as, as?, as! 区别

# as
`as` 是在编译期间进行的操作。

下面两行的行为是一样的

```swift
let x = 4 as Double
let x: Double = 4
```

在 pattern match 时，as 是运行时行为。

```swift
let value: Any = …
	switch value {
	case let i as Int: …
	case let s as String: …
}
```

# as? as!
as? as! 是运行时行为，两者是一样的操作。

等价于：

```swift
x as! Y
(x as? Y)!
```