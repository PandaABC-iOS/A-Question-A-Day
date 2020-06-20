//
//  AnyEncodable.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/18.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

struct AnyEncodable: Encodable {
    private let encodable: Encodable
    
    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }
    
    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
