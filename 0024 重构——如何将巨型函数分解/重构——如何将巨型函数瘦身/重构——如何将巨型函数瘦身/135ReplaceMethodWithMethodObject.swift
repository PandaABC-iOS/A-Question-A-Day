//
//  135ReplaceMethodWithMethodObject.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/20.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 概述：
 将一个函数放进一个单独对象中，如此一来局部变量就成了对象内的字段。然后你可以在同一个对象中将这个大型函数分解为多个小型函数。
 
 动机：
 有时候发现根本无法拆解一个需要拆解的函数。这种情况下，可以祭出该方法。
 Replace Method With Method Object 会将所有局部变量都变成函数对象的字段。
 然后就可以对这个新对象使用Extract Method（110）创造出新的函数，从而将原本的大型函数拆解变短。
 
 做法：
 - 1. 建立一个新类，根据待处理函数的用途，为这个类命名。
 - 2. 在新类中建立一个let字段，用以保存原先大型函数所在的对象。我们将这个字段称为“源对象”。同时，针对原函数的每个临时变量和每个参数，在新类中建立一个对应的字段保存之。
 - 3. 在新类中建立一个构造函数，接收源对象及原函数的所有参数作为参数。
 - 4. 在新类中建立一个compute()函数。
 - 5. 将原函数的代码复制到compute()函数中。如果需要调用源对象的任何函数，请通过源对象字段调用。
 - 6. 编译。
 - 7. 将旧函数的函数本体替换为这样一条语句：创建上述新类的一个新对象，而后调用其中的compute()函数。
 */

class ReplaceMethodWithMethodObject {
    class Account {
        
        func delta() -> Double {
            return 0.0
        }
        
        func gamma(inputVal: Double, quantity: Double, yearToDate: Double) -> Double {
            return Gamma(source: self, inputVal: inputVal, quantity: quantity, yearToDate: yearToDate).compute()
        }
    }
    
    class Gamma {
        var account = Account()
        var inputVal: Double
        var quantity: Double
        var yearToDate: Double
        var importantValue1: Double = 0.0
        var importantValue2: Double = 0.0
        var importantValue3: Double = 0.0
        
        init(source: Account, inputVal: Double, quantity: Double, yearToDate: Double) {
            self.account = source
            self.inputVal = inputVal
            self.quantity = quantity
            self.yearToDate = yearToDate
        }
        
        func compute() -> Double {
            importantValue1 = inputVal * quantity + account.delta()
            importantValue2 = inputVal * yearToDate + 100.0

            importantThing()
            
            importantValue3 = importantValue2 * 7.0
            return importantValue3 - 2.0 * importantValue2
        }
        
        func importantThing() {
            if yearToDate - importantValue1 > 100.0 {
                importantValue2 -= 20.0
            }
        }
    }
}

