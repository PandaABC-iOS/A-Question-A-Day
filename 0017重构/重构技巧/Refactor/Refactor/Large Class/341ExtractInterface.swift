//
//  341ExtractInterface.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/15.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 若干客户使用类接口中的同一子集，或者两个类的接口有部分相同，将相同的子集提炼到一个独立接口中。
 
 做法：
 - 1. 新建一个空接口
 - 2. 在接口中声明待提炼类的共通操作。
 - 3. 让相关的类实现上述接口。
 - 4. 调整客户端的类型声明，令其使用该接口。
 */

protocol Billable {
    func getRate() -> Int
    func hasSpecialSkill() -> Bool
}

class ExtractInterface {

    func charge(emp: Billable, days: Int) -> Double {
        let base = emp.getRate() * days
        if emp.hasSpecialSkill() {
            return Double(base) * 1.05
        } else {
            return Double(base)
        }
    }
    
    class Employee: Billable {
        func getRate() -> Int {
            return 0
        }
        
        func hasSpecialSkill() -> Bool {
            return false
        }
    }
}
