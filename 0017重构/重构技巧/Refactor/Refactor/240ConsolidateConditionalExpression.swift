//
//  240ConsolidateConditionalExpression.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 确定这些条件语句都没有副作用。
 - 使用适当的逻辑操作符，将一系列相关条件表达式合并为一个。
 - 编译，测试。
 - 对合并后的条件表达式实施Extract Method。

 */
class ConsolidateConditionalExpression {

    private var _seniority = 0

    private var _monthsDisabled = 0

    private var _isPartTime = true

    func disablilityAmount() -> Double {
        if isNotEligibleForDisability() {
            return 0
        }
        return -1
    }

    func isNotEligibleForDisability() -> Bool {
        return _seniority < 2 || _monthsDisabled > 12 || _isPartTime
    }
}
