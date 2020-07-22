//
//  SortedSet.swift
//  Collection
//
//  Created by songzhou on 2020/7/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

public protocol SortedSet: BidirectionalCollection, CustomStringConvertible where Element: Comparable {
    init()
    func contains(_ element: Element) -> Bool
    mutating func insert(_ newElement: Element) -> (inserted: Bool, memberAfterInsert: Element)
}

extension SortedSet {
    public var description: String {
        let contents = self.lazy.map { "\($0)" }.joined(separator: ", ")
        
        return "[\(contents)]"
    }
}
