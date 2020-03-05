# iOS开发如何适配暗黑模式（Dark Mode）

### 原理

1. 将同一个资源，创建出两种模式的样式。系统根据当前选择的样式，自动获取该样式的资源
2. 每次系统更新样式时，应用会调用当前所有存在的元素调用对应的一些重新方法，进行重绘视图，可以在对应的方法做相应的改动

### 资源文件适配

1. 创建一个Assets文件（或在现有的Assets文件中）
2. 新建一个图片资源文件（或者颜色资源文件、或者其他资源文件）
3. 选中该资源文件， 打开 Xcode ->View ->Inspectors ->Show Attributes Inspectors （或者Option+Command+4）视图，将`Apperances` 选项 改为`Any，Dark`
4. 执行完第三步，资源文件将会有多个容器框，分别为 `Any Apperance` 和 `Dark Apperance`. `Any Apperance` 应用于默认情况（Unspecified）与高亮情况（Light）， `Dark Apperance` 应用于暗黑模式（Dark）
5. 代码默认执行时，就可以正常通过名字使用了，系统会根据当前模式自动获取对应的资源文件

<table><tr><td bgcolor=red>注意: 同一工程内多个Assets文件在打包后，就会生成一个Assets.car 文件，所以要保证Assets内资源文件的名字不能相同</td></tr></table>
### 如何在代码里进行适配颜色（UIColor）

```css
+ (UIColor *)colorWithDynamicProvider:(UIColor * (^)(UITraitCollection *))dynamicProvider API_AVAILABLE(ios(13.0), tvos(13.0)) API_UNAVAILABLE(watchos);
- (UIColor *)initWithDynamicProvider:(UIColor * (^)(UITraitCollection *))dynamicProvider API_AVAILABLE(ios(13.0), tvos(13.0)) API_UNAVAILABLE(watchos);
```

e.g.

```kotlin
[UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
    if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
        return UIColorRGB(0x000000);
    } else {
        return UIColorRGB(0xFFFFFF);
    }
 }];
```

### 系统调用更新方法，自定义重绘视图

当用户更改外观时，系统会通知所有window与View需要更新样式，在此过程中iOS会触发以下方法, [完整的触发方法文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fappkit%2Fsupporting_dark_mode_in_your_interface%3Fchanges%3Dlatest_minor)

#### UIView

```css
traitCollectionDidChange(_:)
layoutSubviews()
draw(_:)
updateConstraints()
tintColorDidChange()
```

#### UIViewController

```css
traitCollectionDidChange(_:)
updateViewConstraints()
viewWillLayoutSubviews()
viewDidLayoutSubviews()
```

#### UIPresentationController

```css
traitCollectionDidChange(_:)
containerViewWillLayoutSubviews()
containerViewDidLayoutSubviews()
```

### [如何不进行系统切换样式的适配](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fappkit%2Fsupporting_dark_mode_in_your_interface%2Fchoosing_a_specific_interface_style_for_your_ios_app%3Fchanges%3Dlatest_minor)

> 注意
>  苹果官方强烈建议适配 暗黑模式（Dark Mode）此功能也是为了开发者能慢慢将应用适配暗黑模式

#### 全局关闭暗黑模式

1. 在Info.plist 文件中，添加`UIUserInterfaceStyle` key 名字为 `User Interface Style` 值为String，
2. 将`UIUserInterfaceStyle` key 的值设置为 `Light`

#### 单个界面不遵循暗黑模式

1. UIViewController与UIView 都新增一个属性 `overrideUserInterfaceStyle` 

2. 将  `overrideUserInterfaceStyle` 设置为对应的模式，则强制限制该元素与其子元素以设置的模式进行展示，不跟随系统模式改变进行改变 

    * 设置 ViewController 的该属性， 将会影响视图控制器的视图和子视图控制器采用该样式
    * 设置 View 的该属性， 将会影响视图及其所有子视图采用该样式
    * 设置 Window 的该属性， 将会影响窗口中的所有内容都采用样式，包括根视图控制器和在该窗口中显示内容的所有演示控制器（UIPresentationController）



## [暗黑模式](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fappkit%2Fsupporting_dark_mode_in_your_interface%3Fchanges%3Dlatest_minor)
