//
//  185ReplaceArrayWithObject.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/26.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 新建一个类表示数组所拥有的信息，并在其中以一个public字段保存原先的数组。
 - 修改数组的所有用户，让它们改用新类的实例。
 - 编译，测试。
 - 逐一为数组元素添加取值、设值函数。根据元素的用途，为这些访问函数命名。修改客户端代码，让它们通过访问函数取用数组内的元素。每次修改后，编译并测试。
 - 当所有对数组的直接访问都转而调用访问函数后，将新类中保存该数组的字段声明为private。
 - 编译。
 - 对于数组内的每一个元素，在新类中创建一个类型相当的字段。修改该元素的访问函数，令它改用上述的新建字段。
 - 每修改一个元素，编译并测试。
 - 数组的所有元素都有了相应字段之后，删除该数组。

 */
class ReplaceArrayWithObject {

    var row = Performance()

    init() {
        row.setName(arg: "Liverpool")
        row.setWins(arg: "15")
    }

    class Performance {

//        private var _data = [String]()

        private var _name = ""

        private var _wins = ""

        public func getName() -> String {
            return _name
        }

        public func setName(arg: String) {
            _name = arg
        }

        public func getWins() -> Int? {
            return Int(_wins)
        }

        public func setWins(arg: String) {
            _wins = arg
        }
    }
}
