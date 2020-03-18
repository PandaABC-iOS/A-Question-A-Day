//
//  175ReplaceDataValueWithObject.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/26.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 为待替换数值新建一个类，在其中声明一个final字段，其类型和源类中的待替换数值类型一样。然后在新类中加入这个字段的取值函数，再加上一个接受此字段为参数的构造函数。
 - 编译。
 - 将源类中的待替换数值字段的类型改为前面新建的类。
 - 修改源类中该字段的取值函数，令它调用新类的取值函数。
 - 如果源类构造函数中用到这个待替换字段（多半是赋值动作），我们就修改构造函数，令它改用新类的构造函数来对字段进行赋值动作。
 - 修改源类中待替换字段的设值函数，令它为新类创建一个实例。
 - 编译，测试。
 - 现在，你有可能需要对新类使用Change Value To Reference。
 */
class ReplaceDataValueWithObject {

}
