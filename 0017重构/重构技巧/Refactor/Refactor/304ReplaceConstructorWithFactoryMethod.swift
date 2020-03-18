//
//  304ReplaceConstructorWithFactoryMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/21.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 新建一个工厂函数，让它调用现有的构造函数
 将调用构造函数的代码改为调用工厂函数
 每次替换后，编译并测试
 将构造函数声明为private
 编译
 */

class ReplaceConstructorWithFactoryMethod {

    class Employee {

        private var type: Int

        private init(type: Int) {
            self.type = type
        }

        static func create(type: Int) -> Employee {
            return Employee(type: type)
        }
    }
}
