//
//  MoyaProvider+Internal.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public extension Method {
    var supportsMultipart: Bool {
        switch self {
        case .post, .put, .patch, .connect:
            return true
        default:
            return false
        }
    }
}

public extension MoyaProvider {
    
    func requestNormal(_ target: Target, callbackQueue: DispatchQueue?, progress: JJMoya.ProgressBlock?, completion: @escaping JJMoya.Completion) -> Cancellable {
        
        let endpoint = self.endpoint(target)
        let stubBehavior = self.stubClosure(target)
        let cancellableToken = CancellableWrapper()
        
        let pluginsWithCompletion: JJMoya.Completion = { result in
            // JJ: 注意这里reduce的用法，这里用plugins对返回的回调进行处理
            let processedResult = self.plugins.reduce(result) { $1.process($0, target: target) }
            completion(processedResult)
        }
        
        if trackInflights {
            lock.lock()
            var inflightCompletionBlocks = self.inflightRequests[endpoint]
            inflightCompletionBlocks?.append(pluginsWithCompletion)
            self.inflightRequests[endpoint] = inflightCompletionBlocks
            lock.unlock()
            
            if inflightCompletionBlocks != nil {
                return cancellableToken
            } else {
                lock.lock()
                self.inflightRequests[endpoint] = [pluginsWithCompletion]
                lock.unlock()
            }
        }
        
        let performNetworking = { (requestResult: Result<URLRequest, MoyaError>) in
            if cancellableToken.isCancelled {
                self.cancelCompletion(completion, target: target)
                return
            }
            var request: URLRequest!
            
            switch requestResult {
            case .success(let urlRequest):
                request = urlRequest
            case .failure(let error):
                pluginsWithCompletion(.failure(error))
                return
            }
            
            let networkCompletion: JJMoya.Completion = { result in
                if self.trackInflights {
                    self.inflightRequests[endpoint]?.forEach { $0(result) }
                    
                    self.lock.lock()
                    self.inflightRequests.removeValue(forKey: endpoint)
                    self.lock.lock()
                } else {
                    pluginsWithCompletion(result)
                }
            }
            
            cancellableToken.innerCancellable = self.performRequest(target, request: request, callbackQueue: callbackQueue, progress: progress, completion: networkCompletion, endpoint: endpoint, stubBehavior: stubBehavior)
        }
        
        requestClosure(endpoint, performNetworking)
        
        return cancellableToken
    }
    
    private func performRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, progress: JJMoya.ProgressBlock?, completion: @escaping JJMoya.Completion, endpoint: Endpoint, stubBehavior: JJMoya.StubBehavior) -> Cancellable {
        switch stubBehavior {
        case .never:
            switch endpoint.task {
            case .requestPlain, .requestData, .requestJSONEncodable, .requestCustomJSONEncodable, .requestParameters, .requestCompositeData, .requestCompositeParameters:
                return self.sendRequest(target, request: request, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .uploadFile(let file):
                return self.sendUploadFile(target, request: request, callbackQueue: callbackQueue, file: file, progress: progress, completion: completion)
            case .uploadMultipart(let multipartBody), .uploadCompositeMultipart(let multipartBody, _):
                guard !multipartBody.isEmpty && endpoint.method.supportsMultipart else {
                    fatalError("\(target) is not a multipart upload target.")
                }
                return self.sendUploadMultipart(target, request: request, callbackQueue: callbackQueue, multipartBody: multipartBody, progress: progress, completion: completion)
            case .downloadDestination(let destination), .downloadParameters(_, _, let destination):
                return self.sendDownloadRequest(target, request: request, callbackQueue: callbackQueue, destination: destination, progress: progress, completion: completion)
            }
        default:
            // JJ: 通过这种方法区分了假数据和真请求
            return self.stubRequest(target, request: request, callbackQueue: callbackQueue, completion: completion, endpoint: endpoint, stubBehavior: stubBehavior)
        }
    }
    
    func cancelCompletion(_ completion: JJMoya.Completion, target: Target) {
        let error = MoyaError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil), nil)
        plugins.forEach { $0.didReceive(.failure(error), target: target) }
        completion(.failure(error))
    }
    
    final func createStubFunction(_ token: CancellableToken, forTarget target: Target, withCompletion completion: @escaping JJMoya.Completion, endpoint: Endpoint, plugins: [PluginType], request: URLRequest) -> (() -> Void) {
        return {
            if token.isCancelled {
                self.cancelCompletion(completion, target: target)
                return
            }
            
            let validate = { (response: JJMoya.Response) -> Result<JJMoya.Response, MoyaError> in
                let validCodes = target.validationType.statusCode
                guard !validCodes.isEmpty else { return .success(response) }
                if validCodes.contains(response.statusCode) {
                    return .success(response)
                } else {
                    let statusError = MoyaError.statusCode(response)
                    // JJ: 这里为什么需要多包装一层
                    let error = MoyaError.underlying(statusError, response)
                    return .failure(error)
                }
            }
            
            switch endpoint.sampleResponseClosure() {
            case .networkResponse(let statusCode, let data):
                let response = JJMoya.Response(statusCode: statusCode, data: data, request: request, response: nil)
                let result = validate(response)
                plugins.forEach { $0.didReceive(result, target: target) }
                completion(result)
            case .response(let customResponse, let data):
                let response = JJMoya.Response(statusCode: customResponse.statusCode, data: data, request: request, response: customResponse)
                let result = validate(response)
                plugins.forEach { $0.didReceive(result, target: target) }
                completion(result)
            case .networkError(let error):
                let error = MoyaError.underlying(error, nil)
                plugins.forEach { $0.didReceive(.failure(error), target: target) }
                completion(.failure(error))
            }
        }
    }
    
    final func notifyPluginsOfImpendingStub(for request: URLRequest, target: Target) -> URLRequest {
        let alamoRequest = session.request(request)
        alamoRequest.cancel()
        
        let preparedRequest = plugins.reduce(request) { $1.prepare($0, target: target) }
        let stubbedAlamoRequest = RequestTypeWrapper(request: alamoRequest, urlRequest: preparedRequest)
        plugins.forEach { $0.willSend(stubbedAlamoRequest, target: target) }
        return preparedRequest
    }
}

private extension MoyaProvider {
    
    // JJ: 真正网络请求的拦截者，做了插件的准备工作。对应假数据里的 notifyPluginsOfImpendingStub 方法
    private func interceptor(target: Target) -> MoyaRequestInterceptor {
        return MoyaRequestInterceptor(prepare: { [weak self] urlRequest in
            return self?.plugins.reduce(urlRequest) { $1.prepare($0, target: target) } ?? urlRequest
        })
    }
    
    private func setup(interceptor: MoyaRequestInterceptor, with target: Target, and request: Request) {
        interceptor.willSend = { [weak self, weak request] urlRequest in
            guard let self = self, let request = request else { return }
            
            let stubbedAlamoRequest = RequestTypeWrapper(request: request, urlRequest: urlRequest)
            self.plugins.forEach { $0.willSend(stubbedAlamoRequest, target: target) }
        }
    }
    
    func sendUploadMultipart(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, multipartBody: [MultipartFormData], progress: JJMoya.ProgressBlock? = nil, completion: @escaping JJMoya.Completion) -> CancellableToken {
        let formData = RequestMultipartFormData()
        formData.applyMoyaMultipartFormData(multipartBody)
        
        let interceptor = self.interceptor(target: target)
        let request = session.upload(multipartFormData: formData, with: request, interceptor: interceptor)
        setup(interceptor: interceptor, with: target, and: request)
        
        let validationCodes = target.validationType.statusCode
        let validateReqeust = validationCodes.isEmpty ? request : request.validate(statusCode: validationCodes)
        return sendAlamofireRequest(validateReqeust, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendUploadFile(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, file: URL, progress: ProgressBlock? = nil, completion: @escaping Completion) -> CancellableToken {
        let interceptor = self.interceptor(target: target)
        let uploadRequest = session.upload(file, with: request, interceptor: interceptor)
        setup(interceptor: interceptor, with: target, and: uploadRequest)
        
        let validationCodes = target.validationType.statusCode
        let alamRequest = validationCodes.isEmpty ? uploadRequest : uploadRequest.validate(statusCode: validationCodes)
        return sendAlamofireRequest(alamRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendDownloadRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, destination: @escaping DownloadDestination, progress: ProgressBlock? = nil, completion: @escaping Completion) -> CancellableToken {
        let interceptor = self.interceptor(target: target)
        let downloadRequest = session.download(request, interceptor: interceptor, to: destination)
        setup(interceptor: interceptor, with: target, and: downloadRequest)
        
        let validationCodes = target.validationType.statusCode
        let alamoRequest = validationCodes.isEmpty ? downloadRequest : downloadRequest.validate(statusCode: validationCodes)
        return sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendRequest(_ target: Target, request: URLRequest, callbackQueue: DispatchQueue?, progress: JJMoya.ProgressBlock?, completion: @escaping JJMoya.Completion) -> CancellableToken {
        let interceptor = self.interceptor(target: target)
        let initialRequest = session.request(request, interceptor: interceptor)
        setup(interceptor: interceptor, with: target, and: initialRequest)
        
        let validationCodes = target.validationType.statusCode
        let alamoRequest = validationCodes.isEmpty ? initialRequest : initialRequest.validate(statusCode: validationCodes)
        return sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendAlamofireRequest<T>(_ alamoRequest: T, target: Target, callbackQueue: DispatchQueue?, progress progressCompletion: JJMoya.ProgressBlock?, completion: @escaping JJMoya.Completion) -> CancellableToken where T: Requestable, T: Request {
     
        let plugins = self.plugins
        var progressAlamoRequest = alamoRequest
        
        let progressClosure: (Progress) -> Void = { progress in
            
            let sendProgress: () -> Void = {
                progressCompletion?(ProgressResponse(progress: progress))
            }
            
            if let callbackQueue = callbackQueue {
                callbackQueue.async(execute: sendProgress)
            } else {
                sendProgress()
            }
        }
        
        if progressCompletion != nil {
            // JJ: 比直接用 == 去比较更Swift化一点
            switch progressAlamoRequest {
            case let downloadRequest as DownloadRequest:
                if let downloadRequest = downloadRequest.downloadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = downloadRequest
                }
            case let uploadRequest as UploadRequest:
                if let uploadRequest = uploadRequest.uploadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = uploadRequest
                }
            case let dataRequest as DataRequest:
                if let dataRequest = dataRequest.downloadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = dataRequest
                }
            default: break
            }
        }
        
        let completionHandler: RequestableCompletion = { response, request, data, error in
            let result = convertResponseToResult(response, request: request, data: data, error: error)
            
            plugins.forEach { $0.didReceive(result, target: target) }
            
            if let progressCompletion = progressCompletion {
                let value = try? result.get()
                switch progressAlamoRequest {
                case let downloadRequest as DownloadRequest:
                    progressCompletion(ProgressResponse(progress: downloadRequest.downloadProgress, response: value))
                case let uploadRequest as UploadRequest:
                    progressCompletion(ProgressResponse(progress: uploadRequest.uploadProgress, response: value))
                case let dataRequest as DataRequest:
                    progressCompletion(ProgressResponse(progress: dataRequest.downloadProgress, response: value))
                default:
                    progressCompletion(ProgressResponse(response: value))
                }
            }
            completion(result)
        }
        
        progressAlamoRequest = progressAlamoRequest.response(callbackQueue: callbackQueue, completionHandler: completionHandler)
        progressAlamoRequest.resume()
        return CancellableToken(request: progressAlamoRequest)
    }
}
