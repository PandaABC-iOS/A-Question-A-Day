//
//  218ReplaceTypeCodeWithClass.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/25.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation
/**
 动机：
 只有当类型码是纯粹数据时，你才能以类来取代它
 做法：
 为类型码建立一个类
    这个类需要一个用以记录类型码的字段，其类型应该和类型码相同，并应该有对应的取值函数。此外还应该用一组静态变量保存允许被创建的实例，并以一个静态函数根据原本的类型码返回合适的实例。
 修改源类实现，让它使用上述新建的类
    维持原先以类型码为基础的函数接口，但改变静态字段，以新建的类产生代码。然后，修改类型码相关函数，让它们也从新建的类中获取类型码。
 编译，测试。
 对源类中每一个使用类型码的函数，相应建立一个函数，让新函数使用新建的类。
 逐一修改源类用户，让它们使用新接口。
 每修改一个用户，编译并测试。
 删除使用类型码的旧接口，并删除保存旧类型码的静态变量。
 编译，测试。

 */

class ReplaceTypeCodeWithClass {
    class Person {
//        static let O = BloodGroup.O.getCode()
//        static let A = BloodGroup.A.getCode()
//        static let B = BloodGroup.B.getCode()
//        static let AB = BloodGroup.AB.getCode()

        private var _bloodGroup: BloodGroup = .O
        private var bloodGroup: Int = 0

//        init(bloodGroup: Int) {
//            self.bloodGroup = bloodGroup
//        }
//
//        func setBloodGroup(arg: Int) {
//            _bloodGroup = BloodGroup.code(arg: arg)
//        }
//
//        func getBloodGroupCode() -> Int {
//            return _bloodGroup.getCode()
//        }

        init(bloodGroup: BloodGroup) {
            self._bloodGroup = bloodGroup
        }

        func getBloodGroup() -> BloodGroup {
            return _bloodGroup
        }

        func setBloodGroup(arg: BloodGroup) {
            _bloodGroup = arg
        }
    }

    class BloodGroup {

        static let O = BloodGroup(0)
        static let A = BloodGroup(1)
        static let B = BloodGroup(2)
        static let AB = BloodGroup(3)

        private static var values = [O, A, B, AB]
        private var code: Int

        private init(_ code: Int) {
            self.code = code
        }

        private func getCode() -> Int {
            return code
        }

        private static func code(arg: Int) -> BloodGroup {
            return values[arg]
        }
    }
}
