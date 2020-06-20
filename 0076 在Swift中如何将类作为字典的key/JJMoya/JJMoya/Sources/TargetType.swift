//
//  TargetType.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public protocol TargetType {
    
    var baseURL: URL { get }
    
    var path: String { get }
    
    var method: JJMoya.Method { get }
    
    var sampleData: Data { get }
    
    var task: Task { get }
    
    // JJ: 用于验证返回值是否符合要求
    var validationType: ValidationType { get }
    
    var headers: [String: String]? { get }
}

public extension TargetType {
    var validationType: ValidationType {
        return .none
    }
}
