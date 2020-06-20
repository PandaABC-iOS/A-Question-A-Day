//
//  Task.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public enum Task {
    
    case requestPlain
    
    case requestData(Data)
    
    case requestJSONEncodable(Encodable)
    
    case requestCustomJSONEncodable(Encodable, encoder: JSONEncoder)
    
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
    
    case requestCompositeData(bodyData: Data, urlParameters: [String: Any])
    
    case requestCompositeParameters(bodyParameters: [String: Any], bodyEncoding: ParameterEncoding, urlParameters: [String: Any])
    
    case uploadFile(URL)
    
    case uploadMultipart([MultipartFormData])
    
    case uploadCompositeMultipart([MultipartFormData], urlParameters: [String: Any])
    
    case downloadDestination(DownloadDestination)
    
    case downloadParameters(parameters: [String: Any], encoding: ParameterEncoding, destination: DownloadDestination)
    
}
