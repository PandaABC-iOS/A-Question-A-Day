# 色彩空间

设计稿中的颜色，比如 `#00A0FF`，是属于 rgb 色彩空间。如果直接在 xib 中使用，色彩会有偏差。

![rgb](./a.png)

正确的做法是在 colorProfile 下选择 srgb，这样是跟用 `UIColor` 代码初始化用的色彩空间是一样的。



