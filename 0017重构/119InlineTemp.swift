//
//  119InlineTemp.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/19.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

// 做法：
// 检查给临时变量赋值的语句，确保等号右边的表达式没有副作用。
// 将临时变量声明为let，然后编译。
// 找到该临时变量的所有引用点，将它们替换为“为临时变量赋值”的表达式
// 每次修改后，编译并测试
// 修改完所有引用点之后，删除该临时变量的声明和赋值语句
// 编译，测试

class InlineTemp {
    
}
