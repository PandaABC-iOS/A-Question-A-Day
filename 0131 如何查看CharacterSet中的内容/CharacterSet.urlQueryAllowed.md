在翻看Alamofire的源码的过程中，一直很好奇CharacterSet.urlQueryAllowed都包含哪些字符，用常规的po打印的结果是

![Screen Shot 2020-09-05 at 2.11.14 PM](https://tva1.sinaimg.cn/large/007S8ZIlgy1gifqv89onvj30fu01rq35.jpg)

知识的真相驱使着我前行，最终功夫不负有心人，代码如下。

```swift
for scalar in UnicodeScalar.allScalars where CharacterSet.urlQueryAllowed.contains(scalar) {
  print(scalar, terminator: "")
}

extension UnicodeScalar {
  static var allScalars: AnySequence<UnicodeScalar> {
    let numbers = sequence(first: 0, next: { $0 + 1 })
    let scalars = numbers
        .lazy
        .prefix(while: { $0 < 0xFFFF })
        .flatMap(UnicodeScalar.init)

    return AnySequence(scalars)
  }
}
```

打印结果为

![Screen Shot 2020-09-05 at 1.41.02 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1gifq5n3s69j314001gq3k.jpg)