//
//  189DuplicateObservedData.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/26.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation
import UIKit

/**
 动机：
 一个分层良好的系统，应该将处理用户界面和处理业务逻辑的代码分开。之所以这样做，原因有以下几点：
 （1）你可能需要使用不同的用户界面来表现相同的业务逻辑，如果同时承担两种责任，用户界面会变得过分复杂；
 （2）与GUI隔离之后，领域对象的维护和演化都会更容易，你甚至可以让不同的开发者负责不同部分的开发。

 做法：
 - 1. 修改展现类，使其成为领域类的Observer。
    => 如果尚未有领域类，就建立一个。
    => 如果没有“从展现类到领域类”的关联，就将领域类保存于展现类的一个字段中。
 - 2. 针对GUI类中的领域数据，使用Self Encapsulate Field（171）。
 - 3. 编译，测试。
 - 4. 在事件处理函数中调用设值函数，直接更新GUI组件。
    => 在事件处理函数中放一个设值函数，利用它将GUI组件更新为领域数据的当前值。当然这其实没有必要，你只不过是拿它的值设定它自己。但是这样使用设值函数，便是允许其中的任何动作得以于日后被执行起来，这是这一步骤的意义所在。
    => 进行这个改变时，对于组件，不要使用取值函数，应该直接取用，因为稍后我们将修改取值函数，使其从领域对象取值。设值函数也将做类似修改。
    => 确保测试代码能够触发新添加的事件处理机制。
 - 5. 编译，测试。
 - 6. 在领域类中定义数据及其相关访问函数。
    => 确保领域类中的设值函数能够触发Observer模式的通报机制。
    => 对于被观察的数据，在领域类中使用与展现类所用的相同类型来保存。后续重构中你可以自由改变这个数据类型。
 - 7. 修改展现类中的访问函数，将它们的操作对象改为领域对象。
 - 8. 修改Observer的update()，使其从相应的领域对象中将所需数据复制给GUI组件。
 - 9. 编译，测试。

 */
class DuplicateObservedData {
    class IntervalWindow: UIView, UITextFieldDelegate {
        
        var startField: UITextField = UITextField()
        
        var endField: UITextField = UITextField()
        
        var lengthField: UITextField = UITextField()
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == startField {
                startFieldFocusLost()
            } else if textField == endField {
                endFieldFocusLost()
            } else if textField == lengthField {
                lengthFieldFocusLost()
            }
        }
        
        func startFieldFocusLost() {
            if isNotInteger(string: startField.text) {
                startField.text = "0"
            }
            calculateLength()
        }
        
        func endFieldFocusLost() {
            if isNotInteger(string: endField.text) {
                endField.text = "0"
            }
            calculateLength()
        }
        
        func lengthFieldFocusLost() {
            if isNotInteger(string: lengthField.text) {
                lengthField.text = "0"
            }
            calculateEnd()
        }
        
        func calculateLength() {
            
            let start = Int(startField.text ?? "")
            let end = Int(endField.text ?? "")
            
            guard let aStart = start, let aEnd = end else {
                return
            }
            
            let length = aEnd - aStart
            lengthField.text = "\(length)"
        }
        
        func calculateEnd() {
            let start = Int(startField.text ?? "")
            let length = Int(lengthField.text ?? "")
            
            guard let aStart = start, let aLength = length else {
                return
            }
            
            let end = aStart + aLength
            endField.text = "\(end)"
        }
        
        func isNotInteger(string: String?) -> Bool {
            guard let string = string else {
                return true
            }
            return Int(string) == nil
        }
    }
}
