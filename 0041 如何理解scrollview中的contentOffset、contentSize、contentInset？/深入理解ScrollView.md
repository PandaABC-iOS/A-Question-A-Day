## UIView 渲染过程

### Rasterization（光栅化）

光栅化简单的说就是产生一组绘图指令并且生成一张图片。

一旦每个视图都产生了自己的光栅化图片，这些图片便被一个接一个的绘制，并产生一个屏幕大小的图片，这便是上文所说的组合。视图层级对于组合如何进行扮演了很重要的角色：一个视图的图片被组合在它父视图的图片上面。然后，组合好的图片被组合到父视图的父视图图片上面。

在光栅化步骤中，视图并不关心即将发生的组合步骤。也就是说，它并不关心自己的frame（这是用来放置视图图像的位置）或自己在视图层级中的位置（这是决定组合的顺序）。视图只关心一件事，就是绘制它自己的content。这个绘制发生在每个视图的`drawRect:`方法中。

在`drawRect:`方法被调用前，会为视图创建一个空白的图片来绘制content。这个图片的坐标系统是视图的bounds。如果你的绘制超出了视图的bounds。那么超出的部分就不属于光栅化图片的部分了，并且会被丢弃。

**因为iOS处理组合方法的原因，你可以将一个子视图渲染在其父视图的bounds之外，但是光栅化期间的绘制不可能超出一个视图的bounds**

### Composition（合成）

1. 从UIWindow到整个视图层级中有多个视图，每个视图都会执行光栅化
2. 将光栅化后的每一张图，绘制到一起，产生用户最终看到的效果
3. 一个视图绘制和它的父视图绘制到一起时，如何决定位置呢？

```objective-c
CompositedPosition.x = View.frame.origin.x - Superview.bounds.origin.x
CompositedPosition.y = View.frame.origin.y - Superview.bounds.origin.y
```

![截屏2020-04-30下午5.25.14](https://tva1.sinaimg.cn/large/007S8ZIlly1gebx5f575cj30c806l0tv.jpg)

## ScrollView中的几个重要概念

### `contentOffset`

> The point at which the origin of the content view is offset from the origin of the scroll view.

**以content view坐标系为坐标系，scrollview的原点的值**

1. 要让视图里的内容可以滚动，最容易想到的直接修改内容视图的frame.origin

2. 如果有多个子视图，修改每个视图的坐标会很麻烦

3. 修改父视图的bounds的origin会导致绘制的所有子视图位置都发生改变，所以，要让内容滚动，那就得改bounds

4. **修改contentOffset就是在修改scrollview.bounds.origin**

5. 

   ```objective-c
   contentOffset的范围：
   - UIEdgeInset.left ≤ x ≤ UIEdgeInset.right + scrollView.contentSize.x - scrollView.width
   - UIEdgeInset.top ≤ y ≤ UIEdgeInset.bottom + scrollView.contentSize.y - scrollView.heigth
   ```

### `contentSize`

> The size of the content view.

定义了可滚动区域。默认的contentSize为CGSize.zero。用户是不可以滚动的，但是scrollView仍然会显示出bounds范围内所有的子视图。当contentSize设置为比bounds大的时候，用户就可以滚动视图了。

![截屏2020-04-30下午6.00.47](https://tva1.sinaimg.cn/large/007S8ZIlly1geby6g7ljuj30fy0eq75s.jpg)

### `contentInset`

> The custom distance that the content view is inset from the safe area or scroll view edges.

1. 在滚动的内容与scrollView边界之间添加一些空白，当contentInset为正时，滚动内容不再是只能到达scrollView的原点，而是可以到达scrollView内部且距离边界有空白。
2. 当contentInset(top)为正时，contentOffset的y值就成了负值。
3. 当contentInset(bottom)为正时，增加了底部可显示的区域。contentOffset的y为正。
4. 设置contentInset并不会改变ContentSize。

## 位置相关基础概念

### `bounds`

> The bounds rectangle, which describes the view’s location and size in its own coordinate system.

### `frame`

> The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.

frame是根据bounds/position/transform计算而来。

frame实际上代表了覆盖在图层旋转之后的整个轴对齐的矩形区域。也就是说frame的宽高和bounds的宽高不一定一致。

![截屏2020-04-30下午7.33.34](https://tva1.sinaimg.cn/large/007S8ZIlly1gec0uwzfy6j30kt0f6whd.jpg)

### `center` 和 `position`

相对于父图层`anchorPoint`所在的位置。

### `anchorPoint`

![截屏2020-04-30下午7.35.58](https://tva1.sinaimg.cn/large/007S8ZIlly1gec0xfdxm5j30l30j9dhu.jpg)

## 参考文章

https://www.objc.io/issues/3-views/scroll-view/#tweaking-the-window-with-content-insets

https://zsisme.gitbooks.io/ios-/chapter3/anchor.html