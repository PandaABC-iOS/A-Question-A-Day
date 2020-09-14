# Optional Protocol

## 1. protocol: NSObjectProtocol + protocol extension

大部分情况，我们为了实现一个可选协议，会给协议提供一个默认实现，但是当存在继承关系时，程序运行和我们预期的会有些偏差

```swift
protocol TestType: NSObjectProtocol {
    func test1()
}

extension TestType {
    func test1() {
        print("================protocol default test1")
    }
}

class SuperClass: NSObject {
    weak var delegate: TestType?

    func testCall() {
        delegate?.test1()
    }
}

extension SuperClass: TestType {
//    func test1() {
//        print("================super test1")
//    }
}

class SubClass: SuperClass {

}

extension SubClass {
    func test1() {
        print("================subclass test1")
    }
}
```

这个场景下，父类遵守了 TestType 协议，但没有实现，子类实现协议方法，我们看看调用会怎样

```swift
let cc = SubClass()
cc.delegate = cc
cc.testCall()

//================protocol default test1
```

可以**看到代理设置为子类时，并没有调子类的实现，而是调了默认实现**

其实这个场景很容易出现，比如自己写了一个 Webview 基类，然后定义了一个 WebviewDelegate , 里面实现了部分代理调用，当子类化 Webview 时，父类没实现的代理方法最后走的是默认实现，造成子类代理方法没调用

但是如果父类实现了协议方法，子类调用是正确的，如果子类要在 extension 重写父类的协议方法，协议需要标记为 @objc

## 2. @objc protocol + protocol extension

这里我们吧 TestType 标记为 @objc ，然后父类、子类都实现协议方法，可以发现调用都是符合预期的

```swift
@objc protocol TestType: NSObjectProtocol {
    func test1()
//    func test2()
}

extension TestType {
    func test1() {
        print("================protocol default test1")
    }

//    func test2() {
//        print("================protocol default test2")
//    }
}

class SuperClass: NSObject {
    weak var delegate: TestType?

    func testCall() {
        delegate?.test1()
    }
}

extension SuperClass: TestType {
    func test1() {
        print("================super test1")
    }

//    func test2() {
//        print("================super test2")
//    }
}

class SubClass: SuperClass {

}

extension SubClass {
    override func test1() {
        print("================subclass test1")
    }
}

let cc = SubClass()
cc.delegate = cc
cc.testCall()
//================subclass test1
```

貌似这样就可以了，其实还有一个问题，当协议被标记为 @objc , 那么遵守这个协议就需要实现所有方法，即使协议的 extension 已经有默认实现

```swift
@objc protocol TestType: NSObjectProtocol {
    @objc func test1()
    @objc func test2()
}

extension TestType {
    func test1() {
        print("================protocol default test1")
    }

    func test2() {
        print("================protocol default test2")
    }
}

class SuperClass: NSObject {
    weak var delegate: TestType?

    func testCall() {
        delegate?.test1()
    }
}

extension SuperClass: TestType { //Non-'@objc' method 'test2()' does not satisfy requirement of '@objc' protocol 'TestType'
    func test1() {
        print("================super test1")
    }

//    func test2() {
//        print("================super test2")
//    }
}

class SubClass: SuperClass {

}

extension SubClass {
    override func test1() {
        print("================subclass test1")
    }
}
```

编译器报错 `Non-'@objc' method 'test2()' does not satisfy requirement of '@objc' protocol 'TestType'` 

如果父类实现 test2 方法，报错消失，这样就失去可选协议的作用了

## 3. @objc protocol + @objc optional func

```swift
@objc protocol TestType: NSObjectProtocol {
    @objc optional func test1()
    @objc optional func test2()
}

class SuperClass: NSObject {
    weak var delegate: TestType?

    func testCall() {
        delegate?.test2?()
    }
}

extension SuperClass: TestType {
    func test1() {
        print("================super test1")
    }
}

class SubClass: SuperClass {

}

extension SubClass {
    func test2() {
        print("================subclass test2")
    }
}
```

最后推荐 @objc protocol + @objc optional func 这种写法，不管是子类重写，还是子类实现父类没实现的协议方法，调用都是符合预期的，写法也简洁
