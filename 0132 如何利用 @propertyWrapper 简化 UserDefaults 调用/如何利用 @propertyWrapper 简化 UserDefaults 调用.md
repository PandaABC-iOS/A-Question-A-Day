# 如何利用 @propertyWrapper 简化 UserDefaults 调用



回答这个问题之前，我们先看另外一个问题

```swift
@propertyWrapper
struct Wrapper<T> {
    var wrappedValue: T

    var projectedValue: Wrapper<T> { return self }

    func foo() { print("Foo") }
}

struct HasWrapper {
    @Wrapper
    var x = 0

    func foo() {
        print(x)
        print(_x)
        print($x)
    }
}

let wr = HasWrapper()
wr.foo()
```

以上代码会输出什么？

```swift
0
Wrapper<Int>(wrappedValue: 0)
Wrapper<Int>(wrappedValue: 0)
```

实际上，输出的值的含义是

```swift
func foo() {
        print(x) // `wrappedValue`
        print(_x) // wrapper type itself
        print($x) // `projectedValue`
}
```

可以看到，当我们访问被 propertyWrapper 标记的属性时，实际上访问的是 wrappedValue ， 这里我们就有机会把一些通用逻辑封装在 wrappedValue 的 get set 方法里

接下来我们用 UserDefaults 保存是否显示新手引导的例子来让大家有一个直观的了解

## 没有@propertyWrapper 的时候。。😔

```swift
extension UserDefaults {

    public enum Keys {
        static let hadShownGuideView = "had_shown_guide_view"
    }

    var hadShownGuideView: Bool {
        set {
            set(newValue, forKey: Keys.hadShownGuideView)
        }
        get {
            return bool(forKey: Keys.hadShownGuideView)
        }
    }
}

/// 下面的就是业务代码了。
let hadShownGuide =  UserDefaults.standard.hadShownGuideView 
if !hadShownGuide {
    /// 显示新手引导 并保存本地为已显示
    showGuideView() /// showGuideView具体实现略。
    UserDefaults.standard.hadShownGuideView = true
}
```

可是项目中有很多地方需要UserDefaults保存本地数据,数据量多了这样的`重复代码`就很多了。

## 有@propertyWrapper 的时候。。😁

```swift
@propertyWrapper /// 先告诉编译器 下面这个UserDefault是一个属性包裹器
struct UserDefault<T> {
    ///这里的属性key 和 defaultValue 还有init方法都是实际业务中的业务代码   
    ///我们不需要过多关注
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
///  wrappedValue是@propertyWrapper必须要实现的属性
/// 当操作我们要包裹的属性时  其具体set get方法实际上走的都是wrappedValue 的set get 方法。 
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

///封装一个UserDefault配置文件
struct UserDefaultsConfig {
///告诉编译器 我要包裹的是hadShownGuideView这个值。
///实际写法就是在UserDefault包裹器的初始化方法前加了个@
/// hadShownGuideView 属性的一些key和默认值已经在 UserDefault包裹器的构造方法中实现
  @UserDefault("had_shown_guide_view", defaultValue: false)
  static var hadShownGuideView: Bool
}

///具体的业务代码。
UserDefaultsConfig.hadShownGuideView = false
print(UserDefaultsConfig.hadShownGuideView) // false
UserDefaultsConfig.hadShownGuideView = true
print(UserDefaultsConfig.hadShownGuideView) // true
```