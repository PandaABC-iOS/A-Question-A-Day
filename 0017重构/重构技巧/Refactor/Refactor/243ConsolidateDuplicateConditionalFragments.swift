//
//  243ConsolidateDuplicateConditionalFragments.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 鉴别出“执行方式不随条件变化而变化”的代码。
 - 如果这些共通代码位于条件表达式起始处，就将它移到条件表达式之前。
 - 如果这些共通代码位于条件表达式尾端，就将它移到条件表达式之后。
 - 如果这些共通代码位于条件表达式中段，就需要观察共通代码之前或之后的代码是否改变了什么东西。如果的确有所改变，
 应该首先将共通代码向前或向后移动，移至条件表达式的起始处或尾端，再以前面所说的办法来处理。
 - 如果共通的代码不止一条语句，应该首先使用Extract Method 将共通代码提炼到一个独立函数中，再以前面所说的办法来处理。

 */
class ConsolidateDuplicateConditionalFragments {

}
