//
//  295IntroduceParameterObject.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/2.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 常会看到特定的一组参数总是一起被传递。我们可以运用一个对象包装所有这些数据，再以该对象取代它们。
 本项重构的价值在于缩短参数列。
 当把这些参数组织到一起之后，往往很快可以发现一些可被移至新建类的行为。原本使用那些参数的函数对这一组参数会有一些共通的处理，如果将这些共通行为移到新对象中，你可以减少很多重复代码。
 
 做法：
 - 1. 新建一个类，用以表现你想替换的一组参数。将这个类设为不可变的。
 - 2. 编译。
 - 3. 针对使用该组参数的所有函数，实施Add Parameter，传入上述新建类的实例对象，并将此参数值设为null。
    => 如果你所修改的函数被其他很多函数调用，那么可以保留修改前的旧函数，并令它调用修改后的新函数。你可以先对就函数进行重构，然后逐一修改调用端使其调用新函数，最后再将旧函数删除。
 - 4. 对于Data Clumps中的每一项，从函数签名中移除之，并修改调用端和函数本体，令它们都改而通过新的参数对象取得该值。
 - 5. 每去除一个参数，编译并测试。
 - 6. 将原先的参数全部去除之后，观察有无适当函数可以运用Move Method搬移到参数对象之中。
    => 被搬移的可能是整个函数，也可能是函数中的一个段落。如果是后者，首先使用Extract Method（110）将该段落提炼为一个独立函数，再搬移这一新建函数。
 */

class IntroduceParameterObject {
    class Entry {

        let flow = Account().getFlowBetween(range: DateRange(start: Date(), end: Date()))
        
        let value: Double
        
        let chargeDate: Date
        
        init(value: Double, chargeDate: Date) {
            self.value = value
            self.chargeDate = chargeDate
        }
        
        func getDate() -> Date {
            return chargeDate
        }

        func getValue() -> Double {
            return value
        }
    }
    
    class Account {

        private var entries = [Entry]()

        func getFlowBetween(range: DateRange) -> Double {
            var result = 0.0
            for aEntry in entries {
                if range.includes(arg: aEntry.getDate()) {
                    result += aEntry.getValue()
                }
            }
            return result
        }
    }
    
    class DateRange {
        
        let start: Date
        
        let end: Date
        
        init(start: Date, end: Date) {
            self.start = start
            self.end = end
        }
        
        func getStart() -> Date {
            return start
        }
        
        func getEnd() -> Date {
            return end
        }
        
        func includes(arg: Date) -> Bool {
            return arg == start || arg == end || (arg > start && arg < end)
        }
    }
}

