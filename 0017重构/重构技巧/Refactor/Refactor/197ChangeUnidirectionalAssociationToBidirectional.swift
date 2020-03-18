//
//  197ChangeUnidirectionalAssociationToBidirectional.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 在被引用类中增加一个字段，用以保存反向指针。
 - 决定由哪个类——引用端还是被引用端——控制关联关系。
    如果两者都是引用对象，其间的关联是一对多关系，那么就由拥有单一引用的那一方承担控制者角色。
    如果某个对象是组成另一个对象的部件，那么由后者负责控制关联关系。
    如果两者都是引用对象，而其间的关联是多对多关系，那么随便其中那个对象来控制关联关系，都无所谓。
 - 在被控制端建立一个辅助函数，其命名应该清楚指出它的有限用途。
 - 如果既有的修改函数在控制端，让它负责更新反向指针。
 - 如果既有的修改函数在被控端，就在控制端建立一个控制函数，并让既有的修改函数调用这个新建的控制函数。

 */
class ChangeUnidirectionalAssociationToBidirectional {

    // 以本例而言，如果一个客户可拥有多份定单，那么就由Order类来控制关联关系。
    class Order {

        private var _customer: Customer

        init(customer: Customer) {
            _customer = customer
        }

        func getCustomer() -> Customer {
            return _customer
        }

        func setCustomer(arg: Customer) {
            _customer = arg
        }
    }

    class Customer {
        public var _orders = [Order]()

        func friendOrders() -> [Order] {
            return _orders
        }
    }
}
