//
//  238DecomposeConditional.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 在带有复杂条件逻辑的函数中，代码会告诉你发生的事情，但常常让你弄不清楚为什么会发生这样的事情。将每个分支分解成新函数可以突出条件逻辑，更清楚地表明每个分支的作用，并且突出每个分支的原因。
 
 做法：
 - 1. 将if段落提炼出来，构成一个独立函数。
 - 2. 将then段落和else段落都提炼出来，各自构成一个独立函数。
 
 */
class DecomposeConditional {
    
    var summer_start = Date()
    
    var summer_end = Date()
    
    var quantity = 0.0
    
    var winterRate = 0.0
    
    var winterServiceCharge = 0.0
    
    var summerRate = 0.0
    
    var charge = 0.0
    
    func aa(date: Date) {
        if notSummer(date: date) {
            charge = winterCharge(quantity: quantity)
        } else {
            charge = summerCharge(quantity: quantity)
        }
    }
    
    func notSummer(date: Date) -> Bool {
        return date < summer_start || date > summer_end
    }
    
    func summerCharge(quantity: Double) -> Double {
        return quantity * summerRate
    }
    
    func winterCharge(quantity: Double) -> Double {
        return quantity * winterRate + winterServiceCharge
    }
}

