# IB 添加自定义 View

Interface Builder 绘制一般的 View 确实挺方便，但在复用方面就比较麻烦。

比如自己用 xib 绘制了一个自定义按钮，里面有一些 subview。当你想在 parent xib 里用这个 xib，发现只会添加一个普通的 UIView，subView 都没有被创建。
我猜测是在 xib 添加子 xib（设置 custom class） 时，系统只会调用 `initWithCoder:` 方法，并不会添加 subview，只有 `Bundle.main.loadNibNamed:` 才会。

有一种做法是添加额外一层 view，在代码中载入自定义 xib。不过还是需要再设置一边约束或布局，其实还是挺麻烦的，还添加了额外的 view。

其实我还是倾向不用 xib 连接自定义 xib，而是用 `Bundle.main.loadNibNamed:` 代码连接和设置布局。