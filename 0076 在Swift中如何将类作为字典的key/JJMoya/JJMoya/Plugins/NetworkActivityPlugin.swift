//
//  NetworkActivityPlugin.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/19.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public enum NetworkActivityChangeType {
    case began, ended
}

// JJ: 通过这个插件可以改良showLoading 和 hideLoading
public final class NetworkActivityPlugin: PluginType {
    
    public typealias NetworkActivityClosure = (_ change: NetworkActivityChangeType, _ target: TargetType) -> Void
    let networkActivityClosure: NetworkActivityClosure
    
    public init(networkActivityClosure: @escaping NetworkActivityClosure) {
        self.networkActivityClosure = networkActivityClosure
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        networkActivityClosure(.began, target)
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        networkActivityClosure(.ended, target)
    }
}
