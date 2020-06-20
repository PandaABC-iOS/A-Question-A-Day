//
//  Plugin.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public protocol PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest
    
    func willSend(_ request: RequestType, target: TargetType)
    
    func didReceive(_ result: Result<JJMoya.Response, MoyaError>, target: TargetType)
    
    func process(_ result: Result<JJMoya.Response, MoyaError>, target: TargetType) -> Result<JJMoya.Response, MoyaError>
}

public extension PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest { return request }
    
    func willSend(_ request: RequestType, target: TargetType) {}
    
    func didReceive(_ result: Result<JJMoya.Response, MoyaError>, target: TargetType) {}
    
    func process(_ result: Result<JJMoya.Response, MoyaError>, target: TargetType) -> Result<JJMoya.Response, MoyaError> { return result }
}

public protocol RequestType {
    
    var request: URLRequest? { get }
    
    var sessionHeaders: [String: String] { get }
    
    func authenticate(username: String, password: String, persistence: URLCredential.Persistence) -> Self 
    
    func authenticate(with credential: URLCredential) -> Self
    
    func cURLDescription(calling handler: @escaping (String) -> Void) -> Self
}
