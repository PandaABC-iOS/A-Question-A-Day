# weak strong dance in swift closure

为了避免循环引用，我们经常会在使用闭包时用捕获列表把 self 用 weak 标记，像下面这样

```swift
self.closure1 = { [weak self] in
    guard let self = self else { return }
    print("================closure1 executed \(self)")
}
```

这样没什么问题

但如果闭包里面还有闭包，这个时候还需要在每个闭包里 weak 吗？ 比如下面这样的情况

```swift
self.closure1 = { [weak self] in
    guard let self = self else { return }
    self.closure2 = { str in
        print("================closure2 executed \(str) \(self)")
    }
    print("================closure1 executed \(self)")
}
```

答案是：需要

可能我们以为后续的 self 用的都是 weak 之后的 self ，但闭包捕获对象类型的变量时，会持有这个变量，除非用 weak 标记后，才会将对象放到自动释放池里，出了作用域再将引用计数减1 ，这里第二个闭包会对 self 持有，造成循环引用，尽管已经 weak 一次了，但指向的是同一个对象，还是会造成引用计数加1

所以正确的用法是每个闭包都把 self 标记为 self

```swift
self.closure1 = { [weak self] in
    guard let self = self else { return }
    self.closure2 = { [weak self] str in
        guard let self = self else { return }
        print("================closure2 executed \(str) \(self)")
    }
    print("================closure1 executed \(self)")
}
```

在我们做多个网络请求的时候，很容易碰到这种嵌套闭包的情况，记得每个闭包里用到 self 都要 weak



延伸阅读：https://www.jianshu.com/p/4e6153ea2734