//
//  285ReplaceParameterWithExplicitMethods.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/28.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 概述：
 你有一个函数，其中完全取决于参数值而采取不同行为。针对该参数的每一个可能值，建立一个独立函数。
 
 做法：
 - 1. 针对参数的每一种可能值，新建一个明确函数。
 - 2. 修改条件表达式的每个分支，使其调用合适的新函数。
 - 3. 修改每个分支后，编译并测试。
 - 4. 修改原函数的每一个被调用点，改而调用上述的某个合适的新函数。
 - 5. 编译，测试。
 - 6. 所有调用端都修改完毕后，删除原函数。
 */
class ReplaceParameterWithExplicitMethods {

    class Employee {
        
        static var Engineer = 0
        
        static var Salesman = 1
        
        static var Manager = 2
        
        func getType() -> Int {
            return -1
        }
        
        // 这里不能使用Replace Conditional with Polymorphism（255），因为使用该函数时对象根本还没创建出来。
//        static func create(type: Int) -> Employee {
//            switch type {
//            case Engineer:
//                return createEngineer()
//            case Salesman:
//                return createSalesman()
//            case Manager:
//                return createManager()
//            default:
//                return Employee()
//            }
//        }
        
        static func createEngineer() -> Employee {
            return EngineerEmployee()
        }

        static func createSalesman() -> Employee {
            return SalesmanEmployee()
        }
        
        static func createManager() -> Employee {
            return ManagerEmployee()
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
