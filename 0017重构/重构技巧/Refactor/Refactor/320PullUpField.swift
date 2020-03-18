//
//  320PullUpField.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/2.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 针对待提升之字段，检查它们的所有被使用点，确认他们以同样的方式被使用。
 - 如果这些字段的名称不同，先将它们改名，使每一个名称都和你想为超类字段取的名称相同。
 - 编译，测试。
 - 在超类中新建一个字段。
 - 移除子类中的字段。
 - 编译，测试。
 - 考虑对超类的新建字段使用Self Encapsulate Field。
 */
class PullUpField {
    
}
