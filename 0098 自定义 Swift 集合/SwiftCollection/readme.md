如何实现自定义 Swift 集合类型

# 有序数组
我们实现一个有序的数组集合，叫做 SortedArray。

内部用数组实现：
```swift
public struct SortedArray<Element: Comparable>: SortedSet {
    
    public init() {}
    
    fileprivate var storage: [Element] = []
}
```

## 查找
二分查找指定元素

```swift
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
```

## 插入操作 
```swift
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
```
##  下标访问

```swift
extension SortedArray: RandomAccessCollection {
    public typealias indices = CountableRange<Int>
    
    public var startIndex: Int { return storage.startIndex }
    public var endIndex: Int { return storage.endIndex }
    

    public subscript(position: Int) -> Element {
        return storage[position]
    }
}
```
