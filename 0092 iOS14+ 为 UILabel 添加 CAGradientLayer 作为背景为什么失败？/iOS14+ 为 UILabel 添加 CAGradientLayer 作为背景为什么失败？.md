# iOS14+ 为 UILabel 添加 CAGradientLayer 作为背景为什么失败？

UILabel 添加 CAGradientLayer 处理流程图 

![img](https://user-gold-cdn.xitu.io/2020/7/10/17334e64596acf6d?imageView2/0/w/1280/h/960/format/png)



## 一、包含中文的文本，为何可以实现 CAGradientLayer 作为背景



![img](https://user-gold-cdn.xitu.io/2020/7/10/17334e5a853b5649?imageView2/0/w/1280/h/960/format/png)



如图所示，如果 UILabel 的文本是中文，系统会添加一个 _UILabelContentLayer，将本文绘制在此层。并且会插入到 UILabel.layer.sublayers 的第一位。



![img](https://user-gold-cdn.xitu.io/2020/7/8/1732f0c93b5dd300?imageView2/0/w/1280/h/960/format/png)



这个时候，如果我们把 CAGradientLayer.zPosition 设置为负值，默认的 CALayer.zPosition = 0, 在渲染的时候，就会先渲染渐变层，然后渲染文本层。这就可以实现用一个渐变色作为背景的目的。

## 二、不包含中文的文本，为何不可以实现 CAGradientLayer 作为背景



![img](https://user-gold-cdn.xitu.io/2020/7/8/1732f0c073df6a02?imageView2/0/w/1280/h/960/format/png/ignore-error/1)



如果文本不包含中文，系统会把文本绘制在 UILabel.layer (_UILabelLayer) 层。此层是 CAGradientLayer 的父 layer，无论如何，都会先于 CAGradientLayer 层渲染。因此 CAGradientLayer 层渲染后，会遮盖文本，达不到目的。

## 三、iOS 14+，包含中文的文本，为何又不能实现 CAGradientLayer 作为背景



![img](https://user-gold-cdn.xitu.io/2020/7/8/1732f0c073df6a02?imageView2/0/w/1280/h/960/format/png/ignore-error/1)



在 iOS14+，苹果做了优化，即便文本包含中文，也不会添加 _UILabelContentLayer 层，直接绘制在 _UILabelLayer 层。因此，再也不能实现一个 CAGradientLayer 作为背景了。

## 四、解决方法

只能把 CAGradientLayer 放在 UILabel 的父视图上面，来实现渐变色背景。

## 五、实验代码

```objc
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.label = label;
    [self.view addSubview:self.label];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = label.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[[UIColor redColor] colorWithAlphaComponent:0.8].CGColor];
    gradientLayer.locations = @[@0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    
    [label.layer insertSublayer:gradientLayer atIndex:0];
    
    label.text = @"中文aaaaaaa";
//    label.text = @"aaaaaaaa";
    
    gradientLayer.zPosition = -10;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", self.label.layer);
    NSLog(@"%@", self.label.layer.sublayers);
}

@end
```

> 说明
>  可以分别修改文本类型，zPosition 值，验证文章中的内容。
>  由于 _UILabelContentLayer 不是在设置文本后就创建，而是在绘制文本的时候才创建。
>  因此实现了屏幕点击事件，UILabel 显示之后，点击屏幕在这里输出 layer 结构。



参考链接： https://juejin.im/post/5f05e20b6fb9a07e6b074a19