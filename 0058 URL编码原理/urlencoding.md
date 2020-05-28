# Unicode 与 UTF-8 编码

Unicode 是字符集，规定了世界上所有符号的二进制值，比如“中” 的码值为 `U+4e2d`。
UTF-8 是一种针对 Unicode 的可变长度字符编码，UTF-8 用 1 到 4 个字节编码 Unicode 字符，“中” 的编码后的字节序列为 `E4B8AD`

# URL 编码规则
URL 编码采用 % 加上一个字节的十六进制形式。

URL 编码默认用的字符集是 US-ASCII，`a` 在 US-ASCII 码中对应字节 `0x61`，编码后就是 `%61`

对于非 ASCII 字符，比如中文，URL 一般用 UTF-8 进行编码到字节，然后再对每个字节进行百分号编码。
比如“中文”使用 UTF-8 编码后的字节序列为 `0xE4 0xB8 0xAD 0xE6 0x96 0x87`，经过 URL 编码后为 `%E4%B8%AD%E6%96%87`


# iOS URL 编码

`- (nullable NSString *)stringByAddingPercentEncodingWithAllowedCharacters:(NSCharacterSet *)allowedCharacters`

系统在 iOS7 以上提供了一个 API 用来编码 URL。参数 `allowedCharacters` ，参数名直译叫做“允许的字符集”，其实就是不会被编码的字符集，会保留原样。

以 `URLQueryAllowedCharacterSet` 举例，我们可以编写一个方法，找出所有字符:

```objc
- (void)_displayCharset:(NSCharacterSet *)charset {
    NSMutableArray *array = [NSMutableArray array];
    for (int plane = 0; plane <= 16; plane++) {
        if ([charset hasMemberInPlane:plane]) {
            UTF32Char c;
            for (c = plane << 16; c < (plane+1) << 16; c++) {
                if ([charset longCharacterIsMember:c]) {
                    UTF32Char c1 = OSSwapHostToLittleInt32(c); // To make it byte-order safe
                    NSString *s = [[NSString alloc] initWithBytes:&c1 length:4 encoding:NSUTF32LittleEndianStringEncoding];
                    [array addObject:s];
                }
            }
        }
    }
    
    NSLog(@"%@", array);
    NSLog(@"%@", [array componentsJoinedByString:@""]);
}
```

整理后，是这些字符是不允许被编码：
```
[0-9]
[A-Z]
[a-z]

!$&'()*+,-./

:;=?@_~
```
## 歧义性
但一个完整的 URL 不能直接调用这个方法，会有歧义性。

比如一个 URL `http://www.baidu.com/ac-common/common/getCurTimeStamp?key1=val&ue1&key2=value2`

这里 `key1=val&ue1` 中就出现了保留字 `&`，解析的时候就分不清楚 `&` 是用来做分隔还是值的一部分。

所以编码的时候要对 URL 各个 component 分别编码：

```objc
 NSString *cv = [@"val&ue" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@""]];
// val&ue = %76%61%6C%26%75%65

// 放入完整 URL 中，因为 % 也是保留字, 再次编码后 "%" 会被编码到 %25
NSString *d = [NSString stringWithFormat:@"http://www.baidu.com/ac-common/common/getCurTimeStamp?key1=%@&key2=value", cv];
d = [d stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
// val&ue = %2576 %2561 %256C %2526 %2575 %2565    


/// 正确解码，解码的时候也需要解码两次
NSString *dd1 = [d stringByRemovingPercentEncoding];
//解码第一次：val&ue=%76%61%6C%26%75%65

NSString *dd2 = [dd1 stringByRemovingPercentEncoding];
//解码第二次：val&ue=val&ue
    
```

## 自定义编码字符

系统提供的不被允许编码字符集：

```
URLFragmentAllowedCharacterSet
URLHostAllowedCharacterSet    
URLPasswordAllowedCharacterSet
URLPathAllowedCharacterSet    
URLQueryAllowedCharacterSet   
URLUserAllowedCharacterSet    
```

系统提供的编码字符集不一定能满足我们的需求，这时候需要自定义字符集。

比如接口签名应用，需要符合 x-www-form-urlencoded 格式，同 JAVA 的 `URLEncoder.encode( url, "UTF-8" )` 方法，根据 JAVA 的文档：

```
public class URLEncoder
extends Object

Utility class for HTML form encoding. This class contains static methods for converting a String to the application/x-www-form-urlencoded MIME format. For more information about HTML form encoding, consult the HTML specification.
When encoding a String, the following rules apply:

- The alphanumeric characters "a" through "z", "A" through "Z" and "0" through "9" remain the same.
- The special characters ".", "-", "*", and "_" remain the same.
- The space character " " is converted into a plus sign "+".
- All other characters are unsafe and are first converted into one or more bytes using some encoding scheme. Then each byte is represented by the 3-character string "%xy", where xy is the two-digit hexadecimal representation of the byte. The recommended encoding scheme to use is UTF-8. However, for compatibility reasons, if an encoding is not specified, then the default encoding of the platform is used.
```

总结一下：

不允许编码的字符：
```
.-*_

[0-9]
[A-Z]
[a-z]

转换：
" " -> "+"
```

所以我们需要这样写：

```objc
NSMutableCharacterSet *charset = [[NSMutableCharacterSet alloc] init];
[charset addCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"];
[charset addCharactersInString:@".-*_"];

NSString *result = [url stringByAddingPercentEncodingWithAllowedCharacters:charset];
result = [result stringByReplacingOccurrencesOfString:@"%20" withString:@"+"];

```


# Demo
demo 上有 iOS 的编码单元测试示例。

根目录下还有一个 Main.java 是 java 的编码示例。



