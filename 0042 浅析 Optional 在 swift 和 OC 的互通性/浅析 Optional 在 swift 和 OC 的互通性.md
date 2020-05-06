# 浅析 Optional 在 Swift 和 OC 的互通性

## 混编的一个不寻常的case

首先我们来看一个场景，当 OC 和 Swift 混编的时候，假设我们有如下的一个 OC 类

```objc
@interface SomeThing : NSObject
@property (nonatomic,nonnull) NSScrollView *scrollView;
@end

@implementation SomeThing
@end
```

可以注意到在类的实现里并没有实现 scrollView , 但是属性被标记为 nonnull , 假设我们在 swift 文件里用这个类

```swift
let thing: SomeThing = SomeThing()
let scrollView: NSScrollView = thing.scrollView
```

Swift 会把 scrollView 推断为非可选，而实际上它是 nil , 这个时候运行会发生什么呢？

大多数人觉得会崩溃，但实际上并没有

接下来我们再深入一点使用这个属性

```swift
let thing: SomeThing = SomeThing()
let scrollView: NSScrollView = thing.scrollView

let contentSize: CGSize = scrollView.contentSize
// ^ this is now a 0 width, 0 height size.

let borderType: NSBorderType = scrollView.borderType

switch borderType {
case .noBorder:
    print("no border") // <- This one prints
case .lineBorder:
    print("line border")
case .bezelBorder:
    print("bezel border")
case .grooveBorder:
    print("groove border")
@unknown default:
    print("unknown border")
}

scrollView.flashScrollers()
// glad we could get that out of the way...
// The scrollers have been flashed. Right?

// getting a nonnull property out...
let clipView: NSClipView = scrollView.contentView
// No problem...
clipView.backgroundColor = NSColor.blue
```

会发现所有的这些代码都正常运行！值类型会返回 0 、 NULL 等这些值，和 OC 时一样



## 检测并做自己的逻辑

在这种 case 下，编译器推断出来的类型和实际类型存在不一致，明明真实值是 nil，但却不是可选值类型，这就会给代码造成一定的风险，至少在语义上会给程序阅读者造成误导

假设现在我们想要避免这种情况，如果是 nil 执行一种逻辑，如果不是 nil 则执行另一种逻辑，怎么做？

问题在于 Swift 此时把这个值推断为非可选值，所以像下面这种代码我们会得到一个警告

```swift
let thing: SomeThing = SomeThing()
guard let scrollView: NSScrollView = thing.scrollView else {
    struct AnonymousError: Error {}
    throw AnonymousError()
}
```

⚠️ `Non-optional expression of type ‘NSSScrollView’ used in a check for optionals`



或者我们想到用比较符来判断，这时编译器也会警告，说条件永远不会成立，但实际运行后，这个条件还是会进入的

```swift
let thing: SomeThing = SomeThing()
let scrollView = thing.scrollView
if scrollView == nil {
    print("The compiler says we won't get here.")
    print("But if we run the program, we do")
}
```



以上的方法都可以检测出 nil 的情况，但都有编译器警告，我们能不能写个函数来判断呢？或许像这样

```swift
func isNil(_ o: Any?) -> Bool {
    switch o {
    case .none:
        return true
    case .some(_):
        return false
    }
}

if isNil(scrollView) {
    print("This doesn't print.")
}
```

我们发现上面的代码没有达到我们的目的，然而当我们把参数类型改为 AnyObject? ，这个方法达到了我们的预期

```swift
func isNil(_ o: AnyObject?) -> Bool {
    switch o {
    case .none:
        return true
    case .some(_):
        return false
    }
}

if isNil(scrollView) {
    print("It works if we make it an AnyObject?")
}
```

我们可以用这个函数去检测这种异常case，做一些提前退出或其他逻辑



### Swift Extensions

假如我们对这个 nil 的类型做一个扩展，这些方法也是可以被调用到的, 这和 OC 有点不一样了， 在 OC 环境下，给 nil 发消息是没有反应的，但 Swift Extension 可以

```swift
extension NSScrollView {
    func doAThing() {
        print("doing it") // <- This will get called
    }
}
```

这些方法也可以返回非0的值，而在 OC 里 会直接返回 0

```swift
extension NSScrollView {
    func oneHundred() -> Float {
        return 100 // <- Now scrollView.oneHundred() can return 100
    }
}
```



### Foundation

 值得一提的是，在 Foundation 框架里的一些类，结果会有些不一样, 比如说 NSCalendar

```objc
@interface CalendarProvider : NSObject
@property (nonatomic, nonnull) NSCalendar *calendar;
@end
```

接下来同样我们在 Swift 中使用这个类

```swift
let calendarProvider = CalendarProvider()
let calendar = calendarProvider.calendar
let weekStartsOn = calendar.firstWeekday
let weekdays: [String] = calendar.weekdaySymbols
```

根据我们上面的经验，这些代码应该也能正常运行

然而，实际上这里会在第二行代码崩溃

这里崩溃的原因并不是因为我们从 calendarProvider 获取了一个意外的值，而是由于 Swift 会自动把 NSCalendar 转换为 Swift 标准库里的 Calendar 类型，这个过程中造成了崩溃，具体我们可以看一下源码

```swift
public static func _unconditionallyBridgeFromObjectiveC(_ source: NSCalendar?) -> Calendar {
    var result: Calendar? = nil
    _forceBridgeFromObjectiveC(source!, result: &result)
    return result!
}
```

可以看到这里有一个强制解包，这就是崩溃的原因， 实际上这里会传进去的参数是Optional<NSCalendar>.some(nil)



### Array

Nonnull NSArray 桥接到 Swift 后行为又有点不一样, 先看例子

```objc
@interface OffendingObject : NSObject
@property (nonnull) NSArray *array;
@end

@implementation OffendingObject

- (NSString *)description
{
    return [NSString stringWithFormat:
    @"%@"
    "array: %@",
    [super description],
            self.array];
}

@end
```

这里我们同样定义一个 nonnull 的 NSArray 但不实现，然后实现了一个 description 方法

接下来我们在 Swift 里用这个类

```swift
let obj = OffendingObject()
print(obj)
print(obj.array)
print(obj)
obj.array.append("thing")
print(obj)
```

先看输出结果

```swift
<OffendingObject: 0x1007b0380>(
    array: (null)
)
[]
<OffendingObject: 0x1007b0380>(
    array: (null)
)
<OffendingObject: 0x1007b0380>(
    array: (
    thing
)
)
```

我们来分析一下这个输出

第 1、2 行代码没什么问题，输出的结果就是一个 nil 代表值 (null)

来到第 3 行代码，奇怪的事情开始了，`print(obj.array)` 这边本来是打印 nil , 但实际上这里打印了一个空数组,看上去我们给 obj.array 存了一个空数组，所以我们再打印一遍 obj， 也就是第 4 行代码

第 4 行代码输出显示 obj.array 还是 null , 看起来越来越奇怪了

来到第 5 、6 行代码，我们往数组里拼加了一个字符串 "thing" , 然后打印 obj , 居然数组里有我们添加的东西了



首先我们要明白的是：NSArray 桥接到 Swift 会变成 Array ，是一个值类型，append 操作其实是生产一个新 Array 再赋值回 obj.array , 这解释了最后一个输出包含 "thing"

剩下的我们再说下第二个输出，那个空数组是怎么来的

和 NSCalendar 一样，NSArray 也有一个桥接到 Array 的函数，它的实现如下：

```swift
static public func _unconditionallyBridgeFromObjectiveC(_ source: NSArray?) -> Array {
    if let object = source {
        var value: Array<Element>?
        _conditionallyBridgeFromObjectiveC(object, result: &value)
        return value!
    } else {
        return Array<Element>()
    }
}
```

这样看就豁然开朗了吧？ 当入参是 nil 时，函数会返回一个空数组



以上这些内容实际开发中可能遇到的情况比较少，而且也不会造成大问题，这里只当作为一个课外知识的补充，了解一下 Optional 在 OC 和 Swift 混编时的部分场景下是怎么表现的



参考链接： [Optionals in Swift Objective-C Interoperability](https://fabiancanas.com/blog/2020/1/9/swift-undefined-behavior.html#cb4-3)





