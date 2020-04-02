# 如何检测项目中是否使用 UIWebView

[Determining which frameworks use UIWebView](https://blog.kulman.sk/determining-which-frameworks-use-uiwebview/)

截止到2020年4月苹果将不再接受包含 UIWebView 的 app ，我们应该使用 WKWebView 替换，那么如何检测项目中有没有使用 UIWebView 呢？

1. 对于项目中的代码可以直接搜索关键字 UIWebView , 或者用 grep 命令

```ruby
❯ grep -r 'UIWebView' .
./RxCocoa/iOS/UIWebView+Rx.swift://  UIWebView+Rx.swift
./RxCocoa/iOS/UIWebView+Rx.swift:    extension Reactive where Base: UIWebView {
./RxCocoa/iOS/UIWebView+Rx.swift:        public var delegate: DelegateProxy<UIWebView, UIWebViewDelegate> {
./RxCocoa/iOS/UIWebView+Rx.swift:                .methodInvoked(#selector(UIWebViewDelegate.webViewDidStartLoad(_:)))
./RxCocoa/iOS/UIWebView+Rx.swift:                .methodInvoked(#selector(UIWebViewDelegate.webViewDidFinishLoad(_:)))
./RxCocoa/iOS/UIWebView+Rx.swift:                .methodInvoked(#selector(UIWebViewDelegate.webView(_:didFailLoadWithError:)))
./RxCocoa/iOS/Proxies/RxWebViewDelegateProxy.swift:extension UIWebView: HasDelegate {
./RxCocoa/iOS/Proxies/RxWebViewDelegateProxy.swift:    public typealias Delegate = UIWebViewDelegate
...
```



2. 对于一些第三方库可能不是直接提供源码，而是以 .framework 或 .a 的方式集成，这个时候可以用 `nm`获取可执行文件的符号表，然后判断其中是否包含 UIWebView

```ruby
❯ nm AWSDK.framework/AWSDK | grep -i UIWebView
                 U _OBJC_CLASS_$_UIWebView
                 U _OBJC_CLASS_$_UIWebView
0000000000002a00 S __OBJC_LABEL_PROTOCOL_$_UIWebViewDelegate
0000000000002998 D __OBJC_PROTOCOL_$_UIWebViewDelegate
0000000000002348 s l_OBJC_$_PROTOCOL_INSTANCE_METHODS_OPT_UIWebViewDelegate
00000000000023b0 s l_OBJC_$_PROTOCOL_METHOD_TYPES_UIWebViewDelegate
0000000000002330 s l_OBJC_$_PROTOCOL_REFS_UIWebViewDelegate
000000000000aaa0 S __OBJC_LABEL_PROTOCOL_$_UIWebViewDelegate
000000000000a858 D __OBJC_PROTOCOL_$_UIWebViewDelegate
0000000000005780 s l_OBJC_$_PROTOCOL_INSTANCE_METHODS_OPT_UIWebViewDelegate
00000000000057e8 s l_OBJC_$_PROTOCOL_METHOD_TYPES_UIWebViewDelegate
0000000000005768 s l_OBJC_$_PROTOCOL_REFS_UIWebViewDelegate
AWSDK.framework/AWSDK(UIWebView+LongPress.o):
...
```



