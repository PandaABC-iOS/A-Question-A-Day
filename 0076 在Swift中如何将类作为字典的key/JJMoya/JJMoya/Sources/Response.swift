//
//  Response.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public final class Response: CustomDebugStringConvertible, Equatable {
    
    public let statusCode: Int
    
    public let data: Data
    
    public let request: URLRequest?
    
    public let response: HTTPURLResponse?
    
    public init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }
    
    public var description: String {
        return "Status Code: \(statusCode), Data Legth: \(data.count)"
    }
    
    public var debugDescription: String {
        return description 
    }
    
    public static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.statusCode == rhs.statusCode 
            && lhs.data == rhs.data 
            && lhs.response == rhs.response
    }
}

extension Response {
    func filter<R: RangeExpression>(statusCodes: R) throws -> Response where R.Bound == Int {
        guard statusCodes.contains(statusCode) else {
            throw MoyaError.statusCode(self)
        }
        return self
    }
    
    func filter(statusCodes: Int) throws -> Response {
        return try filter(statusCodes: statusCode...statusCode)
    }
    
    func filterSuccessfulStatusCodes() throws -> Response {
        return try filter(statusCodes: 200...299)
    }
    
    func filterSuccessfulStatusAndRedirectCodes() throws -> Response {
        return try filter(statusCodes: 200...399)
    }
    
    func mapImage() throws -> Image {
        guard let image = Image(data: data) else {
            throw MoyaError.imageMapping(self)
        }
        return image
    }
    
    func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            if data.count < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw MoyaError.jsonMapping(self)
        }
    }
    
    func mapString(atKeyPath keyPath: String? = nil) throws -> String {
        if let keyPath = keyPath {
            guard let jsonDictionary = try mapJSON() as? NSDictionary, let string = jsonDictionary.value(forKeyPath: keyPath) as? String else {
                throw MoyaError.stringMapping(self)
            }
            return string
        } else {
            guard let string = String(data: data, encoding: .utf8) else {
                throw MoyaError.stringMapping(self)
            }
            return string
        }
    }
    
    func map<D: Decodable>(_ type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> D {
        
        let serializeToData: (Any) throws -> Data? = { (jsonObject) in
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return nil
            }
            do {
                return try JSONSerialization.data(withJSONObject: jsonObject)
            } catch {
                throw MoyaError.jsonMapping(self)
            }
        }
        
        let jsonData: Data
        keyPathCheck: if let keyPath = keyPath {
            guard let jsonObject = (try mapJSON(failsOnEmptyData: failsOnEmptyData) as? NSDictionary)?.value(forKeyPath: keyPath) else {
                if failsOnEmptyData {
                    throw MoyaError.jsonMapping(self)
                } else {
                    jsonData = data
                    break keyPathCheck
                }
            }
            
            if let data = try serializeToData(jsonObject) {
                jsonData = data
            } else {
                let wrappedJsonObject = ["value": jsonObject]
                let wrappedJsonData: Data
                if let data = try serializeToData(wrappedJsonObject) {
                    wrappedJsonData = data
                } else {
                    throw MoyaError.jsonMapping(self)
                }
                
                do {
                    return try decoder.decode(DecodableWrapper<D>.self, from: wrappedJsonData).value
                } catch let error {
                    throw MoyaError.objectMapping(error, self)
                }
            }
        } else {
            jsonData = data
        }
        
        do {
            if jsonData.count < 1 && !failsOnEmptyData {
                if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONObjectData) {
                    return emptyDecodableValue
                } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONArrayData) {
                    return emptyDecodableValue
                }
            }
            return try decoder.decode(D.self, from: jsonData)
        } catch let error {
            throw MoyaError.objectMapping(error, self)
        }
    }
}

private struct DecodableWrapper<T: Decodable>: Decodable {
    let value: T
}


