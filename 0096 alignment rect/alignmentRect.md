在自动布局中，我们可能会认为约束是使用 `frame` 来确定视图的大小和位置的，但实际上，它使用的是 **对齐矩形**（alignment rect）。在大多数情况下，`frame` 和 `alignment rect` 是相等的，所以我们这么理解也没什么不对。

那么为什么是使用 `alignment rect`，而不是 `frame` 呢？

有时候，我们在创建复杂视图时，可能会添加各种装饰元素，如：阴影，角标等。为了降低开发成本，我们会直接使用设计师给的切图。如下所示：

[![img](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/blog-images/alignment-rect.png?x-oss-process=image/resize,w_800)](https://chuquan-public-r-001.oss-cn-shanghai.aliyuncs.com/blog-images/alignment-rect.png?x-oss-process=image/resize,w_800)

其中，(a) 是设计师给的切图，(c) 是这个图的 `frame`。显然，我们在布局时，不想将阴影和角标考虑进入（视图的 `center` 和底边、右边都发生了偏移），而只考虑中间的核心部分，如图 (b) 中框出的矩形所示。

对齐矩形就是用来处理这种情况的。`UIView` 提供了方法可以实现从 `frame` 得到 `alignment rect` 以及从 `alignment rect` 得到 `frame`。

```
// The alignment rectangle for the specified frame.
- (CGRect)alignmentRectForFrame:(CGRect)frame;

// The frame for the specified alignment rectangle.
- (CGRect)frameForAlignmentRect:(CGRect)alignmentRect;
```

此外，系统还提供了一个简便方法，有 `UIEdgeInsets` 指定 `frame` 和 `alignment rect` 的关系。

```
// The insets from the view’s frame that define its alignment rectangle.
- (UIEdgeInsets)alignmentRectInsets;
```

如果希望 `alignment rect` 比 `frame` 的下边多 `10` 个点，可以这些写：

```
- (UIEdgeInsets)alignmentRectInsets {
    return UIEdgeInsetsMake(.0, .0, -10.0, .0);
}
```