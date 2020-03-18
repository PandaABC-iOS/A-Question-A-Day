//
//  179ChangeValueToReference.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/21.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 使用Replace Constructor with Factory Method（304）。
 - 编译，测试。
 - 决定由什么对象负责提供访问新对象的途径。
    可能是一个静态字典或一个注册表对象。
    也可以使用多个对象作为新对象的访问点。
 - 决定这些引用对象应该预先创建好，或是应该动态创建。
 - 修改工厂函数，令它返回引用对象。
 - 编译，测试。

 */
class ChangeValueToReference {
    class Customer {
        private var _name: String

        public func getName() -> String {
            return _name
        }

        private init(name: String) {
            _name = name
        }

        public static func create(name: String) -> Customer {
            return Customer(name: name)
        }
    }

    class Order {
        private var _customer: Customer

        public init(customerName: String) {
            _customer = Customer.create(name: customerName)
        }

        public func setCustomer(customerName: String) {
            _customer = Customer.create(name: customerName)
        }

        public func getCustomerName() -> String {
            return _customer.getName()
        }
    }
}
