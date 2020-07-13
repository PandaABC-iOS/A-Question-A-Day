Auto Layout 翻译过来就是自动布局。在ios中Auto Layout 会根据我们在视图上所设置的约束来动态地计算视图层次中所有视图的大小和位置。即使我们使用不同尺寸的手机屏幕，或者横屏竖屏展示我们的页面，自动布局总是能够适应这些变化，让页面上的元素按照我们想要的样子展示出来。Auto Layout 内容很多，包括：UIStackView、UILayoutGuide、NSLayoutConstraint、NSLayoutAnchor、SizeClasses、Constraints in Interface Builder等，本文主要介绍的是 NSLayoutConstraint。

##### 使用代码为控件添加约束主要有分为以下两个步骤：

###### 步骤1： 实例化一个 NSLayoutConstraint 约束对象；

###### 步骤2： 使步骤1中生成的约束生效

使用代码创建 NSLayoutConstraint 最核心的步骤就是上面两步。下面会详细进行说明。

### 1.实例化一个 NSLayoutConstraint 约束对象

创建 NSLayoutConstraint 对象最常用的方法是：

```objectivec
+(instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(nullable id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
```

NSLayoutConstraint 是界面上两个视图对象之间的关系，必须满足于基于约束的布局系统。这个系统刚好构成一个线性方程，格式如下：

```undefined
view1.attribute1 = multiplier × view2.attribute2 + constant
```

这个方法中包含七个参数，下面分别解释一下：

- view1: 要约束的视图
- attr1: 约束的类型，是一个 NSLayoutAttribute 常量，有如下几个值，根据名字也可以看出这些值代表的意义，这里不再赘述。

```objectivec
typedef NS_ENUM(NSInteger, NSLayoutAttribute) {
  NSLayoutAttributeLeft = 1, 
  NSLayoutAttributeRight,
  NSLayoutAttributeTop,
  NSLayoutAttributeBottom,
  NSLayoutAttributeLeading,
  NSLayoutAttributeTrailing,
  NSLayoutAttributeWidth,
  NSLayoutAttributeHeight,
  NSLayoutAttributeCenterX,
  NSLayoutAttributeCenterY,
  NSLayoutAttributeLastBaseline,
  NSLayoutAttributeBaseline NS_SWIFT_UNAVAILABLE("Use 'lastBaseline' instead") = NSLayoutAttributeLastBaseline,
  NSLayoutAttributeFirstBaseline NS_ENUM_AVAILABLE_IOS(8_0),
  
  
  NSLayoutAttributeLeftMargin NS_ENUM_AVAILABLE_IOS(8_0),
  NSLayoutAttributeRightMargin NS_ENUM_AVAILABLE_IOS(8_0),
  NSLayoutAttributeTopMargin NS_ENUM_AVAILABLE_IOS(8_0),
  NSLayoutAttributeBottomMargin NS_ENUM_AVAILABLE_IOS(8_0),
  NSLayoutAttributeLeadingMargin NS_ENUM_AVAILABLE_IOS(8_0),
  NSLayoutAttributeTrailingMargin NS_ENUM_AVAILABLE_IOS(8_0),
  NSLayoutAttributeCenterXWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
  NSLayoutAttributeCenterYWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
  
  NSLayoutAttributeNotAnAttribute = 0
};
```

- relation: 与参照视图 view2 之间的关系，是一个 NSLayoutRelationEqual 常量，包括等于、大于等于、小于等于



```objectivec
typedef NS_ENUM(NSInteger, NSLayoutRelation) {
    NSLayoutRelationLessThanOrEqual = -1,  // 小于等于 <=
    NSLayoutRelationEqual = 0,      // 等于 =
    NSLayoutRelationGreaterThanOrEqual = 1,    // 大于等于 <=
};
```

- view2: 参照的视图
- attr2: view2 的约束类型，是一个 NSLayoutAttribute 常量，具体值和 attr1 中的列出来的一样
- multiplier: 乘数，倍数关系
- c: 常量，约束值

了解了计算公式和七个参数分别代表的意义，我们可以结合苹果给出的样本图加深理解：![Screen Shot 2020-07-13 at 1.40.34 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1ggpaij0e5gj312q0hs789.jpg)

从图中可以看出蓝色按钮和红色按钮的左右间距为8，根据所给出的公式我们很容易创建这样一个 NSLayoutConstraint 实例，创建的代码如下：



```objectivec
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.redView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.blueView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
```

约束创建好了，接下来就是如何添加正确的添加约束了。

### 2. 使创建好的约束生效

不同的约束要添加到相应的视图上，只有添加正确约束才能生效，添加错误的话程序会crash。当然也可以直接使用属性 active 来使约束生效，这样不需要考虑要将约束具体添加到哪一个视图上，但我觉得我们有必要理清楚约束的正确添加原理，在实际项目中具体使用哪种方法使约束生效，依个人喜好而定。

#### 2.1 添加约束的原理分析及结论

添加或移除约束的涉及到的方法为：

```objectivec
// 添加单个约束， 等价于接下来2.2 介绍的 constraint. active = YES.
- (void)addConstraint:(NSLayoutConstraint *)constraint NS_AVAILABLE_IOS(6_0); 
// 添加多个约束， 等价于接下来2.2 介绍的 +[NSLayoutConstraint activateConstraints:].
- (void)addConstraints:(NSArray<__kindof NSLayoutConstraint *> *)constraints NS_AVAILABLE_IOS(6_0);
// 移除单个约束， 等价于接下来2.2 介绍的 constraint. active = NO.
- (void)removeConstraint:(NSLayoutConstraint *)constraint NS_AVAILABLE_IOS(6_0); 
// 移除多个约束， 等价于接下来2.2 介绍的 +[NSLayoutConstraint deactivateConstraints:].
- (void)removeConstraints:(NSArray<__kindof NSLayoutConstraint *> *)constraints NS_AVAILABLE_IOS(6_0); 
```

方法介绍完，但添加到哪一个视图上才是更需要了解的，下面主要就是分析创建好的约束具体要添加到哪一个视图上。

实际开发中能用storyboard设置的约束使用代码都可以做到,而且在某些方面使用代码设置约束反而更加灵活，为了弄清楚用代码创建好的约束要在那个视图上添加，我们这里可以分析一下使用storyboard创建好的约束苹果自动为我们添加到了哪一个视图上，通过类比，可以让我们更快速的地搞清楚这个问题：

首先需要实现的页面效果如下图,页面中的三个小图从左到右依次为 View1 、View2 、View3 ,每个视图上都包含一个属于自己的button:![Screen Shot 2020-07-13 at 1.41.48 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1ggpaorzdetj30lm08wgm3.jpg)

##### 2.1.1 为view1添加不依赖于view2的约束（ 如view1 的宽高约束，此时 view2 = nil ,attr2 = NSLayoutAttributeNotAnAttribute ）

- 分析

![Screen Shot 2020-07-13 at 1.42.24 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1ggpak8wn3wj31260bqdnh.jpg)

我们为图中 view1 添加宽高约束，如图中蓝色背景选中的约束所示，可以看出：为view1添加的 width约束 和 height 约束，均被包含在vew1的约束下。也就是说这两个约束被添加到了view1上。

- 结论：

###### 在使用代码添加约束时，如果为 view1 添加约束，该约束并不依赖于view2,  此时约束要添加到 view1上。比如常见的宽、高约束就是这类型约束。

------

##### 2.1.2  view1 和 view2 有高低层级关系（比如为 view1 中的 button 添加依赖于view1的约束，要求 button 在 view1 上Y 方向居中、X 方向居中）

- 分析：

![Screen Shot 2020-07-13 at 1.43.01 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1ggpakzcb2sj31260fyn5e.jpg)

根据上图可以看出：button 在 view1 上 Y 方向居中、X 方向居中，这两个约束依赖的视图有两个: 一个是 button 本身，另一个就是 button的父视图 view1。button 和 view1 具有层级关系，view1 的层级高于button,  结合上图蓝色背景选中的约束可以发现创建好的约束依旧被添加到了在 vew1 上。

- 结论

###### 在使用代码添加约束时，如果为view1添加约束，该约束依赖于view2, 而且view1 和 view 2 有高低层级关系，那么将创建好的约束添加到层级较高的那一个视图上。

------

##### 2.1.3 view1 和 view2 属于同一层级， 具有相同的父视图。（如为下图的view1 和 view2 添加等高约束，为 view2 和 view3 添加中心点在Y方向上相同）

- 分析

![Screen Shot 2020-07-13 at 1.43.49 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1ggpalpbpx5j310m0i4tjr.jpg)

对于view1 和 view2 的等高约束来说：他依赖于两项，一项是view1, 一项是vew2。view2 和 view3 的中心点在Y方向上相同的约束， 他也依赖于两项，一项是view2, 一项是view3。再看他们之间的关系：view1 和 view2 是同一个层级的兄弟视图，view2 和 view3 也是同一个层级的兄弟视图, 具有相同的父视图。结合上图蓝色背景选中的约束可以发现创建好的约束依旧被添加到了包含view1、view2、view3的最外层的父视图 view 上。

- 结论

###### 在使用代码添加约束时，如果为view1添加约束，该约束依赖于view2。而且view1 和 view 2 属于同一层级，他们具有相同的父视图，那么将创建好的约束添加它们的父视图上。即：A->B->(C、D)： C、D同层级，约束要添加到B上

------

##### 2.1.4 view1 和 view2 属于不同的层级 （如下图的 view1 上的button 和 view2 上的button, 他们属于不同的层级， 在这里为这两个 button 添加等宽约束）

##### ![Screen Shot 2020-07-13 at 1.44.14 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1ggpaoqi877j310g0iqtbg.jpg)

根据上图可以看出：view1 上的 button 和 view2 上的 button 属于不同的层级，为这两个button所添加的这个等宽约束依赖于两项，分别为这两个button。但该约束却被添加到了包含他们父视图view1、view2的那个更大的父视图 view 上。

- 结论

###### 在使用代码添加约束时，如果为view1添加约束，该约束依赖于view2。而且view1 和 view 2 属于不同层级，那么将创建好的约束添加到离它们最近的那个父视图上。即：

###### A->B->E

###### A->C->F

###### E、F属于不同层级，A是离它们最近的那个父视图上， 所以约束要添加到A上

------

好了，到此为止，已经列举了使用代码添加约束的几种不同的情况，根据上面的结论就可以知道实际情况中所创建的约束具体要添加到哪个视图上了。

#### 2.2 使约束生效的另一种方式

在第2节的开篇提到过可以使用 active 属性这样的方式使约束生效，这不需要去区分创建好的约束具体要添加到那个视图上面。这种方式主要涉及到以下三个方法：



```objectivec
// 通过设置该属性的值来激活或停用一个约束，默认值为NO
@property (getter=isActive) BOOL active NS_AVAILABLE(10_10, 8_0); 

// 激活数组中的每个约束，与设置active = YES的方式相同。这通常比单独激活每个约束更有效。
+ (void)activateConstraints:(NSArray<NSLayoutConstraint *> *)constraints NS_AVAILABLE(10_10, 8_0);

// 停用数组中的每个约束，与设置 active = NO的方式相同。这通常比单独停用每个约束更有效。
+ (void)deactivateConstraints:(NSArray<NSLayoutConstraint *> *)constraints NS_AVAILABLE(10_10, 8_0);
```

#### 2.3 添加约束的注意事项

- 如果我们的视图的布局方式为autolayout，再添加约束之前要将视图的translatesAutoresizingMaskIntoConstraints属性设为NO
- 最好是将子视图添加到父视图后再添加约束，例如上文的为view1中的button 添加垂直水平居中的约束，该约束是被添加到view1上的。此时要保证 button 在 view1 中,也就是 [view1 addSubview:button ];，之后再添加约束；如果不这样做，程序会crash。

### 3.应用

#### 3.1  目标实现效果

实现一个效果：页面上有两个视图，一个紫色视图，另一个是蓝色视图，这两个视图等大，而且它们在X方向上居中显示，紫色视图距离顶部100，蓝色视图在Y方向上距离紫色视图的距离也是100。如下图所示：

![Screen Shot 2020-07-13 at 1.45.08 PM](https://tva1.sinaimg.cn/large/007S8ZIlly1ggpan66rh6j30le0pw0tz.jpg)

#### 3.2 实现代码

```objectivec
- (void)setViewConstraint {
    UIView *purpleView = [[UIView alloc] init];
    purpleView.backgroundColor = [UIColor purpleColor];
    UIView *blueView = [[UIView alloc] init];
    blueView.backgroundColor = [UIColor blueColor];
    // 1. 禁止将 AutoresizingMask 转换为 Constraints
    purpleView.translatesAutoresizingMaskIntoConstraints = NO;
    blueView.translatesAutoresizingMaskIntoConstraints = NO;

    // 2. 为防止添加约束过程中程序crash,可以先将子视图添加到父视图中
    [self addSubview:purpleView];
    [self addSubview:blueView];

    // 3.为purpleView添加 width 约束和 height 约束
   NSLayoutConstraint *purpleViewWidthConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:100];
    NSLayoutConstraint *purpleViewHeightConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:100];
    [purpleView addConstraint:purpleViewWidthConstraint];   // 可使用purpleViewWidthConstraint.active = YES;替换
    [purpleView addConstraint:purpleViewHeightConstraint];  // 可使用purpleViewHeightConstraint.active = YES;替换

    // 4.为blueView添加 width 约束和 height 约束，有两种方式。第一种是可以直接类似第三步为purpleView添加宽高约束那样添加；第二种方法是参考purpleView的宽高约束，等宽等高即可。(***注意:此时添加的约束一共有blueView 和 purpleView 两项,它们属于同一层级，添加约束时需要将约束添加到它们共同的父类上，也就是self上)
    NSLayoutConstraint *blueViewWidthConstraint = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:purpleView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *blueViewHeightConstraint = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:purpleView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self addConstraint:blueViewWidthConstraint];   // 可使用blueViewWidthConstraint.active = YES;替换
    [self addConstraint:blueViewHeightConstraint];  // 可使用blueViewHeightConstraint.active = YES;替换

    // 5.为purpleView添加距离顶部距离为100的顶部约束，并且在x方向上居中(***注意：此时添加的约束一共有purpleView 和 self 两项,self比purpleView层级要高，添加约束时需要将约束添加到层级较高的视图上，也就是self上)
    NSLayoutConstraint *purpleViewTopConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:100];
    NSLayoutConstraint *purpleViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:purpleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:purpleViewTopConstraint];   // 可使用purpleViewTopConstraint.active = YES;替换
    [self addConstraint:purpleViewCenterXConstraint];   // 可使用purpleViewCenterXConstraint.active = YES;替换

    // 6.为buleView添加Y方向上距离purpleView为100的约束，并且blueView在x方向上居中(***注意：根据4、5中括号内注意的描述，可知这两个约束也是要添加到self上的)
    NSLayoutConstraint *buleViewTopConstraint = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:purpleView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:100];
    NSLayoutConstraint *blueViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:blueView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:buleViewTopConstraint];     // 可使用buleViewTopConstraint.active = YES;替换
    [self addConstraint:blueViewCenterXConstraint];     //  可使用blueViewCenterXConstraint.active = YES;替换
}
```