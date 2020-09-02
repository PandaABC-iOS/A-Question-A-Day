import Foundation

var a: Int? = 42

/// 一般做法，判断非可选值情况
var b: Bool = false
if let _a = a {
    b = _a == 42
}

print(b)

/// Map
var c: Bool = a.map{ $0 == 42 } ?? false
/// 返回值是可选值类型
var d: Bool? = a.flatMap {
    $0 == 42 ? true : nil
}

print(c)
print(d)

/// Examples
print("---URL test---")
var urlString: String? = "http://www.baidu.com"
var url = urlString.flatMap(URL.init(string:))
print(url, url?.scheme)

urlString = ""
url = urlString.flatMap(URL.init(string:))
print(url, url?.scheme)


