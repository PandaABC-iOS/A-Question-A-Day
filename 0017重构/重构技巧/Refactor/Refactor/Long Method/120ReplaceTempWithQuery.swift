//
//  120ReplaceTempWithQuery.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/19.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation
/**
 动机：
 临时变量的问题在于：它们是暂时的，而且只能在所属的函数内使用。由于临时变量只在所属函数内可见，所以它们会驱使你写出更长的函数，因为只有这样你才能访问到需要的临时变量。如果把临时变量替换为一个查询，那么同一个类中的所有函数都将可以获得这份信息。
 
 较为简单的情况是：临时变量只被赋值一次，或者赋值给临时变量的表达式不受其他条件影响。
 其他情况下，需要先运用Split Temporary Variable（128）或Separate Query from Modifier（279）使情况变得简单一些，然后再替换临时变量。
 
 做法：
 - 1. 找出只被赋值一次的临时变量
    => 如果某个临时变量被赋值超过一次，考虑使用Split Temporary Variable（128）将它分割成多个变量
 - 2. 将该临时变量声明为let
 - 3. 编译
    => 这可确保该临时变量的确只被赋值一次。
 - 4. 将“对该临时变量赋值”语句的等号右侧部分提炼到一个独立函数中。
    => 首先将函数声明为private，若日后发现有更多的类需要使用它，那时再放松对它的保护。
    => 确保提炼出来的函数无任何副作用。如果有副作用，就对它进行Separate Query from Modifier（279）
 - 5. 编译，测试
 - 6. 在该临时变量身上实施Inline Temp（119）
 
 */

// 范例
class ReplaceTempWithQuery {
    
    var quantity = 0.0
    
    var itemPrice = 0.0

    func getPrice() -> Double {
        return basePrice() * discountFactor()
    }
    
    func basePrice() -> Double {
        return quantity * itemPrice
    }
    
    func discountFactor() -> Double {
        if basePrice() > 1000 {
            return 0.95
        } else {
            return 0.98
        }
    }
}
