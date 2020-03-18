//
//  223ReplaceTypeCodeWithSubclasses.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/21.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 概述：
 你有一个不可变的类型码，它会影响类的行为。那么以子类取代这个类型码。
 
 动机：
 该手法的好处在于，它“把对不同行为的了解”从类用户那儿转移到了类自身。如果需要再加入新的行为变化，只需添加一个子类就行了。如果没有多态机制，就必须找到所有条件表达式，并逐一修改它们。因此，如果未来还有可能加入新行为，这项重构将特别有价值。
 
 做法：
 - 1. 使用Self Encapsulate Field（171）将类型码自我封装起来。
    => 如果类型码被传递给构造函数，就需要将构造函数换成工厂函数。
 - 2. 为类型码的每一个数值建立一个相应的子类。在每个子类中覆写类型码的取值函数，使其返回相应的类型码值。
    => 这个值被硬编码于return语句中。这看起来很肮脏，但只是权宜之计。当所有case子句都被替换后，问题就解决了。
 - 3. 每建立一个新的子类，编译并测试。
 - 4. 从超类中删掉保存类型码的字段。将类型码访问函数声明为抽象函数。
 - 5. 编译，测试。
 */
class ReplaceTypeCodeWithSubclasses {

    class Employee {
        
        static var Engineer = 0
        
        static var Salesman = 1
        
        static var Manager = 2
        
        func getType() -> Int {
            return -1
        }
        
        static func create(type: Int) -> Employee {
            
            switch type {
            case Engineer:
                return EngineerEmployee()
            case Salesman:
                return SalesmanEmployee()
            case Manager:
                return ManagerEmployee()
            default:
                return Employee()
            }
        }

    }
    
    class EngineerEmployee: Employee {
        
        override func getType() -> Int {
            return Employee.Engineer
        }
    }
    
    class SalesmanEmployee: Employee {
        override func getType() -> Int {
            return Employee.Salesman
        }
    }
    
    class ManagerEmployee: Employee {
        override func getType() -> Int {
            return Employee.Manager
        }
    }
}
