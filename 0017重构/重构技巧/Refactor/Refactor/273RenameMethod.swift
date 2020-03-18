//
//  273RenameMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/25.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 检查函数签名是否被超类或子类实现过。如果是，则需要针对每份实现分别进行下列步骤。
 声明一个新函数，将它命名为你想要的新名称。将旧函数的代码复制到新函数中，并进行适当调整。
 编译。
 修改旧函数，令它将调用转发给新函数。
 编译，测试。
 找出旧函数的所有被引用点，修改它们，令它们改而引用新函数。每次修改后，编译并测试。
 删除旧函数。
 编译，测试。
 */
class RenameMethod {

}
