//
//  345FormTemPlateMethod.swift
//  Refactor
//
//  Created by 张津铭 on 2020/3/14.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 两个函数以相同顺序执行大致相近的操作，但是各操作不完全相同。这种情况下我们可以将执行操作的序列移至超类，并借助多态保证各操作仍得以保持差异性。这样的函数被称为Template Method。
 做法：
 - 1.在各个子类中分解目标函数，使分解后的各个函数要不完全相同，要不完全不同。
 - 2.运用Pull Up Method将各子类内完全相同的函数上移至超类。
 - 3.对于那些完全不同的函数，实施Rename Method，使所有这些函数的签名完全相同。
    => 这将使得原函数变为完全相同，因为它们都执行同样一组函数调用；但各子类会以不同方式响应这些调用。
 - 4.修改上述所有签名后，编译并测试。
 - 5.运用Pull Up Method将所有原函数逐一上移至超类。在超类中将那些代表各种不同操作的函数定义为抽象函数。
 - 6.编译，测试。
 - 7.移除其他子类中的原函数，每删除一个，编译并测试。
 */
class FormTemPlateMethod {
    class Customer {
        
        public var rentals = [Rental]()
        
        func getName() -> String {
            return ""
        }
        
        func getTotalCharge() -> String {
            return ""
        }
        
        func getTotalFrequentRenterPoints() -> String {
            return ""
        }
        
        func statement() -> String {
            return TextStatement().value(aCustomer: self)
        }
        
        func htmlStatement() -> String {
            return HtmlStatement().value(aCustomer: self)
        }
    }
    
    class Rental {
        func getMovie() -> Movie {
            return Movie()
        }
        
        func getCharge() -> String {
            return ""
        }
    }
    
    class Movie {
        func getTitle() -> String {
            return ""
        }
    }
    
    /// 超类
    class Statement {
        func value(aCustomer: Customer) -> String {
            var result = headerString(aCustomer: aCustomer)
            for aRental in aCustomer.rentals {
                result += eachRentalString(aRental: aRental)
            }
            result += footerString(aCustomer: aCustomer)
            return result
        }
        
        func headerString(aCustomer: Customer) -> String {
            return ""
        }
        
        func eachRentalString(aRental: Rental) -> String {
            return ""
        }
        
        func footerString(aCustomer: Customer) -> String {
            return ""
        }
    }
    
    class TextStatement: Statement {
        
        override func headerString(aCustomer: Customer) -> String {
            return "Rental Record for" + aCustomer.getName() + "\n"
        }
        
        override func eachRentalString(aRental: Rental) -> String {
            return "\t" + aRental.getMovie().getTitle() + "\t" + aRental.getCharge() + "\n"
        }
        
        override func footerString(aCustomer: Customer) -> String {
            return "Amount owed is" + aCustomer.getTotalCharge() + "\n" + "You earned" + aCustomer.getTotalFrequentRenterPoints() + " frequent renter points"
        }
    }
    
    class HtmlStatement: Statement {
        
        override func headerString(aCustomer: Customer) -> String {
            return "<H1>Rental for <EM>" + aCustomer.getName() + "</EM></H1><p>\n"
        }
        
        override func eachRentalString(aRental: Rental) -> String {
            return aRental.getMovie().getTitle() + ": " + aRental.getCharge() + "<BR>\n"
        }
        
        override func footerString(aCustomer: Customer) -> String {
            return "<P>You owe <EM>" + aCustomer.getTotalCharge() + "</EM><P>\n" + "On this rental you earned <EM>" + aCustomer.getTotalFrequentRenterPoints() + "</EM> frequent renter points<P>"
        }
    }
}
