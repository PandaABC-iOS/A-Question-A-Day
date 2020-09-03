## iOS Xcode 的汇编模式切换



>  **1.你只需要在XCODE的菜单：Debug -> Breakpoints -> Create Symbolic Breakpoint 或者快捷键:option + command + \ 来建立符号断点：**

> **图1:**

![img](https://upload-images.jianshu.io/upload_images/6083675-b064944e5c68d5fc?imageMogr2/auto-orient/strip|imageView2/2/w/1124)

> **图2:**

![img](https://upload-images.jianshu.io/upload_images/6083675-3028c09f0cbe8bad?imageMogr2/auto-orient/strip|imageView2/2/w/932)

>  **2.\* 汇编模式下**
>
>  fn + control + F7 :  指令单步执行，当遇到函数调用时会跳入函数内部。
>
>  fn + control + F6:  指令单独执行，当遇到函数调用时不会跳入函数内部。

>  **3.\* 多线程之间的切换：**
>
>  control + shift + F7:  切换到当前线程，并执行单步指令。
>
>  control  + shift + F6:  切换到当前线程，并跳转到函数调用的者的下一条指令。 

>  **4.\* lldb命令行**
>
> expr  变量|表达式//显示变量或者表达式的值。
>
> expr -f h --  变量|表达式 //以16进制格式显示变量或表达式的内容
>
> expr -f b --  变量|表达式//以二进制格式显示变量或者表达式的内容。
>
> expr -o --  oc对象 //等价于po  oc对象
>
>   expr -P  3 -- oc对象//上面命令的加强版本，他还会显示出对象内数据成员的结构，具体的P后面的数字就是你要想显示的层次。
>
> expr my_struct->a = my_array[3]//给my_struct的a成员赋值。
>
> expr (char*)_cmd//显示某个oc方法的方法名。
>
> expr (IMP)[self methodForSelector:_cmd]//执行某个方法调用.

> **图3:**

![img](https://upload-images.jianshu.io/upload_images/6083675-02bc565cbbe42e2c?imageMogr2/auto-orient/strip|imageView2/2/w/1016)

# **三、查看内存地址**

>  **1.Debug -> Debug Workflow -> View Memory 或者通过快捷键：shift+command + m 来调用内存查看界面:**

> **图4:**

![img](https://upload-images.jianshu.io/upload_images/6083675-09b0f32c20922db4?imageMogr2/auto-orient/strip|imageView2/2/w/1043)

> **注意一点的是: 因为内存地址是从低位按字节依次排列而来，所以对于比如int类型的值的读取我们就要从高位到低位开始读取。**

# 