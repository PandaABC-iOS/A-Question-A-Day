//
//  227ReplaceTypeCodeWithStateOrStrategy.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 概述：
 你有一个类型码，它会影响类的行为，但你无法通过继承手法消除它（类型码的值在对象生命期中发生变化）。那么以状态对象取代类型码。
 
做法：
- 1. 使用Self Encapsulate Field 将类型码自我封装起来。
- 2. 新建一个类，根据类型码的用途为它命名。这就是一个状态对象。
- 3. 为这个新类添加子类，每个子类对应一种类型码。
    => 比起逐一添加，一次性加入所有必要的子类可能更简单些。
- 4. 在超类中建立一个抽象的查询函数，用以返回类型码。在每个子类中覆写该函数，返回确切的类型码。
- 5. 编译。
- 6. 在源类中建立一个字段，用以保存新建的状态对象。
- 7. 调整源类中负责查询类型码的函数，将查询动作转发给状态对象。
- 8. 调整源类中为类型码设值的函数，将一个恰当的状态对象子类赋值给“保存状态对象”的那个字段。
- 9. 编译，测试。
*/

class ReplaceTypeCodeWithStateOrStrategy {
    
    class Employee {
        
        private var type: EmployeeType

        private var _monthlySalary = 0
        
        private var _commission = 1
        
        private var _bonus = 2
        
        func getType() -> Int {
            return type.getTypeCode()
        }
        
        func setType(arg: Int) {
            type = EmployeeType.newType(code: arg)
        }
        
        init(type: EmployeeType) {
            self.type = type
        }

        func payAmount() -> Int {
            switch getType() {
            case EmployeeType.ENGINEER:
                return _monthlySalary
            case EmployeeType.SALESMAN:
                return _monthlySalary + _commission
            case EmployeeType.MANAGER:
                return _monthlySalary + _bonus
            default:
                return -1
            }
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
            case ENGINEER:
                return Engineer()
            case SALESMAN:
                return Salesman()
            case MANAGER:
                return Manager()
            default:
                return EmployeeType()
            }
        }
    }
    
    class Engineer: EmployeeType {
        
        override func getTypeCode() -> Int {
            return EmployeeType.ENGINEER
        }
    }
    
    class Manager: EmployeeType {
        override func getTypeCode() -> Int {
            return EmployeeType.MANAGER
        }
    }
    
    class Salesman: EmployeeType {
        override func getTypeCode() -> Int {
            return EmployeeType.SALESMAN
        }
    }
}
