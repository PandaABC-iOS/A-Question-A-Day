//
//  255ReplaceConditionalWithPolymorphism.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/26.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation
/**
 概述：
 你手上有个条件表达式，它根据对象类型的不同而选择不同的行为。
 将这个条件表达式的每个分支放进一个子类内的覆写函数中，然后将原始函数声明为抽象函数。

 动机：
 使用条件表达式时，如果你想添加一种新类型，就必须查找并更新所有条件表达式。但如果改用多态，只需建立一个新的子类，并在其中提供适当的函数就行了。
 类的用户不需要了解这个子类，这就大大降低了系统各部分之间的依赖，使系统升级更加容易。
 
 做法：
 - 1. 如果要处理的条件表达式是一个更大函数中的一部分，首先对条件表达式进行分析，然后使用Extract Method（110）将它提炼到一个独立函数去。
 - 2. 如果有必要，使用Move Method（142）将条件表达式放置到继承结构的顶端。
 - 3.  任选一个子类，在其中建立一个函数，使之覆写超类中容纳条件表达式的那个函数。
    将与该子类相关的条件表达式分支复制到新建函数中，并对它进行适当调整。
    => 为了顺利进行这一步骤，你可能需要将超类中的某些 private 字段声明为 internal。
 - 4. 编译，测试。
 - 5. 在超类中删除条件表达式内被复制了的分支。
 - 6. 编译，测试。
 - 7. 针对条件表达式的每个分支，重复上述过程，直到所有分支都被移到子类内的函数为止。
 - 8. 将超类之中容纳条件表达式的函数声明为抽象函数。

 */

class ReplaceConditionalWithPolymorphism {
    
    class Employee {
        
        private var _type: EmployeeType

        init(type: Int) {
            _type = EmployeeType.newType(code: type)
        }

        func getType() -> Int {
            return _type.getTypeCode()
        }

        private var _monthlySalary = 0
        private var _commission = 1
        private var _bonus = 2
        
        func getMonthlySalary() -> Int {
            return _monthlySalary
        }

        func getCommission() -> Int {
            return _commission
        }

        func getBonus() -> Int {
            return _bonus
        }

        func payAmount() -> Int {
            return _type.payAmount(emp: self)
        }
    }

    class Engineer: EmployeeType {
        override func getTypeCode() -> Int {
            return EmployeeType.ENGINEER
        }
        
        override func payAmount(emp: ReplaceConditionalWithPolymorphism.Employee) -> Int {
            return emp.getMonthlySalary()
        }
    }
    
    class Salesman: EmployeeType {
        override func getTypeCode() -> Int {
            return EmployeeType.SALESMAN
        }
        
        override func payAmount(emp: ReplaceConditionalWithPolymorphism.Employee) -> Int {
            return emp.getMonthlySalary() + emp.getCommission()
        }
    }

    class Manager: EmployeeType {
        override func getTypeCode() -> Int {
            return EmployeeType.MANAGER
        }
        
        override func payAmount(emp: ReplaceConditionalWithPolymorphism.Employee) -> Int {
            return emp.getMonthlySalary() + emp.getBonus()
        }
    }

    class EmployeeType {

        static let ENGINEER = 0
        static let SALESMAN = 1
        static let MANAGER = 2

        func getTypeCode() -> Int {
            return -1
        }

        static func newType(code: Int) -> EmployeeType {
            switch code {
            case EmployeeType.ENGINEER:
                return Engineer()
            case EmployeeType.SALESMAN:
                return Salesman()
            case EmployeeType.MANAGER:
                return Manager()
            default:
                return EmployeeType()
            }
        }
        
        func payAmount(emp: Employee) -> Int {
            return -1
        }
    }
}
