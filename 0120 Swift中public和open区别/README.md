## Swift中public和open区别？



这两个都是 Swift 中访问修饰符之一。用于在模块中声明需要对外界暴露的函数。

 区别在于， `public` 修饰的类, 在模块外无法继承, 而 `open` 则可以任意继承，从暴露程度来说, `public < open`



除此之外，还有 internal、private、fileprivate。



其暴露程度，排序如下：

`private < fileprivate < internal < public < open`

