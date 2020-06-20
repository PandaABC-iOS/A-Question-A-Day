//
//  AccessTokenPlugin.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/19.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public protocol AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? { get }
}

public enum AuthorizationType {
    case basic
    case bearer
    case custom(String)
    
    public var value: String {
        switch self {
        case .basic: return "Basic"
        case .bearer: return "Bearer"
        case .custom(let customValue): return customValue
        }
    }
}

extension AuthorizationType: Equatable {
    public static func == (lhs: AuthorizationType, rhs: AuthorizationType) -> Bool {
        switch (lhs, rhs) {
        case (.basic, .basic), (.bearer, .bearer):
            return true
        case let (.custom(value1), .custom(value2)):
            return value1 == value2
        default:
            return false
        }
    }
}

public struct AccessTokenPlugin: PluginType {
    
    public typealias TokenClosure = (AuthorizationType) -> String
    
    public let tokenClosure: TokenClosure
    
    public init(tokenClosure: @escaping TokenClosure) {
        self.tokenClosure = tokenClosure
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let authorizable = target as? AccessTokenAuthorizable, let authorizationType = authorizable.authorizationType else {
            return request
        }
        var request = request
        let authValue = authorizationType.value + " " + tokenClosure(authorizationType)
        request.addValue(authValue, forHTTPHeaderField: "Authorization")
        return request
    }
}
