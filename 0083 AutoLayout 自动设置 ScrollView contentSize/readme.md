# AutoLayout 自动设置 UIScrollView contentSize

一般页面都会用 UIScrollView 打底，也会用 AutoLayout 布局，那么设置 scrollview 的 contentSize 也是一个常见的需求。

## 设置 contentSize

1. 固定尺寸

这个情况比较少见

2. 根据内容计算 contentSize

如果每一个界面元素对应的高度是固定的，或者可以方便的只根据 model 属性计算出来。

3. 根据最后一个 subView 的 frame 计算 contentSize

一般最后一个 subView 处于最后面的的位置，在 `layoutSubview` 取它的 frame.maxY 就行。

## 用 Autolayout 设置 contentSize

1. 添加一个 subView，叫它 contentView。
2. 设置约束对其到 scrollView 四边
3. 设置宽度约束到 scrollView 宽度；设置高度约束到 scrollView 高度，优先级非必须
4. 用 autolayout 添加 subView，垂直方向上设置约束到 contentView，那么 contentSize 就会自动计算出来

