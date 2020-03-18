//
//  232ReplaceSubclassWithFields.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/27.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 对所有子类使用ReplaceConstructorWithFactoryMethod
 - 如果有任何代码直接引用子类，令它改而引用超类。
 - 针对每个常量函数，在超类中声明一个final字段。
 - 为超类声明一个protected构造函数，用以初始化这些新增字段。
 - 新建或修改子类构造函数，使它调用超类的新增构造函数。
 - 编译，测试。
 - 在超类中实现所有常量函数，令它们返回相应字段值，然后将该函数从子类中移除。
 - 每删除一个常量函数，编译并测试。
 - 子类中所有的常量函数都被删除后，使用Inline Method 将子类构造函数内联到超类的工厂函数中。
 - 编译，测试。
 - 将子类删掉
 - 编译，测试
 - 重复“内联构造函数、删除子类”过程，直到所有子类都被删除。
 */
class ReplaceSubclassWithFields {

}
