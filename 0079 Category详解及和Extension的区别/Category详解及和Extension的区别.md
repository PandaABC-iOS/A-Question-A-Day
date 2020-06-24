# Category详解及和Extension的区别

1、**Category:类别，分类**

- 类别是一种为现有的类添加新方法的方式。
- **可以添加属性`@property`,但是不会生成成员变量，也不会生成setter方法和getter方法的实现。但是可以通过runtime关联对象生成setter方法和getter方法的实现。**
- **是在运行时决议的**
- 不能添加实例变量的原因：因为在运行时，对象的内存布局已经确定，如果添加实例变量会破坏类的内存布局，这对编译性语言是灾难性的。

2、**Extension**

- 可以说成是特殊的分类，也叫做匿名的分类
- **可以给类添加属性，但是是私有变量**
- **可以给类添加方法，也是是私有方法**
-  **编译时决议，是类的一部分，**在编译时和头文件的@interface和实现文件里的@implement一起形成了一个完整的类。
- 伴随着类的产生而产生，也随着类的消失而消失。
- **Extension一般用来隐藏类的私有消息，你必须有一个类的源码才能添加一个类的Extension，所以对于系统一些类，如NSString，就无法添加类扩展**

## Category的优点

- **可以将类的实现代码分散到多个不同的文件或框架中**

  - 可以减少单个文件的体积
  - 可以把不同的功能组织到不同的Category中
  - 可以由多个开发者共同完成一个类
  - 可以按需加载想要的Category

- **创建对私有方法的前向引用**

  > Cocoa没有任何真正的私有方法。只要知道对象支持的某个方法的名称，即使该对象所在的类的接口中没有该方法的声明，你也可以调用该方法。不过这么做编译器会报错，但是只要新建一个该类的类别，在类别.h文件中写上原始类该方法的声明，类别.m文件中什么也不写，就可以正常调用私有方法了。这就是传说中的私有方法前向引用。 所以说cocoa没有真正的私有方法。

- 模拟多继承（另外可以模拟多继承的还有protocol，组合、消息转发）

- 把framework的私有方法公开

## Category的特点

- 如果Category中的方法和类中原有的方法同名，运行时会优先调用Category中的方法。也就是，**category中的方法会覆盖掉类中原有的方法。**所以开发中尽量保证不要让分类中的方法和原有类中的方法名相同。避免出现这种情况的解决方案是给分类的方法名统一添加前缀。比如category_。

  > 1.**category的方法没有“完全替换掉”原来类已经有的方法**，也就是说如果category和原来类都有methodA，那么category附加完成之后，类的方法列表里会有两个methodA。

  > 2.**category的方法被放到了新方法列表的前面，而原来类的方法被放到了新方法列表的后面**，这也就是我们平常所说的category的方法会“覆盖”掉原来类的同名方法，这是因为运行时在查找方法的时候是顺着方法列表的顺序查找的，它只要一找到对应名字的方法，就会罢休，殊不知后面可能还有一样名字的方法。

- **如果多个category中存在同名的方法，运行时到底调用哪个方法有编译器决定，最后一个参与编译的方法会被调用。**

## 为什么category不能添加成员变量？

Objective-C类是由Class类型来表示的，它实际上是一个指向`objc_class`结构体的指针。它的定义如下：



```cpp
typedef struct objc_class *Class;
```

objc_class结构体的定义如下：



```cpp
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;
#if !__OBJC2__
    Class super_class                       OBJC2_UNAVAILABLE;  // 父类
    const char *name                        OBJC2_UNAVAILABLE;  // 类名
    long version                            OBJC2_UNAVAILABLE;  // 类的版本信息，默认为0
    long info                               OBJC2_UNAVAILABLE;  // 类信息，供运行期使用的一些位标识
    long instance_size                      OBJC2_UNAVAILABLE;  // 该类的实例变量大小
    struct objc_ivar_list *ivars            OBJC2_UNAVAILABLE;  // 该类的成员变量链表
    struct objc_method_list **methodLists   OBJC2_UNAVAILABLE;  // 方法定义的链表
    struct objc_cache *cache                OBJC2_UNAVAILABLE;  // 方法缓存
    struct objc_protocol_list *protocols    OBJC2_UNAVAILABLE;  // 协议链表
#endif
} OBJC2_UNAVAILABLE;
```

在上面的`objc_class`结构体中，ivars是`objc_ivar_list`成员变量列表的指针；`methodLists`是指向`objc_method_list`指针的指针。在Runtime中，objc_class结构体大小是固定的，不可能往这个结构体中添加数据，只能修改。所以ivars指向的是一个固定区域，只能修改成员变量值，不能增加成员变量个数。methodList是一个二维数组，所以可以修改*methodLists的值来增加成员方法，虽没办法扩展methodLists指向的内存区域，却可以改变这个内存区域的值（存储的是指针）。因此，可以动态添加方法，不能添加成员变量。

## Category中能添加属性吗？

Category不能添加成员变量（instance variables），那到底能不能添加属性（property）呢？
 这个我们要从Category的结构体开始分析：



```cpp
typedef struct category_t {
    const char *name;  //类的名字
    classref_t cls;  //类
    struct method_list_t *instanceMethods;  //category中所有给类添加的实例方法的列表
    struct method_list_t *classMethods;  //category中所有添加的类方法的列表
    struct protocol_list_t *protocols;  //category实现的所有协议的列表
    struct property_list_t *instanceProperties;  //category中添加的所有属性
} category_t;
```

从Category的定义也可以看出Category的可为（可以添加实例方法，类方法，甚至可以实现协议，添加属性）和不可为（无法添加实例变量）。



