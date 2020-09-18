###### 1、在用OC写代码时，我们使用PCH统一导入在绝大部分地方需要使用到的三方库和一些宏定义，比如导入网络请求，图片加载，然后设置屏幕尺寸，Debug之类的

test.pch

```cpp
#ifndef PrefixHeader_pch
#define PrefixHeader_pch

//一些大部分类需要用的三方库
#import "AFNetworking.h"
#import "Masonry.h"
...

//debug
#ifdef DEBUG
#define ZHYLog(fmt,...) NSLog((@"\n方法: %s \n行号: %d \n打印信息:" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define ZHYLog(...)
#endif

//size
#define  ScreenH  [UIScreen mainScreen].bounds.size.height
#define  ScreenW  [UIScreen mainScreen].bounds.size.width
#define  ViewH self.view.height
#define  ViewW self.view.width


#endif

/* PrefixHeader_pch */
```

###### 2、或者我们开始OC和Swift混编了，我们依然可以在`xxx-Bridging-Header.h`,中导入第三方框架到Swift中使用

此时在Swift中的宏定义那就只能找个文件直接let了，比如`Const.swift`之类的。

###### 3、当单纯使用Swift写程序时。。。一直使用OC的我找不到怎么统一导入三方库。。。虽然说单独导入也有单独导入的好处。。。但是有时候还是想统一导入某一些库。。比如R.Swift，RxSwift之类在项目中各处都大量使用的库

##### 导入方法一、

再要使用的类头部import

```swift
import Foundation
import MBProgressHUD
import Rswift
```

适合不常用的一些三方库

##### 导入方法二、

自己在要导入的库上方再封装一层，就变成全局导入的了，比如 `MBProgressHUD`,先新建一个HUD.swift,然后在里面：

```go
import Foundation
import MBProgressHUD

    ///弹窗加载提示
    class func show() {
       MBProgressHUD.showAdded(to: viewToShow(), animated: true)
    }
    
    ///隐藏所有弹窗
    class func hide() {
        MBProgressHUD.hide(for: viewToShow(), animated: true)   
    }

    ...
```

这样在需要使用的地方直接按如下示例使用就行，不需要单独导入了

```css
HUD.show()
HUD.hide()
```

##### 导入方法三、

某些自己无法轻松封装的，或者本来已经非常容易使用的库，但是又在项目中大量使用，如我我在项目用到了Then协议库，和R.swift本地资源加载库，很多地方都要用，每个地方都去导入又非常麻烦，那么可以使用`@_exported import`关键字导入,这样就可以全局通用了，比如我在我的`Const.swift`中：

```swift
import Foundation
import UIKit

@_exported import Hue
@_exported import RxSwift
@_exported import RxCocoa
@_exported import Rswift
@_exported import Then

/// RxSwift 回收池
let disposeBag = DisposeBag()
/// 屏幕高度
let zyScreenH = UIScreen.main.bounds.height
/// 屏幕宽度
let zyScreenW = UIScreen.main.bounds.width
```

这样使用就十分方便了