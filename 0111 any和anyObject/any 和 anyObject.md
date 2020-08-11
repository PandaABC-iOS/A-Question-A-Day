`Any` 和 `AnyObject` 是 Swift 中两个妥协的产物，也是很让人迷惑的概念。在 Swift 官方编程指南中指出

> `AnyObject` 可以代表任何 `class` 类型的实例
>
> `Any` 可以表示任意类型，甚至包括方法 (func) 类型

先来说说 `AnyObject` 吧。写过 Objective-C 的读者可能会知道在 Objective-C 中有一个叫做 `id` 的神奇的东西。编译器不会对向声明为 `id` 的变量进行类型检查，它可以表示任意类的实例这样的概念。在 Cocoa 框架中很多地方都使用了 `id` 来进行像参数传递和方法返回这样的工作，这是 Objective-C 动态特性的一种表现。现在的 Swift 最主要的用途依然是使用 Cocoa 框架进行 app 开发，因此为了与 Cocoa 架构协作，将原来 `id` 的概念使用了一个类似的，可以代表任意 `class` 类型的 `AnyObject` 来进行替代。

但是两者其实是有本质区别的。在 Swift 中编译器不仅不会对 `AnyObject` 实例的方法调用做出检查，甚至对于 `AnyObject` 的所有方法调用都会返回 Optional 的结果。这虽然是符合 Objective-C 中的理念的，但是在 Swift 环境下使用起来就非常麻烦，也很危险。应该选择的做法是在使用时先确定 `AnyObject` 真正的类型并进行转换以后再进行调用。

假设原来的某个 API 返回的是一个 `id`，那么在 Swift 中现在就将被映射为 `AnyObject?` (因为 `id` 是可以指向 `nil` 的，所以在这里我们需要一个 Optional 的版本)，虽然我们知道调用来说应该是没问题的，但是我们依然最好这样写：

```
func someMethod() -> AnyObject? {
    // ...

    // 返回一个 AnyObject?，等价于在 Objective-C 中返回一个 id
    return result
}

let anyObject: AnyObject? = SomeClass.someMethod()
if let someInstance = anyObject as? SomeRealClass {
    // ...
    // 这里我们拿到了具体 SomeRealClass 的实例

    someInstance.funcOfSomeRealClass()
}
```

如果我们注意到 `AnyObject` 的定义，可以发现它其实就是一个接口：

```
protocol AnyObject {
}
```

特别之处在于，所有的 `class` 都隐式地实现了这个接口，这也是 `AnyObject` 只适用于 `class` 类型的原因。而在 Swift 中所有的基本类型，包括 `Array` 和 `Dictionary` 这些传统意义上会是 `class` 的东西，统统都是 `struct` 类型，并不能由 `AnyObject` 来表示，于是 Apple 提出了一个更为特殊的 `Any`，除了 `class` 以外，它还可以表示包括 `struct` 和 `enum` 在内的所有类型。

为了深入理解，举个很有意思的例子。为了实验 `Any` 和 `AnyObject` 的特性，在 Playground 里写如下代码：

```
import UIKit

let swiftInt: Int = 1
let swiftString: String = "miao"

var array: [AnyObject] = []
array.append(swiftInt)
array.append(swiftString)
```

我们在这里声明了一个 `Int` 和一个 `String`，按理说它们都应该只能被 `Any` 代表，而不能被 `AnyObject` 代表的。但是你会发现这段代码是可以编译运行通过的。那是不是说其实 Apple 的编程指南出错了呢？不是这样的，你可以打印一下 `array`，就会发现里面的元素其实已经变成了 `NSNumber` 和 `NSString` 了，这里发生了一个自动的转换。因为我们 `import` 了 `UIKit` (其实这里我们需要的只是 `Foundation`，而在导入 `UIKit` 的时候也会同时将 `Foundation` 导入)，在 Swift 和 Cocoa 中的这几个对应的类型是可以进行自动转换的。因为我们显式地声明了需要 `AnyObject`，编译器认为我们需要的的是 Cocoa 类型而非原生类型，而帮我们进行了自动的转换。

在上面的代码中如果我们把 `import UIKit` 去掉的话，就会得到无法适配 `AnyObject` 的编译错误了。我们需要做的是将声明 `array` 时的 `[AnyObject]` 换成 `[Any]`，就一切正确了。

```
let swiftInt: Int = 1
let swiftString: String = "miao"

var array: [Any] = []
array.append(swiftInt)
array.append(swiftString)
array
```

顺便值得一提的是，只使用 Swift 类型而不转为 Cocoa 类型，对性能的提升是有所帮助的，所以我们应该尽可能地使用原生的类型。

其实说真的，使用 `Any` 和 `AnyObject` 并不是什么令人愉悦的事情，正如开头所说，这都是为妥协而存在的。如果在我们自己的代码里需要大量经常地使用这两者的话，往往意味着代码可能在结构和设计上存在问题，应该及时重新审视。简单来说，我们最好避免依赖和使用这两者，而去尝试明确地指出确定的类型。