# 使用信号量

使用信号量，用来控制并发访问资源

串联请求
```swift
let sem = DispatchSemaphore(value: 0)

for i in 0..<10 {
    let task = DispatchQueue.init(label: "this is \(i) queue")
    task.async {

        sleep(1)
        print("async \(i), current thread: \(Thread.current)")
        sem.signal()
    }
    
    print("i \(i), current thread: \(Thread.current)")
    sem.wait(timeout: DispatchTime.distantFuture)
}
print("执行完毕 current thread: \(Thread.current)")
```

创建信号量 

```swift
let sem = DispatchSemaphore(value: 0)
```

等待信号量

```swift
sem.wait(timeout: DispatchTime.distantFuture)
```

`sem` 等于 0，线程一直等待。`sem` 大于 0，往下执行，`sem` 减 1。

发送信号量
```swift
sem.signal()
```

运行结果

```
i 0, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 0, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 1, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 1, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 2, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 2, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 3, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 3, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 4, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 4, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 5, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 5, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 6, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 6, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 7, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 7, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 8, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 8, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
i 9, current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
async 9, current thread: <NSThread: 0x600001d8c900>{number = 5, name = (null)}
执行完毕 current thread: <NSThread: 0x600001dcc3c0>{number = 1, name = main}
```
