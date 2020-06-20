//
//  MultipartFormData.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/15.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public struct MultipartFormData {
    
    public enum FormDataProvider {
        case data(Foundation.Data)
        case file(URL)
        case stream(InputStream, UInt64)
    }
    
    public init(provider: FormDataProvider, name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.provider = provider
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    public let provider: FormDataProvider
    
    public let name: String
    
    public let fileName: String?
    
    public let mimeType: String?
}

internal extension RequestMultipartFormData {
    func append(data: Data, bodyPart: MultipartFormData) {
        append(data, withName: bodyPart.name, fileName: bodyPart.fileName, mimeType: bodyPart.mimeType)
    }
    
    func append(fileURL url: URL, bodyPart: MultipartFormData) {
        if let fileName = bodyPart.fileName, let mimeType = bodyPart.mimeType {
            append(url, withName: bodyPart.name, fileName: fileName, mimeType: mimeType)
        } else {
            append(url, withName: bodyPart.name)
        }
    }
    
    func append(stream: InputStream, length: UInt64, bodyPart: MultipartFormData) {
        append(stream, withLength: length, name: bodyPart.name, fileName: bodyPart.fileName ?? "", mimeType: bodyPart.mimeType ?? "")
    }
    
    func applyMoyaMultipartFormData(_ multipartBody: [JJMoya.MultipartFormData]) {
        for bodyPart in multipartBody {
            switch bodyPart.provider {
            case .data(let data):
                append(data: data, bodyPart: bodyPart)
            case .file(let url):
                append(fileURL: url, bodyPart: bodyPart)
            case .stream(let stream, let length):
                append(stream: stream, length: length, bodyPart: bodyPart)
            }
        }
    }
}
