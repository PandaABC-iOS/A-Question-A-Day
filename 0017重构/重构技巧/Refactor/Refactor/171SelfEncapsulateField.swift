//
//  171SelfEncapsulateField.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/20.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：为待封装字段建立取值、设值函数。
 找出该字段的所有引用点，将他们全部改为调用取值、设置函数
 将该字段声明为private
 复查，确保找出所有引用点
 编译，测试
 */
class SelfEncapsulateField {
    class IntRange {
        private var _low = 0
        private var _high = 0

        func include(arg: Int) -> Bool {
            return arg >= low && arg <= high
        }

        func grow(factor: Int) {
            high = high * factor
        }

        init(low: Int, high: Int) {
            _low = low
            _high = high
        }

        public var low: Int {
            set {
                _low = newValue
            }
            get {
                return _low
            }
        }

        public var high: Int {
            set {
                _high = newValue
            }
            get {
                return _high
            }
        }
    }

    class CappedRange: IntRange {

        private var _cap = 0

        init(low: Int, high: Int, cap: Int) {
            super.init(low: low, high: high)
            _cap = cap
        }

        public var cap: Int {
            set {
                _cap = newValue
            }
            get {
                return _cap
            }
        }

        override var high: Int {
            set {
                super.high = newValue
            }
            get {
                return min(super.high, cap)
            }
        }
    }
}
