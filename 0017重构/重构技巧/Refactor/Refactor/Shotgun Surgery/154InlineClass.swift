//
//  154InlineClass.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/26.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 在目标类身上声明源类的public协议，并将其中所有函数委托至源类。
 - 修改所有源类引用点，改而引用目标类。
 - 编译，测试。
 - 运用Move Method 和 Move Field，将源类的特性全部搬移到目标类。
 - 为源类举行一个简单的“丧礼”。

 */
class InlineClass {
    class Person {

//        private var _officeTelephone = TelephoneNumber()

        private var _areaCode: String = ""

        private var _number: String = ""

        private var _name: String = ""

        public func getName() -> String {
            return _name
        }

        public func getTelephoneNumber() -> String {
            return "(" + _areaCode + ")" + _number
        }

//        public func getOffieTelephone() -> TelephoneNumber {
//            return _officeTelephone
//        }

        func getAreaCode() -> String {
            return _areaCode
        }

        func setAreaCode(arg: String) {
            _areaCode = arg
        }

        func getNumber() -> String {
            return _number
        }

        func setNumber(arg: String) {
            _number = arg
        }
    }

    class TelephoneNumber {

//        private var _areaCode: String = ""
//
//        private var _number: String = ""

//        public func getTelephoneNumber() -> String {
//            return "(" + _areaCode + ")" + _number
//        }

//        func getAreaCode() -> String {
//            return _areaCode
//        }
//
//        func setAreaCode(arg: String) {
//            _areaCode = arg
//        }
//
//        func getNumber() -> String {
//            return _number
//        }
//
//        func setNumber(arg: String) {
//            _number = arg
//        }
    }
}
