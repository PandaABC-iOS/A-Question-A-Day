# NSOperation

如果需要子类一个异步的 NSOperation，需要先继承 NSOperation。

```swift
class CustomOperation: Operation {
    /// 表明这是一个异步的 opertion
    override var isAsynchronous: Bool { true }

    override var isExecuting: Bool {
        get {
            return _executing
        }
        
        set {
            willChangeValue(forKey: "isExecuting")
            _executing =  newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished: Bool {
        get {
            return _finished
        }
        
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var _executing: Bool = false
    private var _finished: Bool = false
}
```
因为 `isExecuting` 是 get only property，需要声明一个私有变量 `_executing` 做修改，同时也需要实现 KVO 的方法。

异步的 NSOperation 的执行代码在 `start()` 方法中。

```swift
 override func start() {
	printLog("operation start \(self) thread:\(Thread.current)")
	self.isExecuting = true
	
	asyncFunction { (ok) -> (Void) in
		printLog("async finished \(self) thread:\(Thread.current)")
		done()
	}
}

private func done() {
	self.isFinished = true
	self.isExecuting = false
}
    
private func asyncFunction(_ callback: (Bool)  -> (Void)) {
	 Thread.sleep(forTimeInterval: 2)
	 callback(true)
}
```

# 使用

```swift
func testCustomOperation() {
	let o1 = CustomOperation()
	o1.name = "1"
	
	let o2 = CustomOperation()
	o2.name = "2"
	
	o2.addDependency(o1)
	printLog("o2 dependencies: \(o2.dependencies)")
	
	OperationQueue.main.addOperation(o2)
	OperationQueue.main.addOperation(o1)
}
```

## 设置依赖关系

o2 需要等 o1 执行完。


```swift
o2.addDependency(o1)
```
