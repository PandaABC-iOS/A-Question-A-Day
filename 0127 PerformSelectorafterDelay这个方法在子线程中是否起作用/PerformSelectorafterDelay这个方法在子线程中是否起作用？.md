# PerformSelector:afterDelay:这个方法在子线程中是否起作用？

不起作用，子线程默认没有 Runloop。
当调用 NSObject 的 performSelecter:afterDelay: 后，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效。

可以使用 GCD的dispatch_after来实现afterDelay这样的需求

也可以创建一个子线程然后为其启动一个Runloop

```objc
NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadConfig:) object:nil];
[thread start];

- (void)threadConfig:(id)object {
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  // 添加下边两句代码，就可以开启RunLoop，之后thread就变成了常驻线程，可随时添加任务，并交于RunLoop处理
	[runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
	[runLoop run];
}
```

当调用 performSelector:onThread: 时，实际上其会创建一个 Source0 的事件源，同样的，如果对应线程没有 RunLoop 该方法也会失效



参考链接：https://bujige.net/blog/iOS-Complete-learning-RunLoop.html

