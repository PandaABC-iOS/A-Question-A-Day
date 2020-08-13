//
//  ViewController.swift
//  CustomOperation
//
//  Created by songzhou on 2020/8/8.
//  Copyright © 2020 songzhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    
        testAnimationOperation()
    }
    
    func testCustomOperation() {
        let o1 = CustomOperation()
        o1.name = "1"
        
        let o2 = CustomOperation()
        o2.name = "2"
        
        o2.addDependency(o1)
        printLog("o2 dependencies: \(o2.dependencies)")
        
        OperationQueue.main.addOperation(o2)
        OperationQueue.main.addOperation(o1)
    }
    
    func testAnimationOperation() {
        let o1 = AnimationOperation { (completion) -> () in
            self.asyncFunction {  _ in
                completion(.success(true))
            }
        }
        
        let o2 = AnimationOperation { (completion) -> () in
            self.asyncFunction {  _ in
                completion(.success(true))
            }
        }
        
        o1.name = "1"
        o2.name = "2"
        o2.addDependency(o1)
        
        o1.completionBlock = { [unowned o1] in
            OperationQueue.main.addOperation {
                printLog("completion: \(o1) thread: \(Thread.current)")
            }
        }
        
        o2.completionBlock = { [unowned o2] in
            printLog("completion: \(o2) thread: \(Thread.current)")
        }
        

        let q = queue
        
        q.addOperation(o1)
        q.addOperation(o2)
        printLog("queue: \(q)")
    }
    
    func asyncFunction(_ callback: (Bool)  -> (Void)) {
        Thread.sleep(forTimeInterval: 2)
        callback(true)
    }
    
    let queue = OperationQueue()
    let serialQueue = OperationQueue()
}
