在定义和实现一个类型的时候，Swift 中的一种非常常见，也是非常先进的做法是先定义最简单的类型结构，然后再通过扩展 (extension) 的方式来实现为数众多的接口和各种各样的功能。这种按照特性进行分离的设计理念对于功能的可扩展性的提升很有帮助。虽然在 Objective-C 中我们也可以通过类似的 protocol + category 的形式完成类似的事情，但 Swift 相比于原来的方式更加简单快捷。

`CustomStringConvertible` 和 `CustomDebugStringConvertible` 这两个接口就是很好的例子。对于一个普通的对象，我们在调用 `print` 对其进行打印时只能打印出它的类型：

```swift
class MyClass {
    var num: Int
    init() {
        num = 1
    }
}

let obj = MyClass()
print(obj)
// MyClass
```

对于 struct 来说，情况好一些。打印一个 struct 实例的话，会列举出它所有成员的名字和值：比如我们有一个日历应用存储了一些会议预约，model 类型包括会议的地点，位置和参与者的名字：

```swift
struct Meeting {
    var date: NSDate
    var place: String
    var attendeeName: String
}

let meeting = Meeting(date: NSDate(timeIntervalSinceNow: 86400),
                     place: "会议室B1",
              attendeeName: "小明")
print(meeting)
// 输出:
// Meeting(date: 2015-08-10 03:15:55 +0000, 
//          place: "会议室B1", attendeeName: "小明")
```

直接这样进行输出对了解对象的信息很有帮助，但也会存在问题。首先如果实例很复杂，我们将很难在其中找到想要的结果；其次，对于 `class` 的对象来说，只能得到类型名字，可以说是毫无帮助。我们可以对输出进行一些修饰，让它看起来好一些，比如使用格式化输出的方式：

```swift
print("于 \(meeting.date) 在 \(meeting.place) 与 \(meeting.attendeeName) 进行会议")
// 输出:
// 于 2014-08-25 11:05:28 +0000 在 会议室B1 与 小明 进行会议
```

但是如果每次输出的时候，我们都去写这么一大串东西的话，显然是不可接受的。正确的做法应该是使用 `CustomStringConvertible` 接口，这个接口定义了将该类型实例输出时所用的字符串。相对于直接在原来的类型定义中进行更改，我们更应该倾向于使用一个 `extension`，这样不会使原来的核心部分的代码变乱变脏，是一种很好的代码组织的形式：

```swift
extension Meeting: CustomStringConvertible {
    var description: String {
        return "于 \(self.date) 在 \(self.place) 与 \(self.attendeeName) 进行会议"
    }
}
```

这样，再当我们使用 `print` 时，就不再需要去做格式化，而是简单地将实例进行打印就可以了：

```swift
print(meeting)
// 输出:
// 于 2015-08-10 03:33:34 +0000 在 会议室B1 与 小明 进行会议
```

`CustomDebugStringConvertible` 与 `CustomStringConvertible` 的作用很类似，但是仅发生在调试中使用 debugger 来进行打印的时候的输出。对于实现了 `CustomDebugStringConvertible` 接口的类型，我们可以在给 `meeting` 赋值后设置断点并在控制台使用类似 `po meeting` 的命令进行打印，控制台输出将为 `CustomDebugStringConvertible` 中定义的 `debugDescription` 返回的字符串。