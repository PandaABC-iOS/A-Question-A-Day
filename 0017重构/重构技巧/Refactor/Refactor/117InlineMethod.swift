//
//  117InlineMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/19.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

// 做法：
// 检查函数，确定它不具有多态性
// 找出这个函数的所有被调用点
// 将这个函数的所有被调用点都替换为函数本体
// 编译，测试。
// 删除该函数的定义。
class InlineMethod {

}
