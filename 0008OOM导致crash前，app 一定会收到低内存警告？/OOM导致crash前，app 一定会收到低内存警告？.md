# OOM 导致 crash 前，app 一定会收到低内存警告？

OOM (out of memory) ，根据 Facebook 的[这篇文章](https://engineering.fb.com/ios/reducing-fooms-in-the-facebook-ios-app/)，分为FOOM (foreground OOM) 和 BOOM (background OOM)。从用户角度来看，FOOM 与一般 crash 无异。但是因 OOM 导致的 crash 无法被 app 捕获，这就为我们判定 OOM 带来了难度。

## didReceiveMemoryWarning

要判断是否发生了 OOM，首先想到的就是 didReceiveMemoryWarning。

我们知道，当内存不足时系统会给 app 发送 didReceiveMemoryWarning 的警告。但是具体是 app 用了多少内存以后会发送这个警告呢？发送了警告之后是不是 app 就 crash 了呢？OOM 导致 crash 前，app 是否一定会收到这个警告呢？

### 内存上限

根据[官方文档](https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle?language=objc )的说明，如果系统可用内存过低，又不能通过杀掉挂起的 app 来释放内存的时候，UIKit 就会给正在运行的 app 发送一个 low-memory 警告。这里并没有提到内存上限的大小。

实际上，根据 *Jetsam 机制*3，OOM发生时，在系统强杀 App 前，会判断优线程先级，按照优先级去释放优先级低还使用内存多的线程。这个优先级规定是：内核用线程的优先级是最高的，操作系统的优先级其次，App 的优先级排在最后。并且，前台 App 程序的优先级是高于后台运行 App 的。所以如果 OOM 发生的时候，你的 app 如果在后台也有可能被强杀。如果你的 app 在前台，能使用内存上限也不是一个固定值。

### 收到低内存警告一定会crash吗

实际上，如果收到内存警告后，内存并没有快速持续上涨，我们又非常快速的释放了内存，app 并不会 crash。也就是说只要及时地降低内存的使用， app 就不会 crash。

### OOM 导致 crash 前，app 一定会收到低内存警告吗

我们可以实际测试一下：

在主线程执行下面的代码：

```objective-c
while (true) {
        NSData *bigData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"some_image" withExtension:@"png"]];
        [oom addObject:[bigData copy]];
    }
```

bigData 足够大的情况下，比如几十 k，app 很快 crash，并且没有收到低内存警告。因为这时，内存增长很快，主线程又忙。

那如果在其他线程执行上述代码呢？

```objective-c
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (true) {
            NSData *bigData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"some_image" withExtension:@"png"]];
            [oom addObject:[bigData copy]];
        }
    });
```

这时，app 收到低内存警告了。也就是说，虽然都是急速的上涨内存，如果主线程不那么忙，就能收到低内存警告。

所以，发生 OOM 时，并不一定能收到低内存警告。Facebook 的[这篇文章](https://engineering.fb.com/ios/reducing-fooms-in-the-facebook-ios-app/)也说并不是总能收到内存警告：

`*If the rate of memory consumption increases drastically, the application can be killed without receiving any signal that memory is running out. On iOS, the OS does its best to send a memory warning to the app, but there is no guarantee that one will always be received before the OS evicts the process from memory.*`



### 小结

通过上面的论述，我们知道：收到低内存警告不一定会 crash，OOM 时也不一定能收到低内存警告。



### 排除法

Facebook的 [Reducing FOOMs in the Facebook iOS app](https://engineering.fb.com/ios/reducing-fooms-in-the-facebook-ios-app/ ) 提到，他们是通过在 app 启动时，排除启动原因来找到 OOM 的：

在app启动时，我们依次判断：

-  App没有升级
- App没有调用exit()或abort()退出
- App没有出现crash
- 用户没有强退App
- 系统没有升级/重启
- App当时没有后台运行
-  App出现FOOM

但是这个模型并不完美。其中最大的漏洞就是那些不能被捕获的 crash。

### 不能被 app 捕获的 crash

不能被 app 捕获的 crash 一般都是因为系统强杀引起的，OOM 是其中一种，但还有其他情况。

其他被系统强杀的原因最常见有两种，一是后台任务超时和二是主线程长时间卡顿被 watchdog 强杀，也就是常见的 0x8badf00d。当然，除了这两种情况还有其他被系统强杀的原因，比如电池过热，启动时间过长等。

随着 iOS 系统的升级，系统强杀的种类和阈值可能都会发生变化。

所以，这种排除法有一定误报的可能。

### 结论

排除法是 facebook 采用的方法，微信的 Matrix 应该也采用了这个方法。但是，排除法会有一定误报的可能，实现难度也更高。

从收到内存警告到 app crash，中间有几秒的时间，一种说法是 6 秒，但我实测是 4 秒左右，系统的日志也是在这段时间产生的。如果 app 收到了低内存警告，又在几秒钟之内 crash 了，基本上就可以 100% 确定发生了 OOM。

对于收不到低内存警告的 OOM，我们就无能为力了。但我认为这种情况是少见的极端情况。

所以两种判定 OOM 的方法都不完美，综合实现难度来看，利用内存警告断定是否发生了 OOM，也许是一个比较不错的选择。