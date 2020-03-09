Swift 的方法调用比较复杂，有静态调用，动态调用（1. V-Table 派发，2. Objective-C 方法派发）。
涉及到协议的时候，又会有另一种基于 Table 的派发，叫做 W-Table。在编译器优化的时候，动态方法可能会变成静态方法来提升效率。

我们可以通过编译到 SIL 来查看，SIL 是 Swift 的中间语言。

```swift
# 用 swiftc 生成 SIL，不开启编译优化
swiftc -emit-silgen Global.swift -Onone > Global.sil
```

Global.sil 中有 [function_ref](https://github.com/apple/swift/blob/master/docs/SIL.rst#function-ref) ，根据 SIL，这是静态调用。


# 说明
V-Table

Virtual Table 是一种动态派发的实现，关于其中的原理介绍，可以看这一篇讲 [C++ Virtual Table](https://www.learncpp.com/cpp-tutorial/125-the-virtual-table/) 的文章。

W-Table

Protocol witness table，是管理 Protocol Type 的方法分派表，每当一个类别遵循某个协议，就会生成一个 witness table。


Message 是 Objective-C Runtime 的消息派发

# 全局函数

全局函数我们都知道是静态调用，可以用 SIL 来验证一下

```swift
swiftc -emit-silgen Global.swift -Onone > Global.sil
```

可以看到是 `function_ref`，所以是静态调用。

# Struct

```swift

struct Foo {
	func bar() {}
}

extension Foo {
	func baz() {}
}
```

都是静态调用

# Class

```swift
class Foo {
	/// V-Table
	func bar() {}
	
	/// Static
	final
	func baz() {}
}

extension Foo {
	/// Static
	func bar() {}
	
	/// Static
	final
	func baz() {}
}
```

Swift class extension 方法都是 Static

# NSObject Class

```swift
class Foo: NSObject {
	/// V-Table
	func bar() {}
	
	/// Static
	final
	func barFinal() {}
	
	/// V-Table
	@objc
	func barObjc() {}
	
	/// Message
	@objc dynamic
	func barDynamic() {}
	
	/// Static
	@objc final
	func barObjcFinal() {}
}
```

标记为 `dynamic` 就会走 Message 派发，`@objc` 只是暴露方法到 Objectiv-C

```swift
extension Foo {
	/// Static
	func bar_() {}
	
	/// Static
	final
	func barFinal_() {}
	
	/// Message
	@objc
	func barObjc_() {}
	
	/// Message
	@objc dynamic
	func barDynamic() {}
	
	/// Static
	@objc final
	func barObjcFinal() {}
}
```
这里标记 `@objc` 后就走 Message 派发了。

# Protocol

```swift
import Foundation

protocol Bar {
	func bar()
}

struct FooStruct: Bar {
	func bar() {}
}

class FooClass: Bar {
	func bar() {}
}

class FooObjectClass: NSObject, Bar {
	func bar() {}
}


/// Static
let o1 = FooStruct()
o1.bar()

/// V-Table
let o2 = FooClass()
o2.bar()

/// V-Table
let o3 = FooObjectClass()
o2.bar()

/// W-Table
let o4 = o1 as Pet
o4.bar()

/// W-Table
let o5 = o2 as Pet
o5.bar()

/// W-Table
let o6 = o3 as Pet
o6.bar()
```

标记为 `@objc` 的协议方法，走 Message 派发。

# 参考
- [Swift 中的方法调用（Method Dispatch）（一） - 概述] (https://x140yu.github.io/2018-04-08-method-dispatch-in-swift-1/)
