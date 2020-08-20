# 强制解包

使用强制解包可以减少代码路径，初始化方法调用的时候，无法赋值给这个变量，但访问的时候一定有值，比如下面的 `myButton`。
如果是一个 optional 的 `myButton`，就不太符合逻辑。

```swift
class MyViewController: UIViewController {
    @IBOutlet weak var myButton: UIButton!
 
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated: animated)
        myButton.addTarget( /* ... */ )
    }
}
```

与后端约定字段的情况，需要崩溃如果 id 是空的或者不是 Number 类型。

```swift
func decodeID(from dict: [String: Any]) -> Int {
    return dict["id"] as! Int
}
```