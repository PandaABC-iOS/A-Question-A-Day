//
//  CredentialsPlugin.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/19.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public final class CredentialsPlugin: PluginType {
    public typealias CredentialClosure = (TargetType) -> URLCredential?
    
    let credentialsClosure: CredentialClosure
    
    public init(credentialsClosure: @escaping CredentialClosure) {
        self.credentialsClosure = credentialsClosure
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        if let credentials = credentialsClosure(target) {
            _ = request.authenticate(with: credentials)
        }
    }
}
