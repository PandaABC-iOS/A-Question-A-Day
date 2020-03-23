//
//  139SubstituteAlgorithm.swift
//  Refactor
//
//  Created by 张津铭 on 2020/2/20.
//  Copyright © 2020 Hangzhou. All rights reserved.
//

import Foundation

/**
 做法：
 - 1. 准备好另一个算法，让它通过编译。
 - 2. 针对现有测试，执行上述新的算法。如果结果与原本结果相同，重构结束。
 - 3. 如果测试结果不同于原先，在测试和调试过程中，以旧算法为比较参考标准。
    => 对于每个测试用例，分别以新旧两种算法执行，并观察两者结果是否相同。这可以帮助你看到哪一个测试用例出现麻烦，以及出现了怎样的麻烦。
 */

class SubstituteAlgorithm {
    func foundPerson(people: [String]) -> String {
        let candidates = ["Don", "John", "Kent"]
        for i in people.indices {
            if candidates.contains(people[i]) {
                return people[i]
            }
        }
        return ""
    }
}
