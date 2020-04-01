# CAReplicatorLayer 类

## 介绍

CAReplicatorLayer可以将自己的子图层复制指定的次数，并且被复制比分会保持被复制图层的各种基础属性以及动画

## 效果

利用 CAReplicatorLayer 类可以实现如下效果
![](1.gif)

## 实现方法

具体实现如下：

```objc
// 1.创建一个复制图层对象，设置复制层的属性
CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];

// 1.1.设置复制图层中子层总数：这里包含原始层
replicatorLayer.instanceCount = 8;
// 1.2.设置复制子层偏移量，不包含原始层，这里是相对于原始层的x轴的偏移量
replicatorLayer.instanceTransform = CATransform3DMakeTranslation(45, 0, 0);
// 1.3.设置复制层的动画延迟事件
replicatorLayer.instanceDelay = 0.1;
// 1.4.设置复制层的背景色，如果原始层设置了背景色，这里设置就失去效果
replicatorLayer.instanceColor = [UIColor greenColor].CGColor;
// 1.5.设置复制层颜色的偏移量
replicatorLayer.instanceGreenOffset = -0.1;

// 2.创建一个图层对象  单条柱形 (原始层)
CALayer *layer = [CALayer layer];
// 2.1.设置layer对象的位置
layer.position = CGPointMake(15, self.view.bounds.size.height);
// 2.2.设置layer对象的锚点
layer.anchorPoint = CGPointMake(0, 1);
// 2.3.设置layer对象的位置大小
layer.bounds = CGRectMake(0, 0, 30, 150);
// 2.5.设置layer对象的颜色
layer.backgroundColor = [UIColor whiteColor].CGColor;

// 3.创建一个基本动画
CABasicAnimation *basicAnimation = [CABasicAnimation animation];
// 3.1.设置动画的属性
basicAnimation.keyPath = @"transform.scale.y";
// 3.2.设置动画的属性值
basicAnimation.toValue = @0.1;
// 3.3.设置动画的重复次数
basicAnimation.repeatCount = MAXFLOAT;
// 3.4.设置动画的执行时间
basicAnimation.duration = 0.5;
// 3.5.设置动画反转
basicAnimation.autoreverses = YES;

// 4.将动画添加到layer层上
[layer addAnimation:basicAnimation forKey:nil];

// 5.将layer层添加到复制层上
[replicatorLayer addSublayer:layer];

// 6.将复制层添加到view视图层上
[self.view.layer addSublayer:replicatorLayer];

```

