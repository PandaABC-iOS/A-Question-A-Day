//
//  288PreserveWholeObject.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/28.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 有时候，会将来自同一对象的若干项数据作为参数，传递给某个函数。这样做的问题在于：万一将来被调用函数需要新的数据项，你就必须查找并修改对此函数的所有调用。如果你把这些数据所属的整个对象传给函数，可以避免这种尴尬的处境，因为被调用函数可以向那个参数对象请求任何它想要的信息。
 运用此方法还能提高代码的可读性，因为过长的参数很难使用。
 
 做法：
 - 1. 对你的目标函数新添一个参数项，用以代表原数据所在的完整对象。
 - 2. 编译，测试。
 - 3. 判断哪些参数可被包含在新添加的完整对象中。
 - 4. 选择上述参数之一，将被调用函数中原来引用该参数的地方，改为调用新添参数对象的相应取值函数。
 - 5. 删除该项参数。
 - 6. 编译，测试。
 - 7. 针对所有可从完整对象中获得的参数，重复上述过程。
 - 8. 删除调用端中那些带有被删除参数的代码。
    => 当然，如果调用端还在其他地方使用了这些参数，就不要删除他们。
 - 9. 编译，测试。
 */
class PreserveWholeObject {
    
    class Room {
        
        func daysTempRange() -> TempRange {
            return TempRange()
        }
        
        func withinPlan(plan: HeatingPlan) -> Bool {
            return plan.withinRange(roomRange: daysTempRange())
        }
    }
    
    class HeatingPlan {
        
        func withinRange(roomRange: TempRange) -> Bool {
            return roomRange.includes(arg: roomRange)
        }
        
        private var range = TempRange()
    }
    
    class TempRange {
        func getLow() -> Int {
            return 0
        }
        
        func getHigh() -> Int {
            return 1
        }
        
        func includes(arg: TempRange) -> Bool {
            return arg.getLow() >= getLow() && arg.getHigh() <= getHigh()
        }
    }
}

