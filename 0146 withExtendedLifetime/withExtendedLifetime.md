```swift
func testPassthroughSubjectSequence() {
    let expectedResult = [1, 2, 3]
    var actualResult: [Int] = []

    let subject = PassthroughSubject<Int, Never>()
    let unusedButNeeded = subject.sink { actualResult.append($0) }
    for value in expectedResult {
        subject.send(value)
    }

    XCTAssertEqual(actualResult, expectedResult)
}
```

此时代码会发出警告

> Initialization of immutable value 'unusedButNeeded' was never used; consider replacing with assignment to '_' or removing it.

若采纳修复这个警告的建议，将第6行改成`_ = subject.sink { actualResult.append($0) }`

XCTAssert会失败，因为subject在方法结束花括号之前就已经释放了。



而withExtendedLifetime 可以很好的规避这个问题，如下用法可以通过测试。

```
func testPassthroughSubjectSequence() {
    let expectedResult = [1, 2, 3]
    var actualResult: [Int] = []
    
    let subject = PassthroughSubject<Int, Never>()
    withExtendedLifetime(subject.sink { actualResult.append($0) }) {
        for value in expectedResult {
            subject.send(value)
        }
    }
    
    XCTAssertEqual(actualResult, expectedResult)
}
```

