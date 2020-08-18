App 自殺的方法很多，有 assert，precondition 和 fatalError 三種，接下來就讓我們好好來研究 App 完全自殺手冊吧。

> **一. assert**

檢查 condition 是否為 true。如果不是 true，App 將閃退並顯示 message。

```swift
func assert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = default, file: StaticString = #file, line: UInt = #line)
```

[assert(_:_:file:line:) — Swift Standard Library | Apple Developer DocumentationPerforms a traditional C-style assert with an optional message.developer.apple.com](https://developer.apple.com/documentation/swift/1541112-assert)

![Image for post](https://miro.medium.com/max/60/1*yzxjRZJyQ3bhsg7v1pugLQ.jpeg?q=20)

![Image for post](https://miro.medium.com/max/2336/1*yzxjRZJyQ3bhsg7v1pugLQ.jpeg)

參數說明:

condition: 想要滿足的條件。

message: 當條件不滿足，App 閃退死掉時顯示的遺言訊息。

例子:

單字 App 需要讀取 vocabulary.txt 顯示單字，如果讀不到，這個 App 基本上就是廢物，沒有活在世上的意義 ! 所以我們利用 assert 檢查 url != nil，當它是 nil 時讓 App 閃退。

```swift
let url = Bundle.main.url(forResource: "vocabulary", withExtension: "txt")assert(url != nil, "no vocabulary.txt")
```

當 url 是 nil 時的閃退畫面。

![Image for post](https://miro.medium.com/max/60/1*-aNdSogNbEj_KD0FUPTqLg.jpeg?q=20)

![Image for post](https://miro.medium.com/max/3608/1*-aNdSogNbEj_KD0FUPTqLg.jpeg)

assert 還有個長得跟它很像的兄弟，assertionFailure，專門用在我們已經事先做過檢查，已經確定要強制 App 閃退的時候。

```swift
func assertionFailure(_ message: @autoclosure () -> String = default, file: StaticString = #file, line: UInt = #line)
```

[assertionFailure(_:file:line:) - Swift Standard Library | Apple Developer DocumentationEdit descriptiondeveloper.apple.com](https://developer.apple.com/documentation/swift/1539616-assertionfailure)

例子:

當分數 < 0 時讓 App 閃退。

```swift
if grade >= 60 {   print("及格了！")} else if grade >= 0 {   print("不及格，但至少分數 >= 0")} else {   assertionFailure("< 0 的分數")}
```

> **二. precondition**

看來使用 assert 已經可以讓 App 成功自殺，我們為何還要學習 precondition 呢 ?

precondition 功能跟 assert 差不多，同樣分兩種，有檢查條件是否滿足的 precondition，也有強制閃退的 preconditionFailure。

![Image for post](https://miro.medium.com/max/60/1*daQ5O2m-TSTlQvb3j3G3Sw.jpeg?q=20)

![Image for post](https://miro.medium.com/max/2464/1*daQ5O2m-TSTlQvb3j3G3Sw.jpeg)

[precondition(_:_:file:line:) — Swift Standard Library | Apple Developer DocumentationChecks a necessary condition for making forward progress.developer.apple.com](https://developer.apple.com/documentation/swift/1540960-precondition)

[preconditionFailure(_:file:line:) - Swift Standard Library | Apple Developer DocumentationEdit descriptiondeveloper.apple.com](https://developer.apple.com/documentation/swift/1539374-preconditionfailure)

但它跟 assert 有個主要的差別。assert 只會在 Optimization Level 為 No Optimization(-Onone) 時發揮作用，precondition 則在任何時候都能作用(除非 Optimization Level 為 Ounchecked)。

從 App 的 Build Settings 頁面，我們可看到在 Debug 模式時， Optimization Level 預設為 No Optimization，Release 模式時為 Optimize for Speed，因此 assert 只會在 Debug 模式時發揮作用。

![Image for post](https://miro.medium.com/max/3432/1*RPKUeYWY-8jrtZub4OH3sA.jpeg)

那 App 什麼時候會是 Debug 模式呢 ? 一般當我們從 Xcode 將 App 裝到模擬器或實機時就是 Debug 模式。因為我們會按下三角形的 Run，而從 App 的 Scheme 設定，我們可發現 Run 的 Build Configuration 為 Debug。

![Image for post](https://miro.medium.com/max/684/1*dvzaUViJLmHqbxCa2wuVHA.jpeg)

![Image for post](https://miro.medium.com/max/3484/1*VGV7h-FVMzlHxkRVSJ_6Nw.jpeg)

當我們用 Archive 製作上架或給朋友測試(TestFlight or Ad Hoc)的 App 時，Build Configuration 則是 Release。

![Image for post](https://miro.medium.com/max/3532/1*ww7rrjdNwbKj4t3YfRyKLg.jpeg)

因此只有我們自己開發測試的 App 會因為 assert 死掉，當使用者從 App Store 或 TestFlight 下載 App 時，App 執行到 assert 的程式還是可以活得好好的。

所以到底要用 assert 還是 precondition 呢? 一般在自己開發測試階段，可以搭配 assert 檢查一些最好要滿足的條件，讓 App 提早閃退，提早發現問題。但上架的 App 若無法滿足 assert 描述的條件，則可忽略它，不影響使用者繼續操作 App。

然而若有一定要滿足，當條件不滿足 App 不該繼續操作的情況，則搭配 precondition，讓它可以作用在開發和上架的 App，比方以下 switch 檢查分數的例子，分數小於 0 的情況永遠不該發生，所以跑到 default 時用 preconditionFailure 讓 App 自殺。

```swift
switch grade {
  case 60...100:   print("及格了！")
  case 0...60:   print("不及格，但至少分數 >= 0")
  default:   preconditionFailure("< 0 的分數")
}
```

> **三. fatalError**

強制 App 自殺閃退。

```swift
func fatalError(_ message: [@autoclosure](http://twitter.com/autoclosure) () -> String = default, file: StaticString = #file, line: UInt = #line) -> Never
```

[fatalError(_:file:line:) - Swift Standard Library | Apple Developer DocumentationEdit descriptiondeveloper.apple.com](https://developer.apple.com/documentation/swift/1538698-fatalerror)

fatalError 跟 assertionFailure，preconditionFailure 類似，都能讓 App 自殺。主要的差別在它不受 optimization level 的影響，因此它會同時作用在測試和上架的 App。

什麼時候會用到 fatalError 呢 ? Apple 提到我們可以在開發階段，在一些還未實作的功能寫 `fatalError("Unimplemented")` ，如此到時 App 執行到此處閃退，即可提醒我們要補上之前尚末完成的功能。

Apple 文件的英文描述

```swift
You can use the fatalError(_:file:line:) function during prototyping and early development to create stubs for functionality that hasn’t been implemented yet, by writing fatalError("Unimplemented") as the stub implementation. Because fatal errors are never optimized out, unlike assertions or preconditions, you can be sure that execution always halts if it encounters a stub implementation.
```