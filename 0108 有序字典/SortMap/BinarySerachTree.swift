//
//  BinarySerachTree.swift
//  Collection
//
//  Created by Song Zhou on 2020/8/5.
//  Copyright © 2020 songzhou. All rights reserved.
//

import Foundation

public enum BinaryTree<Element: Comparable> {
    case empty
    indirect case node(Element, BinaryTree, BinaryTree)
}

extension BinaryTree: CustomStringConvertible {
    func diagram(_ top: String, _ root: String, _ bottom: String) -> String {
        switch self {
        case .empty:
            return root + "•\n"
        case let .node(value, .empty, .empty):
            return root + "\(value)\n"
        case let .node(value, left, right):
            return right.diagram(top + "    ", top + "┌───", top + "│   ")
                + root + "\(value)\n"
                + left.diagram(bottom + "│   ", bottom + "└───", bottom + "    ")
        }
    }
    
    public var description: String {
        return self.diagram("", "", "")
    }
}

public extension BinaryTree {
    func contains(_ element: Element) -> Bool {
        switch self {
        case .empty:
            return false
        case .node(element, _, _):
            return true
        case let .node(value, left, _) where value > element:
            return left.contains(element)
        case let .node(_, _, right):
            return right.contains(element)
        }
    }
}

public extension BinaryTree {
    func forEach(_ body: (Element) -> Void) {
        switch self {
        case .empty:
            break
        case let .node(value, left, right):
            left.forEach(body)
            body(value)
            right.forEach(body)
        }
    }
}

public extension BinaryTree {
    @discardableResult
    mutating func insert(_ element: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        let (tree, old) = _inserting(element)

        self = tree
        return (old == nil, old ?? element)
    }
    
    func _inserting(_ element: Element) -> (tree: BinaryTree, old: Element?) {
        switch self {
            
        case .empty:
            return (.node(element, .empty, .empty), nil)
            
        case let .node(value, _, _) where value == element:
            return (self, value)
            
        case let .node(value, left, right) where value > element:
            let (l, old) = left._inserting(element)
            
            if let old = old { return (self, old) }
            
            return (.node(value, l, right), nil)
        case let .node(value, left, right):
            let (r, old) = right._inserting(element)
            
            if let old = old { return (self, old) }
            
            return (.node(value, left, r), nil)
        }
    }
}
