//
//  206EncapsulateField.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/20.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 为public字段提供取值和设值函数
 - 找到这个类以外使用该字段的所有地点。如果客户只是读取该字段，就把引用替换为对取值函数的调用；如果客户修改了该字段值，就将此引用点替换为对设值函数的调用
 - 每次修改之后，编译并测试
 - 将字段的所有用户修改完毕后，把字段声明为private
 - 编译，测试
 */
class EncapsulateField {

}
