//
//  149ExtractClass.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/20.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 动机：
 一个类应该是一个清楚的抽象，处理一些明确的责任。实际工作中，类会不断成长扩展。随着责任不断增加，这个类会变得过分复杂。很快，你的类就会变成一团乱麻。
 另外一个信号是，如果你发现子类化只影响类的部分特性，或如果你发现某些特性需要以一种方式来子类化，某些特性则需要以另一种方式子类化，这就意味你需要分解原来的类。
 
 做法：
 - 1. 决定如何分解类所负的责任。
 - 2. 建立一个新类，用以表现从旧类中分离出来的责任。
    => 如果旧类剩下的责任与旧类名称不符，为旧类更名。
 - 3. 建立“从旧类访问新类”的连接关系。
    => 有可能需要一个双向连接。但是在真正需要它之前，不要建立“从新类通往旧类”的连接。
 - 4. 对于你想搬移的每一个字段，运用Move Field搬移之。
 - 5. 每次搬移后，编译，测试。
 - 6. 使用Move Method将必要的函数搬移到新类。先搬移较低层次函数，再搬移较高层函数。
 - 7. 每次搬移之后，编译、测试。
 - 8. 检查，精简每个类的接口。
    => 如果你建立起双向连接，检查是否可以将它改为单向连接。
 - 9. 决定是否公开新类。如果你的确需要公开它，就要决定让它成为引用对象还是不可变的值对象
 
 思考：
 第9步，
 */
class ExtractClass {
    
    // 运用步骤1.2.3.4.5
    class Person {
        
        private var officeTelephone = TelephoneNumber()
        
        var name = ""
        
        func getName() -> String {
            return name
        }
        
        func getTelephoneNumber() -> String {
            return officeTelephone.getTelephoneNumber()
        }
        
        func getOfficeAreaCode() -> String {
            return officeTelephone.getAreaCode()
        }
        
        func setOfficeAreaCode(arg: String) {
            officeTelephone.setAreaCode(arg: arg)
        }
        
        func getOfficeNumber() -> String {
            return officeTelephone.getNumber()
        }
        
        func setOfficeNumber(arg: String) {
            officeTelephone.setNumber(arg: arg)
        }
    }
    
    class TelephoneNumber {
        
        func getTelephoneNumber() -> String {
            return "(" + areaCode + ")" + number
        }
        
        var number = ""
        
        var areaCode = ""
        
        func getAreaCode() -> String {
            return areaCode
        }
        
        func setAreaCode(arg: String) {
            areaCode = arg
        }
        
        func getNumber() -> String {
            return number
        }
        
        func setNumber(arg: String) {
            number = arg
        }
    }
}
