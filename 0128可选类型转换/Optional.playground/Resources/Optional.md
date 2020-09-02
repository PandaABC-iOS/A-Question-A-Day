#  可选类型转换

Swift 编程中需要经常处理可选类型。比如把一个可选类型转到另一个可选或非可选类型。

## 常规做法

```swift
var a: Int? = 42

/// 一般做法，判断非可选值情况
var b: Bool = false
if let _a = a {
    b = _a == 42
}

print(b)

// true
```

## map, flatMap

Optional（可选类型）其实是一个枚举，自带有 `map`, `flatMap` 方法来做转换。

```swift
/// Map
var c: Bool = a.map{ $0 == 42 } ?? false
/// 返回值是可选类型
var d: Bool? = a.flatMap {
    $0 == 42 ? true : nil
}

print(c)
print(d)

// true
// Optional(true)
```

### 示例

String 转 URL 

```swift
/// Examples
print("---URL test---")
var urlString: String? = "http://www.baidu.com"
var url = urlString.flatMap(URL.init(string:))
print(url, url?.scheme)

urlString = ""
url = urlString.flatMap(URL.init(string:))
print(url, url?.scheme)

// ---URL test---
// Optional(http://www.baidu.com) Optional("http")
// nil nil
```
