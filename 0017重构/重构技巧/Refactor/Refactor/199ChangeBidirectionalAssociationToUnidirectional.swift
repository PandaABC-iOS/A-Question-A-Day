//
//  199ChangeBidirectionalAssociationToUnidirectional.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 找出保存“你想去除的指针”的字段，检查它的每一个用户，判断是否可以去除该指针。
 - 如果客户使用了取值函数，先运用Self Encapsulate Field 将待删除字段自我封装起来，侯然使用Substitute Algorithm 对付取值函数，令它不再使用该字段。然后编译、测试。
 - 如果用户并未使用取值函数，那就直接修改待删除字段的所有被引用点：改而以其他用途获得该字段所保存的对象。每次修改后，编译并测试。
 - 如果已经没有任何函数使用待删除字段，移除所有对该字段的更新逻辑，然后移除该字段。
 - 编译，测试。
 */
class ChangeBidirectionalAssociationToUnidirectional {

}
