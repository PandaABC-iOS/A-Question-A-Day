//
//  Cancellable.swift
//  JJMoya
//
//  Created by 张津铭 on 2020/6/12.
//  Copyright © 2020 iOS. All rights reserved.
//

import Foundation

public protocol Cancellable {
    
    var isCancelled: Bool { get }
    
    func cancel()
}

// JJ: 对于没有实际发出的请求，cancel动作直接用SimpleCancellable()。而对于实际发出的请求，cancel则需要取消实际的网络请求。
internal class CancellableWrapper: Cancellable {
    
    internal var innerCancellable: Cancellable = SimpleCancellable() 
    
    var isCancelled: Bool { return innerCancellable.isCancelled }
    
    internal func cancel() {
        innerCancellable.cancel()
    }
}

internal class SimpleCancellable: Cancellable {
    var isCancelled = false
    func cancel() {
        isCancelled = true
    }
}
