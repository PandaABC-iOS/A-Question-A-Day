## JSPatch热修复原理是怎么样的？



### JavaScriptCore

iOS 系统内置的 JavaScriptCore，是能够在 App 运行过程中解释执行 JS 脚本的解释器。

### Objective-C 的动态性

JSPatch 能做到通过 JS 调用和改写 OC 方法最根本的原因是 Objective-C 是动态语言，OC 上所有方法的调用/类的生成都通过 Objective-C Runtime 在运行时进行，我们可以通过类名/方法名反射得到相应的类和方法：

```
Class class = NSClassFromString("UIViewController");
id viewController = [[class alloc] init];
SEL selector = NSSelectorFromString("viewDidLoad");
[viewController performSelector:selector];
```

也可以替换某个类的方法为新的实现：

```
static void newViewDidLoad(id slf, SEL sel) {}
class_replaceMethod(class, selector, newViewDidLoad, @"");
```

还可以新注册一个类，为类添加方法：

```
Class cls = objc_allocateClassPair(superCls, "JPObject", 0);
class_addMethod(cls, selector, implement, typedesc);
objc_registerClassPair(cls);
```

理论上你可以在运行时通过类名/方法名调用到任何 OC 方法，替换任何类的实现以及新增任意类。

### 实现原理

JSPatch 的基本原理就是：在应用启动的时候，下载脚本，并使用 JavaScriptCore 进行解释。JS 传递字符串给 OC，OC 通过 Runtime 接口调用和替换 OC 方法。

更多细节请查看[链接](https://github.com/bang590/JSPatch/wiki/JSPatch-实现原理详解)。