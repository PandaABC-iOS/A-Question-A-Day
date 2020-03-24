# Swift 中如何在数组中装不同类型的元素



## 场景

开发过程中，可能会遇到这种情况：希望往数组中存一些数据，这些数据可能有相同的一些特征点，但不是一个类型，甚至没有共同特征，只是想对它做统一处理逻辑，但数组又不能存不同类型的数据，这种情况怎么实现我们的需求呢？

### 有共同特征

先说第一类，有共同特征：第一想法是定一个协议，把数据归为一类，就能存进去了，但这样有点不方便，你除了要新写一个协议，把所有你需要统一处理的属性和方法都声明进去，万一要新加属性或方法，你要在协议和遵守者都写一遍

像下面这样

```swift
protocol MyType {
    var aaa: Int? { get set}
    func test1()
}

struct Data1: MyType {
    var aaa: Int?

    func test1() {

    }
}

struct Data2: MyType {
    var aaa: Int?

    func test1() {

    }
}

let datas: [MyType] = [Data1(), Data2()]
for data in datas {
    print("================\(data.aaa)")
    data.test1()
}
```

可以用，但是挺麻烦的， 不是吗？



### 没有共同特征呢？

万一我要装的数据是 [Int Double UIView String] , 这怎么搞 ？？？

我的第一想法是用 Any 装咯，可以是可以，但取数据的时候类型判断就麻烦了，代码会像这样

```swift
let datas: [Any] = [6, 12.5, UISwitch(), "哈哈哈"]
for data in datas {
    if let num = data as? Int {
        print("================ a int \(num)")
    }
    if let num = data as? Double {
        print("================ a Double \(num)")
    }
    if let view = data as? UIView {
        print("================ a UIView \(view)")
    }
    if let str = data as? String {
        print("================ a String \(str)")
    }
}
```

That's suck ! 

可以是可以 ，好恶心有没有



## 试试关联值

其实数组只能装一种类型的数据的事实是不能改变的，从它连续相同大小的内存布局的底层就注定了，我们要做的就是怎么把数据包装成一种类型，既方便取数据时知道这是什么类型，又可以方便的用数据的真实类型？

关联值可以

```swift
enum Container {
    case view(UIView)
    case int(Int)
}

func testContainer() {
    let view = Container.view(UIView())
    let num = Container.int(2)
    let array = [view, num]
    array.forEach { (box) in
        switch box {
        case .view(let view):
            print("================a view \(view)")
        case .int(let num):
            print("================a int \(num)")
        }
    }
}
```

无论是相同类型还是不同类型，你都可以方便的知道数据的真实类型和原数据



抛砖引玉，有更好的思路可以一起交流一下😊