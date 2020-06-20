//
//  MoyaError.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public enum MoyaError: Swift.Error {
    case imageMapping(Response)
    case jsonMapping(Response)
    case stringMapping(Response)
    case objectMapping(Swift.Error, Response)
    case encodableMapping(Swift.Error)
    case statusCode(Response)
    case underlying(Swift.Error, Response?)
    case requestMapping(String)
    case parameterEncoding(Swift.Error)
}

public extension MoyaError {
    var response: JJMoya.Response? {
        switch self {
        case .imageMapping(let response): return response
        case .jsonMapping(let response): return response
        case .stringMapping(let response): return response
        case .objectMapping(_, let response): return response
        case .encodableMapping: return nil
        case .statusCode(let response): return response
        case .underlying(_, let response): return response
        case .requestMapping: return nil
        case .parameterEncoding: return nil
        }
    }
    
    internal var underlyingError: Swift.Error? {
        switch self {
        case .imageMapping: return nil
        case .jsonMapping: return nil
        case .stringMapping: return nil
        case .objectMapping(let error, _): return error
        case .encodableMapping(let error): return error
        case .statusCode: return nil
        case .underlying(let error, _): return error
        case .requestMapping: return nil
        case .parameterEncoding(let error): return error
        }
    }
}

extension MoyaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .imageMapping:
            return "Failed to map data to an Image"
        case .jsonMapping:
            return "Failed to map data to JSON"
        case .stringMapping:
            return "Failed to map data to a String"
        case .objectMapping:
            return "Failed to map data to a Decodable object."
        case .encodableMapping:
            return "Failed to encode Encodable object into data."
        case .statusCode:
            return "Status code didn't fall within the given range."
        case .underlying(let error, _):
            return error.localizedDescription
        case .requestMapping:
            return "Failed to map Endpoint to a URLRequest"
        case .parameterEncoding(let error):
            return "Failed to encode parameters for URLRequest. \(error.localizedDescription)"
        }
    }
}

extension MoyaError: CustomNSError {
    public var errorUserInfo: [String : Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }
}
