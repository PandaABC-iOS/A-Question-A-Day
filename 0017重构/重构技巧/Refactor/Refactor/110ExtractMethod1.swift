//
//  110ExtractMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/19.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation





//class ExtractMethod {
//
//    var name: String = ""
//
//    func printOwing(amount: Double) {
//
//        printBanner()
//        printDetails(amount: amount)
//    }
//
//    func printBanner() {
//
//    }
//
//    func printDetails(amount: Double) {
//        print("name:" + name)
//        print("amount:" + "\(amount)")
//    }
//}

// 范例1：无局部变量
class ExtractMethod1 {

}

// 范例2：有局部变量
// 局部变量最简单的情况：被提炼代码段只是读取这些变量的值，并不修改它们。
// 局部变量是个对象，而被提炼代码段调用了会对该对象造成修改的函数，也可以如法炮制。只有在被提炼代码段真的对一个局部变量赋值的情况下，你才必须采取其他措施。
class ExtractMethod2 {

}

// 范例3：对局部变量再赋值，只讨论临时变量，若发现是源函数的参数被赋值，应该马上使用131 Remove Assignments to Parameters
// 情况一：这个变量若只在被提炼代码段中使用，则将这个临时变量的声明移动到被提炼代码段中，然后一起提炼出去。
// 情况二：被提炼代码段之外的代码也使用了这个变量。
// 情况2.1：这个变量在被提炼代码段之后未再被使用，只需要直接在目标函数中修改它就可以了。
// 情况2.2：如果被提炼代码段之后的代码还使用了这个变量，就需要让目标函数返回该变量改变后的值。

class ExtractMethod3 {

    var name = ""

    var orders = [Double]()

    func printOwing(previousAmount: Double) {
        printBanner()
        let outstanding = getOutstanding(initialValue: previousAmount * 1.2)
        printDetails(outstanding)
    }

    func getOutstanding(initialValue: Double) -> Double {
        var result = initialValue
        for order in orders {
            result += order
        }
        return result
    }

    func printBanner() {

    }

    func printDetails(_ amount: Double) {
        print("name:" + name)
        print("amount:" + "\(amount)")
    }
}
