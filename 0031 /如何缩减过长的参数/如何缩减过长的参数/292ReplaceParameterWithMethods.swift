//
//  292ReplaceParameterWithMethods.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/2.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 概述：
 对象调用某个函数，并将所得结果作为参数，传递给另一个函数。而接受该参数的函数自身也能够调用前一个函数。
 让参数接受者去除该项参数，并直接调用前一个函数。
 
 做法：
 - 1. 如果有必要，将参数的计算过程提炼到一个独立函数中。
 - 2. 将函数本体内引用该参数的地方改为调用新建的函数。
 - 3. 每次替换后，修改并测试。
 - 4. 全部替换完成后，使用 Remove Parameter将该参数去掉。
 
 */
class ReplaceParameterWithMethods {

    private var _quantity = 0.0

    private var _itemPrice = 0.0

    func getPrice() -> Double {
        if getDiscountLevel() == 2 {
            return getBasePrice() * 0.1
        } else {
            return getBasePrice() * 0.05
        }
    }
    
    func getDiscountLevel() -> Int {
        if _quantity > 100 {
            return 2
        } else {
            return 1
        }
    }
    
    func getBasePrice() -> Double {
        return _quantity * _itemPrice
    }
}

