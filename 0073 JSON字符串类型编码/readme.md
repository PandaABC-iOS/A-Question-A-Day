# JSON 序列化对字符串的处理

在使用 `NSJSONSerialization` 序列化到字符串时，会碰到 "http://" 被转义到 "http:\/\/" 的情况。然后一般会用 `[strResult stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"]` 进行替换。其实会被转义的字符不光只有斜杠 '/'。



根据 JSON [RFC 7159](https://tools.ietf.org/html/rfc7159#section-7) 

> All Unicode characters may be placed within the
> quotation marks, except for the characters that must be escaped:
>    quotation mark, reverse solidus, and the control characters (U+0000
>    through U+001F).
>    
> 所有的 unicode 字符可以被双引号包围，除了一些必须被转义的字符：双引号，反斜杠，和控制字符(U+0000 到 U+001F)

所以说斜杠 '/' 不是必须被转义的，但 `NSJSONSerialization` 还是选择去做了，有可能是考虑到内嵌到 `</script>` 标签中的情况。

## Unicode

Unicode 为每一个字符而非字形定义唯一的代码（即一个整数）。在表示一个 Unicode 的字符时，通常会用“U+”然后紧接着一组十六进制的数字来表示这一个字符。

Unicode 的[字符平面映射](https://zh.wikipedia.org/wiki/Unicode字符平面映射#基本多文种平面), 分为 17 组，第 0 号平面表示的字符范围是 U+0000 - U+FFFF。

UTF-8 是用一至四个字节对 Unicode 字符集中的所有有效编码点进行编码。

# 转义

JSON 对第 0 号平面字符的转义规则是，用 "\u" 加上对应字符在特定字符编码下的的四位十六进制。比如 `\` 在 UTF-8 编码后的结果是 `\u005c`

在第 0 号平面外的字符，会用类似 `\uD834\uDD1E` 的形式。

可选的，对一些比较流行的字符，可以通过添加 `\` 来转义:

```
 "    quotation mark  U+0022
 \    reverse solidus U+005C
 /    solidus         U+002F
 b    backspace       U+0008
 f    form feed       U+000C
 n    line feed       U+000A
 r    carriage return U+000D
 t    tab             U+0009
```

比如 `/` 可以用 `\/` 来表示转义。这就说明了为什么会出现 "http:\/\/" 这种情况。

# 实现

知道了原理，我们可以自己去对字符串做转义了。


根据上文
> 所有的 unicode 字符可以被双引号包围，除了一些必须被转义的字符：双引号，反斜杠，和控制字符(U+0000 到 U+001F)

很显然，这些字符在 ascii 范围内，属于第 0 平面，所以可以用 `\u{xxxx}` 的形式转义。然后对一些流行字符用加上 `\` 前缀的形式处理。

## UTF-8
**Unicode 和 UTF-8 之间的转换关系表 ( x 字符表示码点占据的位 )**

| 码点的位数 | 码点起值  |  码点终值  | 字节序列 |   Byte 1   |   Byte 2   |   Byte 3   |   Byte 4   |   Byte 5   |   Byte 6   |
| :--------: | :-------: | :--------: | :------: | :--------: | :--------: | :--------: | :--------: | :--------: | :--------: |
|     7      |  U+0000   |   U+007F   |    1     | `0xxxxxxx` |            |            |            |            |            |
|     11     |  U+0080   |   U+07FF   |    2     | `110xxxxx` | `10xxxxxx` |            |            |            |            |
|     16     |  U+0800   |   U+FFFF   |    3     | `1110xxxx` | `10xxxxxx` | `10xxxxxx` |            |            |            |
|     21     |  U+10000  |  U+1FFFFF  |    4     | `11110xxx` | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` |            |            |
|     26     | U+200000  | U+3FFFFFF  |    5     | `111110xx` | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` |            |
|     31     | U+4000000 | U+7FFFFFFF |    6     | `1111110x` | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` | `10xxxxxx` |

U+0000-U+007F 是我们需要转义的字符范围（ascii）。在 UTF-8 会被编码到一个字节，用 `0xxxxxxx` 二进制形式表示。

## 代码

所以思路是遍历这些 UTF-8 字节流，替换成转义后的 UTF-8 字节流，再转回字符串：

需要处理的字符范围是 0x00-0x7f（ascii 范围），可以在终端输入 `man ascii` 查看 ascii 码位十六进制表示。
其中 0x00-0x1f 是控制字符，但我们不会对其中所有的字符用 `\uxxxx` 形式转义，因为 0x08,0x09,0x0a,0x0c,0x0d 需要加上反斜杠转义。


这是可以反斜杠转义的字符，我代码中没有处理 "/":

```
 "    quotation mark  U+0022
 \    reverse solidus U+005C
 /    solidus         U+002F
 b    backspace       U+0008
 f    form feed       U+000C
 n    line feed       U+000A
 r    carriage return U+000D
 t    tab             U+0009
```


```swift
/// 1. 如果是 `0x00...0x07, 0x0b, 0x0e...0x1f` 范围内，就编码到 `\uxxxx` 字符串，再转回 UTF-8 字节。
/// 2. 反斜杠转义的字符，通过插入 `0x5c`(反斜杠) 字节。
private func escapeString(val: String) -> String {
	var result = [UInt8]()

	for unit in val.utf8 {
		switch unit {
		case 0x00...0x07, 0x0b, 0x0e...0x1f: // \u0000...\u0007, \u000b, \u000e...\u001f
			let str = String(format: "\\u00%02x", unit)
			result.append(contentsOf: Array(str.utf8))
		case 0x22:
			result.append(contentsOf: [0x5c, 0x22])
		case 0x5c:
			result.append(contentsOf: [0x5c, 0x5c])
		case 0x08:
			result.append(contentsOf: [0x5c, 0x62])
		case 0x09:
			result.append(contentsOf: [0x5c, 0x74])
		case 0x0a:
			result.append(contentsOf: [0x5c, 0x6e])
		case 0x0c:
			result.append(contentsOf: [0x5c, 0x66])
		case 0x0d:
			result.append(contentsOf: [0x5c, 0x72])
		default:
			result.append(unit)
		}
	}

	return String(bytes: result, encoding: .utf8)!
}
```



demo 中单元测试，有转义的示例



