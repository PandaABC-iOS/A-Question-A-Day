//
//  330ExtractSubclass.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/15.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 类中的某些特性只被某些实例用到，新建一个子类，将上面所说的那一部分特性移到子类中。
 Extract Class 是 Extract Subclass之外的另一种选择，两者之间的抉择其实就是委托和继承之间的抉择。
 Extract Subclass，只能用以表现一组变化。如果希望一个类以几种不同的方式变化，就必须使用委托。
 
 做法：
 - 1. 为源类定义一个新的子类。
 - 2. 为这个新的子类提供构造函数。
    => 简单的做法是：让子类构造函数接受与超类构造函数相同的参数，并通过super调用超类构造函数。
    => 如果你希望对用户隐藏子类的存在，可使用Replace Constructor with Factory Method（304）
 - 3. 找出调用超类构造函数的所有地点。如果它们需要的是新建的子类，令它们改而调用新构造函数。
    => 如果子类构造函数需要的参数和超类构造函数的参数不同，可以使用Rename Method修改其参数列。如果子类构造函数不需要超类构造函数的某些参数，可以使用Rename Method将它们去除。
    => 如果不再需要直接创建超类的实例，就将超类声明为抽象类。
 - 4. 逐一使用Push Down Method 和 Push Down Field将源类的特性移到子类去。
    => 和Extract Class 不同的是，先处理函数再处理数据，通常会简单一些。
    => 当一个public函数被下移到子类后，你可能需要重新定义该函数的调用端的局部变量或参数类型，让它们改而调用子类中的新函数。
    如果忘记进行这一步骤，编译器会提醒你。
 - 5. 找到所有这样的字段：它们所传达的信息如今可由继承体系自身传达（这一类字段通常是bool变量或类型码）。以Self Encapsulate Field 避免直接使用这些字段，然后将它们的取值函数替换为多态常量函数。所有使用这些字段的地方都应该以Replace Conditional with Polymorphism重构。
    => 任何函数如果位于源类之外，而又使用了上述字段的访问函数，考虑以Move Method将它移到源类中，然后再使用Replace Conditional with Polymorphism。
 - 6. 每次下移之后，编译并测试。
 */
class ExtractSubclass {
    
    func test() {
//        let j2 = JobItem(unitPrice: 10, quantity: 15)
    }
    
    class JobItem {
        
        private var quantity: Int
         
        fileprivate init(quantity: Int) {
            self.quantity = quantity
        }
        
        func getTotalPrice() -> Int {
            return getUnitPrice() * quantity
        }
        
        func getUnitPrice() -> Int {
            return 0
        }
        
        func getQuantity() -> Int {
            return quantity
        }
        
        func isLabor() -> Bool {
            return false
        }
    }
    
    class Employee {
        
        private var rate: Int
        
        init(rate: Int) {
            self.rate = rate
        }
        
        func getRate() -> Int {
            return rate
        }
    }
    
    class LaborItem: JobItem {
        
        var employee: Employee
        
        override func isLabor() -> Bool {
            return true
        }
        
        override func getUnitPrice() -> Int {
            return employee.getRate()
        }
        
        init(quantity: Int, employee: Employee) {
            self.employee = employee
            super.init(quantity: quantity)
        }
        
        func getEmployee() -> Employee {
            return employee
        }
    }
    
    class PartsItem: JobItem {

        var unitPrice: Int
        
        override func getUnitPrice() -> Int {
            return unitPrice
        }
        
        init(unitPrice: Int, quantity: Int) {
            self.unitPrice = unitPrice
            super.init(quantity: quantity)
        }
    }
}
