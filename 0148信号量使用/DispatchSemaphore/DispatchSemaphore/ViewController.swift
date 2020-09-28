//
//  ViewController.swift
//  DispatchSemaphore
//
//  Created by Song Zhou on 2020/9/28.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sem = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "test")
        for i in 0..<10 {
            queue.async {
                sleep(1)
                print("async \(i), current thread: \(Thread.current)")
                sem.signal()
            }
            
            print("i \(i), current thread: \(Thread.current)")
            let _ = sem.wait(timeout: DispatchTime.distantFuture)
        }
        
        print("执行完毕 current thread: \(Thread.current)")
    }
}

