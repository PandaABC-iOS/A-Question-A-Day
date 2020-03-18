//
//  157HideDelegate.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/26.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 在服务类上建立客户所需的所有函数，用以隐藏委托关系。

 做法：
 - 对于每一个委托关系中的函数，在服务对象端建立一个简单的委托函数。
 - 调整客户，令它只调用服务对象提供的函数。
 - 每次调整后，编译并测试。
 - 如果将来不再有任何客户需要取用的Delegate，便可移除服务对象中的相关访问函数。
 - 编译，测试。
 */
class HideDelegate {

}
