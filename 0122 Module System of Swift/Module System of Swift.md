# Module System of Swift

LLVM 引入 Module 是为了解决传统的 `#include` 和 `#import` 这些头文件导入机制所存在的问题，也就是说这是一种新的头文件管理机制

每个module意味着

* 一个和Module同名的命名空间，这也就是为什么在一个项目中，定义在不同Swift文件中的类型可以在不同的文件中直接使用而不需要include的原因了，因为它们本身就在同一个namespace里
* 一个独立的访问控制范围，当我们通过import在项目中引入一个module时，就相当于打开了这个module对应的名字空间，进而可以使用这个module中所有标记为public的代码了

## 现有机制的问题

* 每次 `#include`  `#import` 编译器必须预处理和解析头文件里的文本，存在一个头文件多次解析处理，造成巨大的冗余工作
* 由于是通过预处理器基于文本解析，容易造成宏定义冲突
* 为了避免宏冲突，一般 C 程序员习惯全大写加下划线命名，但这对非 C 语言开发者来说是不友好的
* 对编译器等工具不友好，难以区分哪些头文件属于哪个库，这些头文件应该以怎样的顺序导入以保证编译通过，这些头文件适用哪些语言（C C++ Objective-C ...）

## Module Import 的好处

* module 只会编译一次并导入，避免头文件多次引用
* module 以独立的实体解析，因此有独立统一的预处理环境，两个module之间互不影响，也不用考虑导入顺序
* 编译器可以获取更多关于 module 的信息，比如链接库、语言等

## 二进制实体

module 的二进制实体是编译器自动生成的，当通过 import 语句导入一个 module 时，编译器会用一个全新的预处理环境去解析module 中的头文件，生成的抽象语法树会存在二进制实体里，然后加载进相应的翻译单元

module 二进制会存在 module cache 里，导入时会先从cache里取，所以对于每个语言配置来说module头文件只会解析一次

如果头文件有修改，或module所依赖的关系有变化，module会自动重新编译

## modulemap

Module 机制中一个很重要的文件就是 module map 文件，module map 文件是用来描述头文件和 module 结构在逻辑上的对应关系的。

> The crucial link between modules and headers is described by a module map, which describes how a collection of existing headers maps on to the (logical) structure of a module. For example, one could imagine a module `std` covering the C standard library. Each of the C standard library headers (`stdio.h`, `stdlib.h`, `math.h`, etc.) would contribute to the `std` module, by placing their respective APIs into the corresponding submodule (`std.io`, `std.lib`, `std.math`, etc.). Having a list of the headers that are part of the `std` module allows the compiler to build the `std` module as a standalone entity, and having the mapping from header names to (sub)modules allows the automatic translation of `#include` directives to module imports.
>
> Module maps are specified as separate files (each named `module.modulemap`) alongside the headers they describe, which allows them to be added to existing software libraries without having to change the library headers themselves (in most cases [2]).

每一个 library 都会有一个对应的 `module.modulemap` 文件，这个文件中会声明要引用的头文件，这些头文件就跟 `module.modulemap` 文件放在一起。

> The module map language describes the mapping from header files to the logical structure of modules. To enable support for using a library as a module, one must write a `module.modulemap` file for that library. The `module.modulemap` file is placed alongside the header files themselves, and is written in the module map language described below.

一个 C 标准库的 module map 文件可能就是这样的：

```
module std [system] [extern_c] {
  module assert {
    textual header "assert.h"
    header "bits/assert-decls.h"
    export *
  }

  module complex {
    header "complex.h"
    export *
  }

  module ctype {
    header "ctype.h"
    export *
  }

  module errno {
    header "errno.h"
    header "sys/errno.h"
    export *
  }

  module fenv {
    header "fenv.h"
    export *
  }

  // ...more headers follow...
}
复制代码
```

modulemap 中的内容是使用 module map 语言来实现的，module map 语言中有一些保留字，其中 `umbrella` 就是用来声明 umbrella header 的。umbrella header 可以把所在目录下的所有的头文件都包含进来，这样开发者中只要导入一次就可以使用这个 library 的所有 API 了。

> A header with the `umbrella` specifier is called an umbrella header. An umbrella header includes all of the headers within its directory (and any subdirectories), and is typically used (in the `#include` world) to easily access the full API provided by a particular library. With modules, an umbrella header is a convenient shortcut that eliminates the need to write out `header` declarations for every library header. A given directory can only contain a single umbrella header.

如果你创建的是 Framework，在创建这个 Framework 时，`defines module` 默认会设置为 `YES`，编译这个 Framework 之后，可以在 build 目录下看到自动生成的 `Module` 目录，这个 `Module` 目录下有自动创建的 `modulemap` 文件，其中引用了自动创建的 umbrella header。但是如果你创建的是 static library，那就需要开发者手动为这个 module 创建 `modulemap` 文件和要引用的 umbrella header。

## Swift 中的 Module System

### Clang

Clang 模块是来自系统底层的模块，一般是 C/ObjC 的头文件。原始 API 通过它们暴露给 Swift ，编译时需要链接到对应的 Library。

例如 `UIKit`、`Foundation` 模块，从这些模块 dump 出的定义来看，几乎是完全自动生成的。当然， `Foundation` 模块更像是自动生成 + 人工扩展（其中的隐式类型转换定义、对 Swift 对象的扩展等，以及 `@availability` 禁用掉部分函数）

Swift 的 C 模块（也是它的标准库部分）完全就是 llvm 的 Module 系统，在 import search path 的所有 module.map 中的模块都可以被识别，唯一缺点可能是如果有过于复杂用到太多高级 C 或者黑暗 C 语法的函数，无法很好识别，相信以后的版本会有所改善。

所以当有人问 Swift 到底有多少标准库的时候，答案就是，基本上系统里所有的 Objective-C 和 C 头文件都可以调用。自 iOS 7 时代，这些头文件就已经被组织为 Module 了，包括标准 C 库 `Darwin.C`。同样因为 Module 系统来自于传统的 C/C++/Objc 头文件，所以 Swift 虽然可以有 `import ModA.ModB.ModC` 的语句，但是整个模块函数名字空间还是平坦的

### Swift

说完了系统模块，该说 Swift 模块了。

#### 几个文件类型

先清楚几个文件类型。假设 `ModName.swift` 是我们的 Swift 源码文件。

- `ModName.swiftmodule` Swift 的模块文件，有了它，才能 import

- `ModName.swiftdoc` 保存了从源码获得的文档注释

  - 文档注释以 `///` 开头

- `libswiftModName.dylib` 动态链接库

- `libswiftModName.a` 静态链接库

TODO: 目前有个疑问就是 `.swiftmodule` 和链接库到底什么时候用哪个，以及具体作用。

##### .swift 源码文件

先明确一个概念，一个 .swift 文件执行是从它的第一条非声明语句（表达式、控制结构）开始的，同时包括声明中的赋值部分（对应为 mov 指令或者 lea 指令），所有这些语句，构成了该 .swift 文件的 `top_level_code()` 函数。

而所有的声明，包括结构体、类、枚举及其方法，都不属于 `top_level_code()` 代码部分，其中的代码逻辑，包含在其他区域，`top_level_code()` 可以直接调用他们。

程序的入口是隐含的一个 `main(argc, argv)` 函数，该函数执行逻辑是设置全局变量 `C_ARGC` `C_ARGV`，然后调用 `top_level_code()`。

不是所有的 .swift 文件都可以作为模块，目前看，任何包含表达式语句和控制的 .swift 文件都不可以作为模块。正常情况下模块可以包含全局变量(`var`)、全局常量(`let`)、结构体(`struct`)、类(`class`)、枚举(`enum`)、协议(`protocol`)、扩展(`extension`)、函数(func)、以及全局属性(`var { get set }`)。这里的全局，指的是定义在 top level 。

这里说的表达式指 expression ，语句指 statement ，声明指 declaration 。

#### 模块编译方法

这里先以命令行操作为例，

```
`xcrun swift -sdk $(xcrun --show-sdk-path --sdk macosx) ModName.swift -emit-library -emit-module -module-name ModName -v -o libswiftModName.dylib -module-link-name swiftModName`
```

执行后获得 `ModName.swiftdoc`、`ModName.swiftmodule`、`libswiftModName.dylib`.

这三个文件就可以表示一个可 import 的 Swift 模块。目前看起来 dylib 是必须得有的，否则链接过程报错。实际感觉 `.swiftmodule` 文件所包含的信息还需要继续挖掘挖掘。

多个源码文件直接依次传递所有文件名即可。

静态链接库 `.a` 目前还没有找到方法， `-Xlinker -static` 会报错。

##### 命令行参数解释

相关命令行参数：

- `-module-name ` Name of the module to build 模块名
- `-emit-library` 编译为链接库文件
- `-emit-module-path ` Emit an importable module to 编译模块到路径（全路径，包含文件名）
- `-emit-module` Emit an importable module
- `-module-link-name ` Library to link against when using this module 该模块的链接库名，就是 `libswiftModName.dylib`，这个信息会直接写入到 `.swiftmodule`

#### 使用模块

使用模块就很简单了，记住两个参数：

`-I` 表示 import search path ，前面介绍过，保证 `.swiftmodule` 文件可以在 import search path 找到（这点很类似 module.map 文件，找得到这个就可以 import 可以编译）

`-L` 表示 链接库搜索路径，保证 `.dylib` 文件可以在其中找到，如果已经在系统链接库目录中，就不需要这个参数。

例如：

```
`xcrun swift -sdk $(xcrun --show-sdk-path --sdk macosx) mymodtest.swift -I. -L.`
```

此时表示所有 module 文件都在当前目录。

这两个选项都可以在 Xcode 中指定，所以如果你有小伙伴编译好的 module 想在你的项目里用是完全 ok 的。

#### 分析 .swiftmodule 文件

##### Foundation

这里先以标准库的 `Foundation.swiftmodule` 下手。

用 hexdump 查看发现它包含所有导出符号，以及 mangled name 。还有个文件列表，表示它是从哪些文件获得的（可以是 .swift 也可以是 .swiftmodule ）。

用 strings 列出内容，发现 Foundation 库有如下特征:

```
`... Foundation LLVM 3.5svn /SourceCache/compiler_KLONDIKE/compiler_KLONDIKE-600.0.34.4.8/src/tools/swift/stdlib/objc/Foundation/Foundation.swift /SourceCache/compiler_KLONDIKE/compiler_KLONDIKE-600.0.34.4.8/src/tools/swift/stdlib/objc/Foundation/KVO.swift /SourceCache/compiler_KLONDIKE/compiler_KLONDIKE-600.0.34.4.8/src/tools/swift/stdlib/objc/Foundation/NSStringAPI.swift CoreFoundation Foundation Swift swiftFoundation ...`
```

可以大胆猜测对应下：

- `-module-name` => `Foundation`
- 编译环境 => LLVM 3.5svn
- 源文件列表 => …
- 依赖列表 => `CoreFoundation`, `Foundation`, `Swift`
- `-module-link-name` => `swiftFoundation`

由此猜测， `Foundation` 的确是只有少量 Swift 代码做桥接。然后通过 Clang 模块将剩下工作交到底层。

分析其他类似模块也得到相同结果。

##### Swift 标准库

接下来有点好奇标准库 Swift 是怎么实现的。

依赖模块 SwiftShims 是一个 `module.map` 定义的模块，桥接的部分头文件。源文件有相关信息和注释。大致意思是用来实现几个底层接口对象，比如 `NSRange` 。

其中`-module-link-name` 是 `swift_stdlib_core`。



参考链接：

[LLVM Module](http://clang.llvm.org/docs/Modules.html#module-maps)

[如何在模块化/组件化项目中实现 ObjC-Swift 混编？](https://juejin.im/post/6844904182873325581)

[认识Swift module](https://www.jianshu.com/p/84c45890d868)

[简析 Swift 的模块系统](http://andelf.github.io/blog/2014/06/19/modules-for-swift/)

