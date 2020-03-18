//
//  250ReplaceNestedConditionalWithGuardClauses.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 对于每个检查，放进一个卫语句。
 - 每次将条件检查替换成卫语句后，编译并测试。
 */
class ReplaceNestedConditionalWithGuardClauses {
    func getPayAmount() -> Double {

        var _isDead: Bool = false

        var _isSeparated: Bool = false

        var _isRetired: Bool = false

        if _isDead {
            return deadAmount()
        }

        if _isSeparated {
            return separatedAmount()
        }

        if _isRetired {
            return retiredAmount()
        }

        return normalPayAmount()
    }

    func deadAmount() -> Double {
        return 0
    }

    func separatedAmount() -> Double {
        return 1
    }

    func retiredAmount() -> Double {
        return 2
    }

    func normalPayAmount() -> Double {
        return 3
    }
}
