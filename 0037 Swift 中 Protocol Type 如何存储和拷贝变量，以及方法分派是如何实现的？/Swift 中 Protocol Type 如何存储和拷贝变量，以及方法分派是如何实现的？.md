# Swift 中 Protocol Type 如何存储和拷贝变量，以及方法分派是如何实现的？

## 协议类型 Protocol Type

首先先看一下 OOP 是如何实现多态的

```swift
class Drawable { func draw() }

class Point : Drawable {
    var x, y:Double
    func draw() { ... }
}

class Line : Drawable {
    var x1, y1, x2, y2:Double
    func draw() { ... }
}

let point = Point(x: 0, y: 0)
let line = Line(x1: 0, y1: 0, x2: 1, y2: 1)

var drawables: [Drawable] = [point, line]
for d in drawables {
    d.draw()
}
```

从上述代码可以看出，变量 `drawables` 是一个元素类型为 `Drawable` 的数组，由于 `class` 关键字标记了 `Drawable` 及其子类 `Point`、`Line` 都是引用类型，因此 `drawables` 的内存布局是固定的，数组里的每一个元素都是一个指针。如下图所示。

![img](https://user-gold-cdn.xitu.io/2020/2/20/17062c8310a5aaca?imageView2/0/w/1280/h/960/format/png/ignore-error/1)

接下来，我们再来看 OOP 是如何通过 `virtual table` 来实现动态派发的。如下图所示

![img](https://user-gold-cdn.xitu.io/2020/2/20/17062c83110d1bae?imageView2/0/w/1280/h/960/format/png/ignore-error/1)

运行时执行 `d.draw()`，会根据 `d` 所指向的对象的 `type` 字段索引到该类型所对应的函数表，最终调用正确的方法。

下面我们举一个例子看一下 POP 是如何实现多态的。

```swift
protocol Drawable { func draw() }

struct Point : Drawable {
    var x, y: Double
    func draw() { ... }
}

struct Line : Drawable {
    var x1, y1, x2, y2: Double
    func draw() { ... }
}

class SharedLine: Drawable {
    var x1, y1, x2, y2: Double
    func draw() { ... }
}

let point = Point(x: 0, y: 0)
let line = Line(x1: 0, y1: 0, x2: 1, y2: 1)
let sharedLine = SharedLine(x1: 0, y1: 0, x2: 1, y2: 1)

var drawables: [Drawable] = [point, line, sharedLine]
for d in drawables {
    d.draw()
}
```

需要注意的是，此时 `Point` 和 `Line` 都是值类型的 `struct`，只有 `SharedLine` 是引用类型的 `class`，并且 `Drawable` 不再是一个基类，而是一个 **协议类型**（Protocol Type）。

那么此时，变量 `drawables` 的内存布局是怎样呢？毕竟，运行时 `d` 可能是遵循协议的任意类型，类型不同，内存大小也会不同。

![img](https://user-gold-cdn.xitu.io/2020/2/20/17062c8311297fd7?imageView2/0/w/1280/h/960/format/png/ignore-error/1)

事实上，在这种情况下，变量 `drawables` 中存储的元素是一种特殊的数据类型：**Existential Container**。

### Existential Container

Existential Container 是编译器生成的一种特殊的数据类型，用于管理遵守了相同协议的协议类型。因为这些数据类型的内存空间尺寸不同，使用 Extential Container 进行管理可以实现存储一致性。

我们在上述代码的基础上执行下面的示例代码。

```swift
let point = Point(x: 0, y: 0)
let line = Line(x1: 0, y1: 0, x2: 1, y2: 1)
let sharedLine = SharedLine(x1: 0, y1: 0, x2: 1, y2: 1)
print("\(MemoryLayout.size(ofValue: point))")
print("\(MemoryLayout.size(ofValue: line))")
print("\(MemoryLayout.size(ofValue: sharedLine))")

var drawables: [Drawable] = [point, line, sharedLine]
for d in drawables {
    print("\(MemoryLayout.size(ofValue: d))")
}

// 原始类型的内存大小，单位：字节
16
32
8
// 协议类型的内存大小，单位：字节
40
40
40
```

由于本机内存对齐是 8 字节，可见 `Extension Container` 类型占据 5 个内存单元（也称 **词**，Word）。其结构如下图所示：

![img](https://user-gold-cdn.xitu.io/2020/2/20/17062c83110417e8?imageView2/0/w/1280/h/960/format/png/ignore-error/1)

- 3 个词作为 **Value Buffer**。
- 1 个词作为 **Value Witness Table** 的索引。
- 1 个词作为 **Protocol Witness Table** 的索引。

下面，我们依次进行介绍。

#### Value Buffer

Value Buffer 占据 3 个词，存储的可能是值，也可能是指针。对于 Small Value（存储空间小于等于 Value Buffer），可以直接内联存储在 Value Buffer 中。对于 Large Value（存储空间大于 Value Buffer），则会在堆区分配内存进行存储，Value Buffer 只存储对应的指针。如下图所示。



![img](https://user-gold-cdn.xitu.io/2020/2/20/17062c831164eb88?imageView2/0/w/1280/h/960/format/png/ignore-error/1)



#### Value Witness Table

由于协议类型的具体类型不同，其内存布局也不同，Value Witness Table 则是对协议类型的生命周期进行专项管理，从而处理具体类型的初始化、拷贝、销毁。如下图所示：



![img](https://user-gold-cdn.xitu.io/2020/2/20/17062c83120e9fba?imageView2/0/w/1280/h/960/format/png/ignore-error/1)



#### Protocol Witness Table

Value Witness Table 管理协议类型的生命周期，Protocol Witness Table 则管理协议类型的方法调用。

在 OOP 中，基于继承关系的多态是通过 Virtual Table 实现的；在 POP 中，没有继承关系，因为无法使用 Virtual Table 实现基于协议的多态，取而代之的是 Protocol Witness Table。

> 注：关于 Virtual Table 和 Protocol Witness Table 的区别，我的理解是：
>  它们都是一个记录函数地址的列表（即函数表），只是它们的生成方式是不同的。
>  对于 Virtual Table，在编译时，子类的函数表是通过对基类函数表进行拷贝、覆写、插入等操作生成的。
>  对于 Protocol Witness Table，在编译时，函数表是通过检查具体类型对协议的实现，直接生成的。



![img](https://user-gold-cdn.xitu.io/2020/2/20/17062c833e98efb9?imageView2/0/w/1280/h/960/format/png/ignore-error/1)

#### 伪代码

我们来借助具体的示例进行进一步了解：

```swift
// Protocol Types
// The Existential Container in action
func drawACopy(local ：Drawable) {
 local.draw()
}
let val :Drawable = Point()
drawACopy(val)
```

在Swift编译器中，通过`Existential Container`实现的伪代码如下：

```swift
// Protocol Types
// The Existential Container in action
func drawACopy(local :Drawable) {
 local.draw()
}
let val :Drawable = Point()
drawACopy(val)

//existential container的伪代码结构
struct ExistContDrawable {
 var valueBuffer:(Int, Int, Int)
 var vwt:ValueWitnessTable
 var pwt:DrawableProtocolWitnessTable
}

// drawACopy方法生成的伪代码
func drawACopy(val:ExistContDrawable) { //将existential container传入
 var local = ExistContDrawable()  //初始化container
 let vwt = val.vwt //获取value witness table，用于管理生命周期
 let pwt = val.pwt //获取protocol witness table，用于进行方法分派
 local.type = type 
 local.pwt = pwt
 vwt.allocateBufferAndCopyValue(&local, val)  //vwt进行生命周期管理，初始化或者拷贝
 pwt.draw(vwt.projectBuffer(&local)) //pwt查找方法，这里说一下projectBuffer，因为不同类型在内存中是不同的（small value内联在栈内，large value初始化在堆内，栈持有指针），所以方法的确定也是和类型相关的，我们知道，查找方法时是通过当前对象的地址，通过一定的位移去查找方法地址。
 vwt.destructAndDeallocateBuffer(temp) //vwt进行生命周期管理，销毁内存
}
```

### 协议类型存储属性优化

由上述 Value Buffer 相关内容可知，协议类型的存储分两种情况

- 对于 Small Value，直接内联存储在 Existential Container 的 Value Buffer 中；
- 对于 Large Value，通过堆区分配进行存储，使用 Existential Containter 的 Value Buffer 进行索引。

那么，协议类型的存储属性是如何拷贝的呢？事实上，对于 Small Value，就是直接拷贝 Existential Container，值也内联在其中。但是，对于 Large Value，Swift 采用了 **Indirect Storage With Copy-On-Write** 技术进行了优化。

这种技术可以提高内存指针利用率，降低堆区内存消耗，从而实现性能提升。该技术的原理是：拷贝时仅仅拷贝 Extension Container，当修改值时，先检测引用计数，如果引用计数大于 1，则开辟新的堆区内存。其实现伪代码如下所示：

```swift
class LineStorage { 
    var x1, y1, x2, y2:Double 
}

struct Line : Drawable {
    var storage : LineStorage
    init() { storage = LineStorage(Point(), Point()) }
    func draw() { … }
 
    mutating func move() {
        if !isUniquelyReferencedNonObjc(&storage) { 
        // 如果存在多份引用，则开启新内存，否则直接修改
            storage = LineStorage(storage)
        }
        storage.start = ...
    }
}
```

## 泛型类型 Generic Type

下面，我们来讨论泛型的实现。首先来看一个例子。

```swift
func foo<T: Drawable>(local: T) {
    bar(local)
}

func bar<T: Drawable>(local: T) {
    
}

let point = Point()
foo(point)
```

上述代码中，泛型方法的调用过程大概如下：

```swift
// foo 方法执行时，Swift 将泛型 T 绑定为具体类型。示例中是 Point
foo(point) --> foo<T = Point>(point)
// 调用内部 bar 方法时，Swift 会使用已绑定的变量类型 Point 进一步绑定到 bar 方法的泛型 T 上。
bar(local) --> bar<T = Point>(local)
```

相比协议类型而言，泛型类型在调用时总是能确定类型，因此无需使用 Existential Container。在调用泛型方法时，只需要将 Value Witness Table/Protocol Witness Table 作为额外参数进行传递。

> 注：根据方法调用时数据类型是否确定可以将多态分为：**静态多态**（Static Polymorphism）和 **动态多态**（Dynamic Polymorphism）。
>  在泛型类型调用方法时， Swift 会将泛型绑定为具体的类型。因此泛型实现的是静态多态。
>  在协议类型调用方法时，类型是 Existential Container，需要在方法内部进一步根据 pwt 进行方法索引。因此协议实现的是动态多态。

### 泛型特化

我们以一个例子来说明编译器对于泛型的一种优化技术：**泛型特化**。

```swift
func min<T: Comparable>(x: T, y: T) -> T {
  return y < x ? y : x
}

let a: Int = 1
let b: Int = 2
min(a, b)
```

上述代码，编译器在编译期间就能通过类型推导确定调用 `min()` 方法时的类型。此时，编译器就会通过泛型特化，进行 **类型取代**（Type Substitute），生成如下的一个方法：

```swift
func min<Int>(x: Int, y: Int) -> Int {
  return y < x ? y :x
}
```

泛型特化会为每个类型生成一个对应的方法。那么是不是会出现代码空间爆炸的情况呢？事实上，并不会出现这种情况。因为编译器可以进行代码内联以及进一步的优化，从而降低方法数量并提高性能。

#### 全模块优化

泛型特化的前提是编译器在编译期间可以进行类型推导，这就要求在编译时提供类型的上下文。如果调用方和类型是单独编译的，就无法在编译时进行类型推导，因此无法使用泛型特化。为了能够在编译期间提供完整的上下文，我们可以通过 **全模块优化**（Whole Module Optimization） 编译选项，实现调用方和类型在不同文件时也能进行泛型特化。

全模块优化是用于 Swift 编译器的优化机制。从 Xcode 8 开始默认开启。

# 总结

本文，我们了解了协议类型和泛型类型对于多态的实现，从中我们也看到了编译器对于 Swift 性能的优化发挥了巨大的作用，如：泛型特化、生成代码实现 Copy-On-Write。

此外，我们了解了关于泛型和协议关于性能优化的启示，能够我们制定技术方案时进行权衡。

# 参考


作者：baochuquan链接：https://juejin.im/post/5e4e8948e51d4526d12099bf来源：掘金著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

深入剖析Swift性能优化 https://juejin.im/post/5bdbdc876fb9a049f36186c3#heading-5