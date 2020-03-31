# UIView的setNeedsLayout，layoutIfNeeded和layoutSubviews

-  layoutSubviews对subviews重新布局

- 当前View的layoutSubviews方法调用先于当前View的drawRect

- setNeedsLayout在receiver标上一个需要被重新布局的标记，在系统runloop的下一个周期自动调用layoutSubviews //不懂的同学这里可以通过为RunLoop添加监听器, 查看RunLoop的运行状态

- layoutIfNeeded方法如其名，UIKit会判断该receiver是否需要layout.

- layoutIfNeeded遍历的不是superview链，应该是subviews链

- testView 仅仅init初始化不会触发layoutSubviews 但是是用initWithFrame进行初始化时，并且rect的值不为CGRectZero时,并且调用addsubView才会触发 testView的layoutsubviews方法

- 设置testView的Frame会触发 testView layoutSubviews，前提是 testView的frame的size设置前后发生了变化 （前提这个testView已经加入了parentView）。 *** 注意：单单更改testView的位置并不会触发testView以及parentView的layoutsubviews方法

- layoutIfNeeded不一定会调用layoutSubviews方法。setNeedsLayout一定会调用layoutSubviews方法（有延迟，在下一轮runloop结束前）如果想在当前runloop中立即刷新，调用顺序应该是款1. [self setNeedsLayout]; 2.[self layoutIfNeeded]; 反之可能会出现布局错误的问题

- 滚动一个UIScrollview会触发layoutSubviews

- 旋转Screen会触发父UIView上的layoutSubviews

  

  PS：可以自己下载demo 演示一下看看

  

  

  

  

  

  