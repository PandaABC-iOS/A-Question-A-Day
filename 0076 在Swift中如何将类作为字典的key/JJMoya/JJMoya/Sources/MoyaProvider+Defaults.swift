//
//  MoyaProvider+Defaults.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public extension MoyaProvider {
    
    final class func defaultEndpointMapping(for target: Target) -> Endpoint {
        return Endpoint(url: URL(target: target).absoluteString, 
                        sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                        method: target.method,
                        task: target.task, 
                        httpHeaderFields: target.headers)
    }
    
    final class func defaultRequestMapping(for endpoint: Endpoint, closure: RequestResultClosure) {
        do {
            let urlRequest = try endpoint.urlRequest()
            closure(.success(urlRequest))
        } catch MoyaError.requestMapping(let url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    final class func defaultAlamofireSession() -> Session {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        return Session(configuration: configuration, startRequestsImmediately: false)
    }
}
