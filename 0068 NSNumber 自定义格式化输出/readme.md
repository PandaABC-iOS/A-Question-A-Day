对一个 NSNumber 的格式化输出，可以用 `stringValue` 方法，也可以用 `NSNumberFormatter`。
但是如果要精确控制输出的格式，就需要自己写一个格式化方法了。

这里也是对 JSON 格式化 `NSNumber` 的一次调查，通过阅读 [JSONKit](https://github.com/johnezang/JSONKit/blob/82157634ca0ca5b6a4a67a194dd11f15d9b72835/JSONKit.m#L2725) 这个第三方 JSON 序列化库的源码对 `NSNumber` 的处理，来猜测 `NSJSONSerialization` 的格式化行为。


# NSNumber

NSNumber 有一个 objCType 方法，可以看到具体编码的类型。

| Code |                           Meaning                            |
| :--: | :----------------------------------------------------------: |
| `c`  |                           A `char`                           |
| `i`  |                           An `int`                           |
| `s`  |                          A `short`                           |
| `l`  | A `long` `l` is treated as a 32-bit quantity on 64-bit programs. |
| `q`  |                        A `long long`                         |
| `C`  |                      An `unsigned char`                      |
| `I`  |                      An `unsigned int`                       |
| `S`  |                     An `unsigned short`                      |
| `L`  |                      An `unsigned long`                      |
| `Q`  |                   An `unsigned long long`                    |
| `f`  |                          A `float`                           |
| `d`  |                          A `double`                          |


# 整型

```objc
// 保存整型数字的字符数组
char anum[256], *aptr = &anum[255];
// 8 字节大小
unsigned long long ullv;

if (ullv < 10ULL) {
  // '0' 的 ascii 值是 48，相加是为了把数字变成 ascii 码值
	*--aptr = ullv + '0';
} else {
	while (ullv > 0ULL) {
		*--aptr = (ullv % 10ULL) + '0';
		ullv /= 10ULL;
	}
}

if (isNegative) {
	*--aptr = '-';
}


NSString *str = [NSString stringWithUTF8String:aptr];
     
```

# 浮点数

```objc
double dv;
if (CFNumberGetValue((CFNumberRef)number, kCFNumberDoubleType, &dv)) {
	// 超出了浮点数的范围，NaN or Infinity
	if (!isfinite(dv)) {
		return nil;
	}

	char buffer[255];
	// 小数点后舍入到 17 位
  // 
  // g 的意思是去掉尾部的空格
  // 会用 e 的格式来表示，如果指数小于 -4 或大于等于精度
  // 小数点后至少有一位数字，才会显示小数点 "."
	sprintf(buffer, "%.17g", dv);
	
	return [NSString stringWithUTF8String:buffer];
}
```



# 测试

```objc
- (void)testExample {
    XCTAssert([[self _format:@42] isEqualToString:@"42"]);
    XCTAssert([[self _format:@-42] isEqualToString:@"-42"]);
    XCTAssert([[self _format:@0.1] isEqualToString:@"0.10000000000000001"]);
}
```

