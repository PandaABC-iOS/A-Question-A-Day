//
//  Moya+Alamofire.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation
import Alamofire

public typealias Session = Alamofire.Session
internal typealias Request = Alamofire.Request
internal typealias DownloadRequest = Alamofire.DownloadRequest
internal typealias UploadRequest = Alamofire.UploadRequest
internal typealias DataRequest = Alamofire.DataRequest

internal typealias URLRequestConvertible = Alamofire.URLRequestConvertible

public typealias Method = Alamofire.HTTPMethod

public typealias ParameterEncoding = Alamofire.ParameterEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias URLEncoding = Alamofire.URLEncoding

public typealias RequestMultipartFormData = Alamofire.MultipartFormData

public typealias DownloadDestination = Alamofire.DownloadRequest.Destination

extension Request: RequestType {
    public var sessionHeaders: [String : String] {
        return delegate?.sessionConfiguration.httpAdditionalHeaders as? [String: String] ?? [:]
    }
}

public typealias RequestInterceptor = Alamofire.RequestInterceptor

public final class CancellableToken: Cancellable, CustomDebugStringConvertible {
    
    let cancelAction: () -> Void
    let request: Request?
    
    public fileprivate(set) var isCancelled = false
    
    fileprivate var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    public func cancel() {
        _ = lock.wait(timeout: DispatchTime.distantFuture)
        defer { lock.signal() }
        guard !isCancelled else {
            return
        }
        isCancelled = true
        cancelAction()
    }
    
    public init(action: @escaping () -> Void) {
        self.cancelAction = action
        self.request = nil
    }
    
    init(request: Request) {
        self.request = request
        self.cancelAction = {
            request.cancel()
        }
    }
    
    public var debugDescription: String {
        guard let request = self.request else {
            return "Empty Request"
        }
        return request.cURLDescription()
    }
    
} 

internal typealias RequestableCompletion = (HTTPURLResponse?, URLRequest?, Data?, Swift.Error?) -> Void

internal protocol Requestable {
    func response(callbackQueue: DispatchQueue?, completionHandler: @escaping RequestableCompletion) -> Self
}

extension DataRequest: Requestable {
    func response(callbackQueue: DispatchQueue?, completionHandler: @escaping RequestableCompletion) -> Self {
        if let callbackQueue = callbackQueue {
            return response(queue: callbackQueue) { handler in
                completionHandler(handler.response, handler.request, nil, handler.error)
            }
        } else {
            return response { handler in
                completionHandler(handler.response, handler.request, nil, handler.error)
            }
        }
    }
}

extension DownloadRequest: Requestable {
    func response(callbackQueue: DispatchQueue?, completionHandler: @escaping RequestableCompletion) -> Self {
        if let callbackQueue = callbackQueue {
            return response(queue: callbackQueue) { handler in
                completionHandler(handler.response, handler.request, nil, handler.error)
            }
        } else {
            return response { handler in
                completionHandler(handler.response, handler.request, nil, handler.error)
            }
        }
    }
}

final class MoyaRequestInterceptor: RequestInterceptor {
    
    private let lock: NSRecursiveLock = NSRecursiveLock()
    
    var prepare: ((URLRequest) -> URLRequest)?
    private var internalWillSend: ((URLRequest) -> Void)?
    
    var willSend: ((URLRequest) -> Void)? {
        get {
            lock.lock(); defer { lock.unlock() }
            return internalWillSend
        }
        
        set {
            lock.lock(); defer { lock.unlock() }
            internalWillSend = newValue
        }
    }
    
    init(prepare: ((URLRequest) -> URLRequest)? = nil, willSend: ((URLRequest) -> Void)? = nil) {
        self.prepare = prepare
        self.willSend = willSend
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let request = prepare?(urlRequest) ?? urlRequest
        willSend?(request)
        completion(.success(request))
    }
}
