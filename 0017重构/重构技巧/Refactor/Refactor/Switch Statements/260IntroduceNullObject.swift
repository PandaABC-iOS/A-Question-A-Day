//
//  260IntroduceNullObject.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/28.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation
import UIKit

/**
 概述：
 将null值替换为null对象。
 
 动机：
 多态的根本好处在于：你不必再向对象询问“你是什么类型”而后根据得到的答案调用对象的某个行为。当某个字段内容为null时，多态可扮演另一个较不直观的用途。
 
 做法：
 - 1. 为源类建立一个子类，使其行为就像是源类的null版本。在源类和null子类中都加上isNull()函数，前者的isNull()应该返回false，后者的isNull()应该返回true。
    => 下面这个办法也可能对你有所帮助：建立一个nullable接口，将isNull()函数放在其中，让源类实现这个接口。
    => 另外，你也可以创建一个测试接口，专门用来检查对象是否为null。
 - 2. 编译。
 - 3. 找出所有“索求源对象却获得一个null”的地方。修改这些地方，使它们改而获得一个空对象。
 - 4. 找出所有“将源对象与null做比较”的地方。修改这些地方，使它们调用isNull()函数。
    => 你可以每次只处理一个源对象及其客户程序，编译并测试后，再处理另一个源对象。
    => 你可以在“不该再出现null”的地方放上一些断言，确保null的确不再出现，这可能对你有所帮助。
 - 5. 编译，测试。
 - 6. 找出这样的程序点：如果对象不是null，做A动作，否则做B动作。
 - 7. 对于每一个上述地点，在null类中覆写A动作，使其行为和B动作相同。
 - 8. 使用上述被覆写的动作，然后删除“对象是否等于null”的条件测试，编译并测试。
 */

protocol Nullable {
    func isNull() -> Bool
}

// 测试接口和instance of 配合使用，来检查对象是否为null
protocol Null {
    
}

class IntroduceNullObject: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let site = Site()
        
        let customer = site.getCustomer()
        
        let plan = customer?.getPlan()
        
        let customerName = customer?.getName()
        
        let weeksDelinquent = customer?.getHistory().getWeekDelinquentInLastYear()

    }
    
    class Site {

        private var _customer: Customer?

        func getCustomer() -> Customer? {
            return _customer == nil ? Customer.newNull() : _customer
        }
    }
    
    class Customer: Nullable {
        
        static func newNull() -> Customer {
            return NullCustomer()
        }

        func isNull() -> Bool {
            return false
        }

        func getName() -> String {
            return ""
        }

        func getPlan() -> BillingPlan {
            return BillingPlan()
        }

        func getHistory() -> PaymentHistory {
            return PaymentHistory()
        }
    }
    
    class NullCustomer: Customer, Null {
        override func isNull() -> Bool {
            return true
        }
        
        override func getName() -> String {
            return "occupant"
        }
        
        override func getPlan() -> IntroduceNullObject.BillingPlan {
            return BillingPlan.basic()
        }
        
        override func getHistory() -> IntroduceNullObject.PaymentHistory {
            return PaymentHistory.newNull()
        }
    }
    
    class BillingPlan {

        static func basic() -> BillingPlan {
            return BillingPlan()
        }
        
    }

    class PaymentHistory {
        func getWeekDelinquentInLastYear() -> Int {
            return 0
        }
        
        static func newNull() -> PaymentHistory {
            return NullPaymentHistory()
        }
    }
    
    class NullPaymentHistory: PaymentHistory {
        override func getWeekDelinquentInLastYear() -> Int {
            return 0
        }
    }
}
