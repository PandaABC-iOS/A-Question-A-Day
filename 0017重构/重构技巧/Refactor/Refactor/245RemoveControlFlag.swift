//
//  245RemoveControlFlag.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 找出让你跳出这段逻辑的控制标记值。
 - 找出对标记变量赋值的语句，代以恰当的break语句或continue语句。
 - 每次替换后，编译并测试。
 做法二：
 - 运用Extract Method，将整段逻辑提炼到一个独立函数中。
 - 找出让你跳出这段逻辑的控制标记值。
 - 找出对标记变量赋值的语句，代以恰当的return语句。
 - 每次替换后，编译并测试。
 */
class RemoveControlFlag {

}
