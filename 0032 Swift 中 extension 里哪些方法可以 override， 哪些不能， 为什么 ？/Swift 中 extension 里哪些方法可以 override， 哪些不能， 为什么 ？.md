# Swift 中 extension 里哪些方法可以 override， 哪些不能， 为什么 ？

回答这个问题之前，先了解一下 Swift 中的方法调用底层机制。

## OC 类的对象方法调用 (objc_msgSend)

所有OC类中定义的方法函数的实现都隐藏了两个参数：一个是对象本身，一个是对象方法的名称。每次对象方法调用都会至少传递对象和对象方法名称作为开始的两个参数，方法的调用过程都会通过一个被称为消息发送的C函数objc_msgSend来完成。objc_msgSend函数是OC对象方法调用的总引擎，这个函数内部会根据第一个参数中对象所保存的类结构信息以及第二个参数中的方法名来找到最终要调用的方法函数的地址并执行函数调用。这也是OC语言Runtime的实现机制，同时也是OC语言对多态的支持实现

## Swift 类的对象方法调用

Swift语言中对象的方法调用的实现机制和C++语言中对虚函数调用的机制是非常相似的。(需要注意的是我这里所说的调用实现只是在编译链接优化选项开关在关闭的时候是这样的,在优化开关打开时这个结论并不正确)。

Swift语言中类定义的方法可以分为三种：OC类的派生类并且重写了基类的方法、extension中定义的方法、类中定义的常规方法。针对这三种方法定义和实现，系统采用的处理和调用机制是完全不一样的。

### OC类的派生类并且重写了基类的方法 (objc_msgSend)

如果在Swift中的使用了OC类，比如还在使用的UIViewController、UIView等等。并且还重写了基类的方法，比如一定会重写UIViewController的viewDidLoad方法。对于这些类的重写的方法定义信息还是会保存在类的Class结构体中，而在调用上还是采用OC语言的Runtime机制来实现，即通过objc_msgSend来调用。而如果在OC派生类中定义了一个新的方法的话则实现和调用机制就不会再采用OC的Runtime机制来完成了，比如说在UIView的派生类中定义了一个新方法foo，那么这个新方法的调用和实现将与OC的Runtime机制没有任何关系了！它的处理和实现机制会变成我下面要说到的第三种方式。

### extension 中定义的方法 (调用硬编码的函数地址)

如果是在Swift类的extension中定义的方法(重写OC基类的方法除外)。那么针对这个方法的调用总是会在编译时就决定，也就是说在调用这类对象方法时，方法调用指令中的函数地址将会以硬编码的形式存在。在extension中定义的方法无法在运行时做任何的替换和改变！而且方法函数的符号信息都不会保存到类的描述信息中去。

### 类中定义的常规方法 (virtual table)

如果是在Swift中定义的常规方法，方法的调用机制和C++中的虚函数的调用机制是非常相似的。Swift为每个类都建立了一个被称之为虚表的数组结构，这个数组会保存着类中所有定义的常规成员方法函数的地址。每个Swift类对象实例的内存布局中的第一个数据成员和OC对象相似，保存有一个类似isa的数据成员。isa中保存着Swift类的描述信息。对于Swift类的类描述结构苹果并未公开(也许有我并不知道)，类的虚函数表保存在类描述结构的第0x50个字节的偏移处，每个虚表条目中保存着一个常规方法的函数地址指针。每一个对象方法调用的源代码在编译时就会转化为从虚表中取对应偏移位置的函数地址来实现间接的函数调用。

## 结论

由于 extension 中定义的方法(重写OC基类的方法除外)是通过直接调用硬编码的函数地址完成调用的，无法实现多态，所以这类方法不能重写。

override normal func of swift is not allowed in extension

![1](https://tva1.sinaimg.cn/large/007S8ZIlly1gdulyas4zoj31q20j8428.jpg)

override func of swift that is defined in extension is not allowed

![2](https://tva1.sinaimg.cn/large/007S8ZIlly1gdulyeddtcj31pm0hggog.jpg)

override func marked as objc dynamic is allowed

![3](https://tva1.sinaimg.cn/large/007S8ZIlly1gdulyimrpyj31pi0hw0vh.jpg)

override func in swift

![4](https://tva1.sinaimg.cn/large/007S8ZIlly1gdulymvjqbj31nc0ew0vi.jpg)

## 延伸

### Extensions of generic classes cannot contain '@objc' members

泛型类的 extension 中不能包含 @objc 的方法

![5](https://tva1.sinaimg.cn/large/007S8ZIlly1gdulysy7mej31qi0h4n23.jpg)

```swift
//// ✅ 泛型类遵循 @objc 协议不能写在 extension 中
@objc protocol Type4: AnyObject {
    @objc optional func test1()
}

class AClass7<T: UIView>: Type4 {
    func test1() {}
}

// 普通的类或泛型类遵循 非 @objc 协议
// ✅
protocol Type1 {
    func test1()
}

class AClass4<T: UIView> {

}

extension AClass4: Type1 {
    func test1() {}
}

// 普通类遵循 @objc 协议
// ✅
@objc protocol Type2: AnyObject {
    @objc optional func test1()
}

class AClass5 {

}

extension AClass5: Type2 {
    func test1() {}
}
```

这个关于协议的实现我们下次分享再聊...

[Swift Runtime 浅析](https://mp.weixin.qq.com/s/qPlg716RqtiT2PK_WqtBZQ)

