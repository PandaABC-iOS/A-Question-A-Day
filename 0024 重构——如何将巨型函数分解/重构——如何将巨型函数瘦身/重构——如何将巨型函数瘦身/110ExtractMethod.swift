//
//  110ExtractMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/14.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：如果每个函数的粒度都很小，那么函数被复用的机会就更大；其次，这会使高层函数读起来就像一系列注释；再其次，如果函数都是细粒度，那么函数的覆写也会更容易些。
 做法：
 - 1. 创造一个新函数，根据这个函数的意图来对它命名（以它做什么来命名，而不是以它怎么做命名）
    => 即使你想要提炼的代码非常简单，例如只是一条消息或一个函数调用，只要新函数的名称能够以更好方式昭示代码意图，你也应该提炼它。但如果想不出一个更有意义的名称，就别动。
 - 2. 将提炼出的代码从源函数复制到新建的目标函数中。
 - 3. 仔细检查提炼出的代码，看看其中是否引用了“作用域限于源函数”的变量（包括局部变量和源函数参数）。
 - 4. 检查是否有“仅作用于被提炼代码段”的临时变量。如果有，在目标函数中将它们声明为临时变量。
 - 5. 检查被提炼代码段，看看是否有任何局部变量的值被它改变。如果一个临时变量值被修改了，看看是否可以被提炼代码段处理为一个查询，并将结果赋值给相关变量。如果很难这样做，或如果被修改的变量不止一个，你就不能仅仅将这段代码原封不动地提炼出来。你可能需要先使用Split Temporary Variable（128），然后再尝试提炼。也可以使用Replace Temp with Query（120）将临时变量消灭掉。
 - 6. 将被提炼代码段中需要读取的局部变量，当作参数传给目标函数。
 - 7. 处理完所有局部变量之后，进行编译。
 - 8. 在源函数中，将被提炼代码段替换为对目标函数的调用。
    => 如果你讲任何临时变量移到目标函数中，请检查它们原本的声明式是否在被提炼代码段的外围。如果是，现在你可以删除这些声明式了。
 - 9. 编译，测试。
 */
class ExtractMethod {
    class Demo1 {
        
        var orders = [Order]()
        
        var name = ""
        
        func printBanner() {
            // 打印banner
            print("***********************")
            print("**** Customer Owes ****")
            print("***********************")
        }
        
        func printDetails(outstanding: Double) {
            // 打印详情
            print("name: " + name)
            print("amount" + "\(outstanding)")
        }
        
        func printOwing() {
            var outstanding = 0.0

            printBanner()
            
            for aOrder in orders {
                outstanding += aOrder.getAmount()
            }
            
            printDetails(outstanding: outstanding)
        }
        
        class Order {
            func getAmount() -> Double {
                return 0.0
            }
        }
    }
    
    /**
     这里只讨论临时变量的问题。如果你发现源函数的参数被赋值，应该马上使用Remove Assignments to Parameters（131）
     1. 这个变量只在被提炼代码段中使用。
        => 将这个临时变量的声明移到被提炼代码段中。然后一起提炼出去。
     2. 被提炼代码段之外的代码也使用了这个变量。
        2.1 如果这个变量在被提炼代码段之后未再使用，你只需要直接在目标函数中修改它就可以了。
        2.2 如果被提炼代码段之后的代码还使用了这个变量，你就需要让目标函数返回该变量改变后的值。
     */
    class Demo2 {
        
        var orders = [Order]()
        
        var name = ""
        
        func printBanner() {
            // 打印banner
            print("***********************")
            print("**** Customer Owes ****")
            print("***********************")
        }
        
        func printDetails(outstanding: Double) {
            // 打印详情
            print("name: " + name)
            print("amount" + "\(outstanding)")
        }
        
        func getoutstanding() -> Double {
            var result = 0.0
            for aOrder in orders {
                result += aOrder.getAmount()
            }
            return result
        }
        
        func printOwing() {
            let outstanding = getoutstanding()
            printBanner()
            printDetails(outstanding: outstanding)
        }
        
        class Order {
            func getAmount() -> Double {
                return 0.0
            }
        }
    }
}
