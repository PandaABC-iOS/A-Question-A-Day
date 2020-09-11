Swift 标准库中有许多 protocols，其中很多看起来貌似很抽象，并且感觉并没有什么卵用，`RawRepresentable` 就是其中之一，也许你平时都没有直接用到它，但事实上，这个协议有着很重要的意义。

## 它是什么

首先我们简单看一下这个东西是用来描述什么问题的，它的定义如下：

```swift
public protocol RawRepresentable {
    associatedtype RawValue
    
    public init?(rawValue: Self.RawValue)

    public var rawValue: Self.RawValue { get }
}
```

简单来说呢，遵循这个协议的类型可以表示另一个类型，并且可以通过 `rawValue` 这个属性得到它表示的值。

## Well, How to Use It?

```swift
struct Directions: OptionSet {
    typealias RawValue = UInt8
    
    var rawValue: UInt8
    
    static let up = Directions(rawValue: 1 << 0)
    static let down = Directions(rawValue: 1 << 1)
    static let left = Directions(rawValue: 1 << 2)
    static let right = Directions(rawValue: 1 << 3)
}
```

由于 `OptionSet` 也是一个协议，而这个协议并没有指定 `RawRepresentable` 中的一个 **associatedtype** `RawValue`，因此我们用第一行的语句指定：我们这个类型表示了一个 `UInt8` 类型。由于协议规定我们需要有个 `rawValue` 属性，所以我们还需要再声明一个 `rawValue` 成员变量。

使用的时候也很方便，我们可以通过 `[.up, .left]` 或者 `.down` 来表示一个 `Direction` 变量，这得益于 Swift 的类型推断和便利的语法。

## One More Thing

是不是觉得好无聊啊，没关系，下面来点来自 Apple Sample Code 的干货。

`UserDefaults` 这个东西相信大家都用过，但是它的存取需要写很长的方法调用，感觉很笨拙。我们为何不用 `subscript` 来改造它呢？

在此之前，我们用一用本文中的主角 —— RawRepresentable。苹果十分不提倡将一些 **Name** 用 hardcode 的方式来表示，不要直接用 `String` 表示一个 asset 名称，不要用 tag 来获取 IB 中拖拽的 view。这些行为十分影响软件的可维护性。所以我们将应用中的 UserDefaults Key 用某种方式来表示：

```swift
struct PreferenceName<Type>: RawRepresentable {
    typealias RawValue = String
    
    var rawValue: String
    
    init?(rawValue: PreferenceName.RawValue) {
        self.rawValue = rawValue
    }
}
```

这小段代码很精巧，既通过 `rawValue` 存储了 key，同时通过范型在类型中注入了 value 的类型信息。

下面我们扩展 `UserDefaults` 类

```swift
extension UserDefaults {
    
    subscript(key: PreferenceName<Bool>) -> Bool {
        set { set(newValue, forKey: key.rawValue) }
        get { return bool(forKey: key.rawValue) }
    }
 
    subscript(key: PreferenceName<Int>) -> Int {
        set { set(newValue, forKey: key.rawValue) }
        get { return integer(forKey: key.rawValue) }
    }
    
    subscript(key: PreferenceName<Any>) -> Any {
        set { set(newValue, forKey: key.rawValue) }
        get { return value(forKey: key.rawValue) }
    }
    
}
```

借助范型，我们将 subscript 用不同类型分开，这样存取不同类型的值时就不用去取分方法名称了，是不是很方便呢？

最后，我们写一个结构体来存储所有配置项的 Key：

```swift
struct PreferenceNames {
    
    static let maxCacheSize = PreferenceName<Int>(rawValue: "MaxCacheSize")
    
    static let badgeType = PreferenceName<Int>(rawValue: "BadgeType")
    
    static let backgroundImageURL = PreferenceName<URL>(rawValue: "BackgroundImageURL")
    
}
```

然后使用的时候就这样：

```swift
UserDefaults.standard[PreferenceNames.maxCacheSize] = 30
```