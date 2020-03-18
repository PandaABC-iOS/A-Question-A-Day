//
//  131RemoveAssignmentsToParameters.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/19.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

// 做法：
// 建立一个临时变量，把待处理的参数值赋予它。
// 以“对参数的赋值”为界，将其后所有对此参数的引用点，全部替换为“对此临时变量的引用”
// 修改赋值语句，使其改为对新建之临时变量赋值。
// 编译，测试

// 因swift中参数默认是let，天然会有一层保护，不会被赋值。因此这个重构手机较少会用到。
class RemoveAssignmentsToParameters {

}
