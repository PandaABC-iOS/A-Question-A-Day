# 如何利用 Symbolic Breakpoint 检测 View Controller 中的循环引用



大多数情况下，为了检测 VC 中是否有内存泄漏，我们会在 `deinit` 方法里打印一段信息，如果某个 VC 一直不进入 `deinit` 方法并打印出相应信息，我们认为这个 VC 存在内存泄漏。

```swift
deinit {
    print("deinit \(self)")
}
```



## A Better Way

其实我们可以用 Xcode 的 symbolic breakpoint 完成这个操作，并且不用写代码

1. Go to **Breakpoint Navigator** (Menu View > Navigators > Show Breakpoint Navigator or ⌘ - command + 8).

![1](https://d33wubrfki0l68.cloudfront.net/16ddc6db69a9121cf2e5484be796a49c069af5f3/f9834/images/debug-deinit-breakpoint-add.png)

2. Click **+** and select **Symbolic Breakpoint...** or Menu Debug > Breakpoints > Create Symbolic Breakpoint...

![2](https://d33wubrfki0l68.cloudfront.net/939e37ca4eacdc2f2bed61facaed3e6ae8e4e7f6/2097b/images/debug-deinit-breakpoint-new.png)

3. Set `Symbol` with value `-[UIViewController dealloc]`.

![3](https://d33wubrfki0l68.cloudfront.net/9dfec756012efde4e9edddfd49a819656eeaeba9/3d7be/images/debug-deinit-breakpoint-symbol.png)

4. Click **Add Action** button and set `Sound` to `Pop` (or any sound you like).

![4](https://d33wubrfki0l68.cloudfront.net/1d4a6297ccb4588c1065e1b8d68983237c17ce2b/2c648/images/debug-deinit-breakpoint-sound.png)

5. Add another action by click **+** next to our sound action.

6. Set an action to `Log Message` and set a message to whatever you want to print to the console when a view controller gets deallocated. In my case I set it to `--- dealloc @(id)[$arg1 description]@`.

![6](https://d33wubrfki0l68.cloudfront.net/65fea51ea9b1f2485cc292b5e7b517b87631a9c8/15552/images/debug-deinit-breakpoint-log.png)

7. Check **Automatically continue after evaluating actions** option since we don't want a debugger to pause when a view controller gets deallocated.

![7](https://d33wubrfki0l68.cloudfront.net/02787f5f5a4704667b633bcc88184c50672878ec/b4396/images/debug-deinit-breakpoint-options.png)



通过设置完这个断点，每当有 VC dissmiss 或 pop 时，我们可以听到一个提示音，并在控制台看到打印信息，如果当我们 pop  或 dismiss 一个 VC 后没听到这个提示音， 说明发生内存泄漏了



完整的设置界面应该是这样的

![9](https://d33wubrfki0l68.cloudfront.net/ed072d774d90c6c39313c572521165b1cd23e5da/c5b38/images/debug-deinit-breakpoint-result.png)