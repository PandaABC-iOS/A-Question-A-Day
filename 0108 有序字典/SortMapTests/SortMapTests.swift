//
//  SortMapTests.swift
//  SortMapTests
//
//  Created by songzhou on 2020/8/7.
//  Copyright © 2020 songzhou. All rights reserved.
//

import XCTest
@testable import SortMap

class SortMapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Swift 中字典是非有序的
    func testDictionary() throws {
        var dict = [Int: Any]()
        
        let keys = (1...20).shuffled()

        keys.forEach {
            dict[$0] = $0
        }

        print("keys: \(keys)")
        dict.forEach {
            print($0.key)
        }
    }
    
    /// NSOrderedSet 只能保证插入元素时的顺序
    func testOrderedSet() throws {
        let set = NSMutableOrderedSet()
        
        let array = (1...20).shuffled()

        array.forEach {
            set.add($0)
        }

        let setArray = set.array as! [Int]
        XCTAssert(setArray == array)
        
        print(array)
        print(setArray)
    }

    func testBST() throws {
        let array = Array(2...10)
        
        var bst = BinaryTree.node(1, .empty, .empty)
        
        array.forEach {
            bst.insert($0)
        }
        
        print(bst)
    }
    
    func testBalanceBSTInsert() throws {
        let array = [2,1,3,4,8,6,7,9]
        
        var bst = BinaryTree.node(5, .empty, .empty)
        
        array.forEach {
            bst.insert($0)
        }
        
        print(bst)
    }
    
    func testRedBlackTreeInsert() throws {
         var set = RedBlackTree<Int>.empty
         
         for i in (1 ... 10).shuffled() {
             set.insert(i)
         }
         
         print(set)
     }
}
