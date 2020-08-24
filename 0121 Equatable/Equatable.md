很显然在 Swift 的世界里，并不是所有东西都可以用 `==` 进行判断，例如:

```swift
struct Man {
   var name: String
   var height: Double
}
let man1 = Man(name: "张思琦", height: 180.5)
let man2 = Man(name: "宋旭陶", height: 180.5)
if man1 == man2 {
}
```

![img](https://picb.zhimg.com/80/v2-541766236efebce23565dae274d089ca_1440w.jpeg)

如果真的想要使用 `==` 比较，也并没有那么难，只需要让类型遵循 Equatable 的 protocol 并定义 `static function ==` ，例如刚才的例子，我们完善一下 Man 的定义

```swift
struct Man: Equatable {
   var name: String
   var height: Double
   static func == (lhs: Man, rhs: Man) -> Bool {
      return lhs.name == rhs.name && lhs.height == rhs.height
   }
}
```

在这个例子中，我们两个人的身高和名字完全相同则两个人完全相等，即用 `==` 进行判断时能够返回 true

