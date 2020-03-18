//
//  100RemoveSettingMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/2.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 检查设值函数被使用的情况，看它是否只被构造函数调用，或者被构造函数所调用的另一个函数调用。
 - 修改构造函数，使其直接访问设值函数所针对的那个变量。
 - 编译，测试。
 - 移除这个设值函数，将它所针对的字段设为let
 - 编译，测试。
 */
class RemoveSettingMethod {
    class Account {
        private let id: String

        init(id: String) {
            self.id = id
        }


    }
}
