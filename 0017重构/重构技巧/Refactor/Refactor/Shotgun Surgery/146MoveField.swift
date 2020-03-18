//
//  146MoveField.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/20.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 概述：
 你的程序中，某个字段被其所驻类之外的另一个类更多地用到。
 在目标类新建一个字段，修改源字段的所有用户，令它们改用新字段。
 
 动机：
 在使用Extract Class 时，我也可能需要搬移字段。此时我会先搬移字段，然后再搬移函数。
 
 做法：
 - 1. 如果字段的访问级是public，使用EncpsulateField（206）将它封装起来。
    => 如果你有可能移动那些频繁访问该字段的函数，或如果有许多函数访问某个字段，先使用Self Encapsulate Field也许会有帮助。
 - 3. 编译，测试。
 - 4. 在目标类中建立与源字段相同的字段，并同时建立相应的设值、取值函数。
 - 5. 编译目标类。
 - 6. 决定如何在源对象中引用目标对象。
    => 首先看是否有一个现成的字段或函数可以助你得到目标对象。如果没有，就看能否轻易建立这样一个函数。如果还不行，就得在源类中新建一个字段来存放目标对象。这可能是个永久性修改，但你也可以让它是暂时的，因为后续重构可能会把这个新建字段除掉。
 - 7. 删除源字段。
 - 8. 将所有对源字段的引用替换为对某个目标函数的调用。
    => 如果需要读取该变量，就把对源字段的引用替换为对目标取值函数的调用；如果要对该变量赋值，就把对源字段的引用替换成对设值函数的调用。
    => 如果源字段不是private的，就必须在源类的所有子类中查找源字段的引用点，并进行相应替换。
 - 9. 编译，测试。
 */

// 范例1，使用SelfEncapsulateField自我封装
class MoveField {
    class Account {
        private var type = AccountType()

//        private var _interestRate = 0.0

        func interestForAmountDays(amount: Double, days: Double) -> Double {
            return getInterestRate() * amount * days / 365
        }

        func getInterestRate() -> Double {
            return type.getInterestRate()
        }

        func setInterestRate(arg: Double) {
            type.setInterestRate(arg: arg)
        }
    }

    class AccountType {

        private var _interestRate = 0.0

        func setInterestRate(arg: Double) {
            _interestRate = arg
        }

        func getInterestRate() -> Double {
            return _interestRate
        }
    }
}
