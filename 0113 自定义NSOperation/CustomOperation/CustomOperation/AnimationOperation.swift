//
//  AnimationOperation.swift
//  CustomOperation
//
//  Created by songzhou on 2020/8/10.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

class AnimationOperation: Operation {
    typealias AnimationOperationStartClosure = (_ completion: @escaping (_ result: Result<Any?, Error>)->()) -> ()
    
    init(start: @escaping AnimationOperationStartClosure) {
        _start = start
        super.init()
    }
    
    private let _start: AnimationOperationStartClosure
    
    override func start() {
        printLog("AnimationOperation \(self), start:\(Thread.current)")
        _start { result in
            switch result {
            case .success(let data):
                self.data = data
            case .failure(let error):
                self.error = error
            }
            
            printLog("AnimationOperation \(self), finished:\(Thread.current)")
            self.done()
        }
    }
    
    var data: Any?
    var error: Error?
    
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
}
