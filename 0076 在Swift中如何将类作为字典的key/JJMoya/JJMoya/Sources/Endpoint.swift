//
//  Endpoint.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public enum EndpointSampleResponse {
    case networkResponse(Int, Data)
    case response(HTTPURLResponse, Data)
    case networkError(NSError)
}

open class Endpoint {
    
    public typealias SampleResponseClosure = () -> EndpointSampleResponse
    
    public let url: String
    
    public let sampleResponseClosure: SampleResponseClosure 
    
    public let method: JJMoya.Method
    
    public let task: Task
    
    public let httpHeaderFields: [String: String]?
    
    public init(url: String, sampleResponseClosure: @escaping SampleResponseClosure, method: JJMoya.Method, task: Task, httpHeaderFields: [String: String]?) {
        self.url = url
        self.sampleResponseClosure = sampleResponseClosure
        self.method = method
        self.task = task
        self.httpHeaderFields = httpHeaderFields
    }
    
    open func adding(newHTTPHeaderFields: [String: String]) -> Endpoint {
        return Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: task, httpHeaderFields: add(httpHeaderFields: newHTTPHeaderFields))
    }
    
    open func replacing(task: Task) -> Endpoint {
        return Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: task, httpHeaderFields: httpHeaderFields)
    }
    
    fileprivate func add(httpHeaderFields headers: [String: String]?) -> [String: String]? {
        guard let unwrappedHeaders = headers, unwrappedHeaders.isEmpty == false else {
            return self.httpHeaderFields
        } 
        
        var newHTTPHeaderFields = self.httpHeaderFields ?? [:]
        unwrappedHeaders.forEach { key, value in
            newHTTPHeaderFields[key] = value
        }
        return newHTTPHeaderFields
    }
}

public extension Endpoint {
    
    func urlRequest() throws -> URLRequest {
        
        guard let requestURL = Foundation.URL(string: url) else {
            throw MoyaError.requestMapping(url)
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = httpHeaderFields
        
        switch task {
        case .requestPlain, .uploadFile, .uploadMultipart, .downloadDestination:
            return request
        case .requestData(let data):
            request.httpBody = data
            return request
        case let .requestJSONEncodable(encodable):
            return try request.encoded(encodable: encodable)
        case let .requestCustomJSONEncodable(encodable, encoder):
            return try request.encoded(encodable: encodable, encoder: encoder)
        case let .requestParameters(parameters, encoding):
            return try request.encoded(parameters: parameters, parameterEncoding: encoding)
        case let .uploadCompositeMultipart(_, urlParameters):
            let parameterEncoding = URLEncoding(destination: .queryString)
            return try request.encoded(parameters: urlParameters, parameterEncoding: parameterEncoding)
        case let .downloadParameters(parameters, parameterEncoding, _):
            return try request.encoded(parameters: parameters, parameterEncoding: parameterEncoding)
        case let .requestCompositeData(bodyData: bodyData, urlParameters: urlParameters):
            request.httpBody = bodyData
            let parameterEncoding = URLEncoding(destination: .queryString)
            return try request.encoded(parameters: urlParameters, parameterEncoding: parameterEncoding)
        case let .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: bodyParameterEncoding, urlParameters: urlParameters):
            if let bodyParameterEncoding = bodyParameterEncoding as? URLEncoding, bodyParameterEncoding.destination != .httpBody {
                fatalError("Only URLEncoding that `bodyEncoding` accepts is URLEncoding.httpBody. Others like `default`, `queryString` or `methodDependent` are prohibited - if you want to use them, add your parameters to `urlParameters` instead.")
            }
            let bodyfulRequest = try request.encoded(parameters: bodyParameters, parameterEncoding: bodyParameterEncoding)
            let urlEncoding = URLEncoding(destination: .queryString)
            return try bodyfulRequest.encoded(parameters: urlParameters, parameterEncoding: urlEncoding)
        }
    }
}

extension Endpoint: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        guard let request = try? urlRequest() else {
            hasher.combine(url)
            return
        }
        hasher.combine(request)
    }
    
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        let lhsRequest = try? lhs.urlRequest()
        let rhsRequest = try? rhs.urlRequest()
        
        if lhsRequest != nil, rhsRequest == nil { return false }
        if lhsRequest == nil, rhsRequest != nil { return false }
        if lhsRequest == nil, rhsRequest == nil { return lhsRequest.hashValue == rhsRequest.hashValue }
        return lhsRequest == rhsRequest
    }
}
