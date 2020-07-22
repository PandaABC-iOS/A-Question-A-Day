//
//  SortedArrayTest.swift
//  CollectionTests
//
//  Created by songzhou on 2020/7/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import XCTest
@testable import Collection

class SortedArrayTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        var set = SortedArray<Int>()
        
        for i in (0..<22).shuffled() {
            set.insert(2*i)
        }
        

        XCTAssertTrue(set.contains(42))
        XCTAssertFalse(set.contains(13))
        
        print(set)
    }

    func testCopyOnWite() throws {
        var set = SortedArray<Int>()
        
        let copy = set

        set.insert(13)

        XCTAssertTrue(set.contains(13))
        XCTAssertFalse(copy.contains(13))
    }
    

}
