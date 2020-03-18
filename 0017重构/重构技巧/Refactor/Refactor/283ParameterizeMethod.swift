//
//  283ParameterizeMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/28.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 新建一个带有参数的函数，使它可以替换先前所有的重复性函数。
 - 编译。
 - 将调用旧函数的代码改为调用新函数。
 - 编译，测试。
 - 对所有旧函数重复上述步骤，每次替换后，修改并测试。

 */
class ParameterizeMethod {
    // 范例1
    class Employee {
        private var salary = 0.0

        func tenPercentRaise() {
            salary *= 1.1
        }

        func fivePercentRaise() {
            salary *= 1.05
        }

        func raise(factor: Double) {
            salary *= (1 + factor)
        }
    }

    // 范例2
    func baseCharge() -> Dollars {
        var result = usageInRang(start: 0, end: 100) * 0.03
        result += usageInRang(start: 100, end: 200) * 0.05
        result += usageInRang(start: 200, end: Int.max) * 0.07
        return Dollars(result: result)
//
//        if lastUsage() > 100 {
//            result += Double(min(lastUsage(), 200) - 100) * 0.05
//        }
//
//        if lastUsage() > 200 {
//            result += Double(lastUsage() - 200) * 0.07
//        }
//        return Dollars(result: result)
    }

    func usageInRang(start: Int, end: Int) -> Double {
        if lastUsage() > start {
            return Double(min(lastUsage(), end) - start)
        } else {
            return 0.0
        }
    }

    class Dollars {
        init(result: Double) {

        }
    }

    func lastUsage() -> Int {
        return 100
    }

}
