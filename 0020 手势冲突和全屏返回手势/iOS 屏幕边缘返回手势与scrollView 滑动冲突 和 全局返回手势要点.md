### iOS 屏幕边缘返回手势与scrollView 滑动冲突 和 全局返回手势要点: 
#### 右滑手势 和 ScrollView滑动手势冲突.
1. 自定义 ScrollView, 设置`self.panGestureRecognizer.delegate = self`
2. 实现代理方法: `func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool` 改代理方法大意为: 该方法返回YES时，意味着所有相同类型的手势都会得到处理。
3.  在改方法内部, 给出一个`自定义距离`, 判断在改距离内, 并且scrollView的contentOffset.x <= 0 (说明scrollView 是在没有滑动的情况下) 返回true: 表明在这个操作中, 允许多个手势共存, 能够处理多个手势的响应.
4.  优化的点: 此时就在scrollView中, 既可以实现滑动, 又可以实现右滑返回手势. 但是此时右滑返回手势和scrollView的滑动同时生效, 右滑返回时, 可以看到scrollView也在滑动. 这个时候就需要在scrollView的代理方法` func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool ` 中判断, 如果是符合第三点时 返回false, 禁止scrollView的手势. 这个时候右滑返回, scrollView就不会跟着滑动了.
#### 全屏返回手势.
1. 在`baseNavigationController`中, 将系统的`interactivePopGestureRecognizer`移除, 并添加自定义的全屏返回手势.并设置其target action和 delegate
```
 func addFullScreenGesture() {
        let selector = NSSelectorFromString("handleNavigationTransition:")
        fullScreenPopPanGesture = UIPanGestureRecognizer(target: self.interactivePopGestureRecognizer?.delegate, action: selector)
        fullScreenPopPanGesture.delegate = self
        view.addGestureRecognizer(fullScreenPopPanGesture)
        interactivePopGestureRecognizer?.require(toFail: fullScreenPopPanGesture)
        interactivePopGestureRecognizer?.isEnabled = false
    }
```
`handleNavigationTransition`是通过打印返回手势拿到的返回响应的action, 是私有API, 但是此API的使用并不会影响审核(经网友测试发现)

2. 实现`UIGestureRecognizerDelegate`中的ShouldBegin方法, 在ShouldBegin方法中, 判断手势, 和 手势作用的开始点.
```
func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        print(gestureRecognizer)
        guard self.viewControllers.count >= 1 else { return false }
        if gestureRecognizer == fullScreenPopPanGesture {
            let point = fullScreenPopPanGesture.translation(in: view)
            if point.x > 0 {
                return true
            }
            return false
        }
        return true
    }
```

这样子就替换掉了系统对pop的响应方法, 系统响应pop的方法只在屏幕边缘响应, 现在替换成在整个屏幕point.x > 0 就响应.