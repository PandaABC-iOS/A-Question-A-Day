//
//  279SeparateQueryFromModifier.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/20.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：任何有返回值的函数，都不应该有看得到的副作用。
 如果遇到一个既有返回值又有副作用的函数，就应该试着将查询动作从修改动作中分割出来。
 做法：
 - 新建一个查询函数，令它返回值与原函数相同。
 - 修改原函数，令它调用查询函数，并返回获得的结果。
 - 编译，测试
 - 将调用原函数的代码改为调用查询函数。然后，在调用查询函数的那一行之前，加上对原函数的调用。每次修改之后，编译并测试
 - 将原函数的返回值改为void，并删除其中所有的return语句
 */

/// 范例
class SeparateQueryFromModifier {
    func sendAlert(peoples: [String]) {
        if foundPerson(peoples: peoples) != "" {
            sendAlert()
        }
    }

    func sendAlert() {

    }

    func checkSecurity(peoples: [String]) {
        sendAlert(peoples: peoples)
        let found = foundPerson(peoples: peoples)
        someLaterCode(people: found)
    }

    func someLaterCode(people: String) {

    }

    func foundPerson(peoples: [String]) -> String {
        for aPeople in peoples {
            if aPeople == "Don" {
                return "Don"
            }
            if aPeople == "John" {
                return "John"
            }
        }
        return ""
    }
}
