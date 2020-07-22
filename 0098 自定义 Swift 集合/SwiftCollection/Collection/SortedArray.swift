//
//  SortedArray.swift
//  Collection
//
//  Created by songzhou on 2020/7/20.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

public struct SortedArray<Element: Comparable>: SortedSet {
    
    public init() {}
    
    fileprivate var storage: [Element] = []
}


extension SortedArray {
    public func sorted() -> [Element] {
        return storage
    }
}

extension SortedArray {
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.forEach(body)
    }
}

extension SortedArray {
    public func contains(_ element: Element) -> Bool {
        let index = self.index(for: element)
        
        return index < count && storage[index] == element
    }
}

extension SortedArray {
    @discardableResult
    public mutating func insert(_ newElement: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let index = self.index(for: newElement)
        
        if index < count && storage[index] == newElement {
            return (false, storage[index])
        }
        
        storage.insert(newElement, at: index)
        
        return (true, newElement)
    }
}

extension SortedArray {
    public func index(of element: Element) -> Int? {
        let index = self.index(for: element)
        
        guard index < count, storage[index] == element else { return nil }
        
        return index
    }
}

extension SortedArray {
    /// 二分查找
    /// 如果大于任何一个元素，返回 storage.count
    /// 如果小于任何一个元素，返回 0
    func index(for element: Element) -> Int {
        var start = 0
        var end = storage.count
        
        while start < end {
            let middle = start+(end-start)/2
            
            if element > storage[middle] {
                start = middle+1
            } else {
                end = middle
            }
        }
        
        return start
    }
}

extension SortedArray: RandomAccessCollection {
    public typealias indices = CountableRange<Int>
    
    public var startIndex: Int { return storage.startIndex }
    public var endIndex: Int { return storage.endIndex }
    

    public subscript(position: Int) -> Element {
        return storage[position]
    }
}
