//
//  275AddParameter.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/28.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 检查函数签名是否被超类或子类实现过。如果是，则需要针对每份实现分别进行下列步骤。
 - 声明一个新函数，名称与原函数相同，只是加上新添参数。将旧函数的代码赋值到新函数中。
 - 编译。
 - 修改旧函数，令它调用新函数。
 - 编译，测试。
 - 找出旧函数的所有被引用点，将它们全部修改为对新函数的引用。每次修改后，编译并测试。
 - 删除旧函数。
 - 编译，测试。
 */
class AddParameter {

}
