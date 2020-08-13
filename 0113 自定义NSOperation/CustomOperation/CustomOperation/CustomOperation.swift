//
//  CustomOperation.swift
//  CustomOperation
//
//  Created by songzhou on 2020/8/8.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

class CustomOperation: Operation {
    override func start() {
        printLog("operation start \(self) thread:\(Thread.current)")
        self.isExecuting = true
        
        asyncFunction { (ok) -> (Void) in
            printLog("async finished \(self) thread:\(Thread.current)")
            done()
        }
    }
    
    override var isAsynchronous: Bool { true }

    override var isExecuting: Bool {
        get {
            return _executing
        }
        
        set {
            willChangeValue(forKey: "isExecuting")
            _executing =  newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished: Bool {
        get {
            return _finished
        }
        
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var _executing: Bool = false
    private var _finished: Bool = false
    
    private func done() {
        self.isFinished = true
        self.isExecuting = false
    }
    
    private func asyncFunction(_ callback: (Bool)  -> (Void)) {
         Thread.sleep(forTimeInterval: 2)
         callback(true)
     }
}
