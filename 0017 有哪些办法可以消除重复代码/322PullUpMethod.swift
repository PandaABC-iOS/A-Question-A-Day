//
//  322PullUpMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/2.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 如果某个函数的各子类中的函数体都相同，这就是显而易见的Pull Up Method的适用场合。
 另外，当子类的函数覆写了超类的函数，但却仍然做相同的工作，这也需要运用322。
 运用该方法，最麻烦的地方在于，被提升的函数可能会引用只出现于子类而不出现于超类的特性。
 
 做法：
 - 1. 检查待提升函数，确定它们是完全一致的。
    => 如果这些函数看上去做了相同的事，但并不完全一致，可使用Substitute Algorithm让它们变成完全一致。
 - 2. 如果待提升函数的签名不同，将那些签名都修改为你想要在超类中使用的签名。
 - 3. 在超类中新建一个函数，将某一个待提升函数的代码复制到其中，做适当调整，然后编译。
    => 如果你使用的是一种强类型语言，而待提升函数又调用了一个只出现于子类而未出现于超类的函数，你可以在超类中为被调用函数声明一个抽象函数。
    => 如果待提升函数使用了子类的一个字段，你可以使用Pull Up Field将该字段也提升到超类；或者也可以先使用Self Encapsulate Field，然后在超类中把取值函数声明为抽象函数。
 - 4. 移除一个待提升的子类函数。
 - 5. 编译，测试。
 - 6. 逐一移除待提升的子类函数，直到只剩下超类中的函数为止。每次移除之后都需要测试。
 - 7. 观察该函数的调用者，看看是否可以改为使用超类类型的对象。

 */
class PullUpMethod {
    class Customer {
        
        var lastBillDate = Date()
        
        func addBill(date: Date, amount: Double) {
            
        }
        
        func chargeFor(start: Date, end: Date) -> Double {
            return 0.0
        }
        
        func createBill(date: Date) {
            let chargeAmount = chargeFor(start: lastBillDate, end: date)
            addBill(date: date, amount: chargeAmount)
        }
    }
    
    class RegularCustomer: Customer {

        override func chargeFor(start: Date, end: Date) -> Double {
            return 0.0
        }
    }
    
    class PreferredCustomer: Customer {
        
        override func chargeFor(start: Date, end: Date) -> Double {
            return 10.0
        }
    }
}
