布局时，如何不遮挡 iPhone 状态栏？

更详细的问题是，如何在不硬编码 status bar 高度的情况下，布局时支持用 frame 和 autolayout 来处理 status bar，并且兼容 iOS 11（不包括） 以下的系统。

状态栏分两种，一种是“刘海屏”，类 iPhone X 型号的 iPhone，一种是其他型号的 iPhone。

iPhone X status Bar 高度为 44，其他为 20。但是对开发者来说，可以不用知道具体的设备。

# iOS 11 及以上 
如果只支持 iOS 11及以上，那么就有一套完美的 API 来用，叫做 `safeAreaLayoutGuide`， 是 view 的属性。


表示的是一个安全的展示区域，不包含状态栏，navigation bar(如果有)，tab bar（如果有），类 iPhoneX 底部（34高度）的区域。

## Autolayout
如果是 autolayout 布局，代码中可以通过访问 `self.view.safeAreaLayoutGuide.topAnchor` 来做顶端的约束。

## frame
如果是代码布局，可以在 `viewDidLayoutSubviews` 或 `layoutSubviews` 中，通过访问 `self.view.safeAreaLayoutGuide.layoutFrame` 来手动修改。
layoutFrame 表示的是一个安全区域的 frame，它的 origin 和 height 与 view 相比会被相应调整。

# 低版本

iOS 11 以下没有这个 `safeAreaLayoutGuide` 这个属性，只有 viewController 的 `topLayoutGuide` 属性来控制到顶端的布局。

## Autolayout
`topLayoutGuide` 不是一个安全区域，它更像是一个在安全区域上方的一个区域。


这个区域可以是 navigation bar（如果内嵌在 navigation controller 中）, status bar（status bar 可见），或者是 viewController 顶部（status bar 隐藏）。

所以需要访问 viewController 的 `self.topLayoutGuide.bottomAnchor` 来做顶端的约束

## frame

在 `viewDidLayoutSubviews`，访问 `self.topLayoutGuide.length` 来得知顶部的高度


# demo
这里有 demo，两个 view 分别采取 autolayout 和 frame 布局，支持 iOS 10 及以上



