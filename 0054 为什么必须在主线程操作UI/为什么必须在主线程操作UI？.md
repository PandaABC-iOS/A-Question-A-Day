# 为什么必须在主线程操作UI？

在[Thread-Safe Class Design](https://www.objc.io/issues/2-concurrency/thread-safe-class-design/)一文提到：

> It’s a conscious design decision from Apple’s side to not have UIKit be thread-safe. Making it thread-safe **wouldn’t buy you much in terms of performance;**it would in fact make many things slower. And the fact that UIKit is tied to the main thread makes it very easy to write concurrent programs and use UIKit. All you have to do is make sure that calls into UIKit are always made on the main thread

大意为把UIKit设计成线程安全并不会带来太多的便利，也不会提升太多的性能表现，甚至会因为加锁解锁而耗费大量的时间。事实上并发编程也没有因为UIKit是线程不安全而变得困难，我们所需要做的只是要确保UI操作在主线程进行就可以了。

在UIKit中，很多类中大部分的属性都被修饰为`nonatomic`，这意味着它们不能在多线程的环境下工作，而对于UIKit这样一个庞大的框架，将其所有属性都设计为线程安全是不现实的，这可不仅仅是简单的将`nonatomic`改成`atomic`或者是加锁解锁的操作，还涉及到很多的方面：

- 假设能够异步设置view的属性，那我们究竟是希望这些改动能够同时生效，还是按照各自runloop的进度去改变这个view的属性呢？
- 假设`UITableView`在其他线程去移除了一个cell，而在另一个线程却对这个cell所在的index进行一些操作，这时候可能就会引发crash。
- 如果在后台线程移除了一个view，这个时候runloop周期还没有完结，用户在主线程点击了这个“将要”消失的view，那么究竟该不该响应事件？在哪条线程进行响应？

仔细思考，似乎能够多线程处理UI并没有给我们开发带来更多的便利，假如你代入了这些情景进行思考，你很容易得出一个结论： **“我在一个串行队列对这些事件进行处理就可以了。”**苹果也是这样想的，所以UIKit的所有操作都要放到主线程串行执行。

参考文档：https://juejin.im/post/5c406d97e51d4552475fe178

