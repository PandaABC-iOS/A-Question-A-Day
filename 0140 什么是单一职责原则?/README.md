## 什么是单一职责原则?

SOLID 是单一职责原则（Single Responsibility Principle）、开闭原则（Open Closed Principle）、里式替换原则（Liskov Substitution Principle）、接口隔离原则（Interface Segregation Principle）、依赖反转原则（Dependency Inversion Principle）的首字母组合而成。



下面介绍一下单一职责原则。



### 单一职责原则



**描述**： A class or module should have a single responsbility

从字面上非常好理解，一个类或者模块应只拥有职责。



从类的层面说上，就是不要设计大而全的类，而是要设计一个粒度小、功能单一的。



这样子做的好处包括：

1. 降低类的复杂度
2. 提高类的可读性和可维护性



这里给出几个一个类可能违背单一职责的规则：

1. 类中代码行数、函数、属性过多时
2. 依赖类的过多
3. 给类命名比较困难
4. 当类中大量的方法都在集中操作类中个别属性时，可以考虑拆分



不过我个人认为这个原则，要根据业务场景进行应用的。

比如在电商业务中，一个类既包含订单的相关方法，又包含对用户的操作，如果是在业务初期，代码量不大的时候，放在一个类中其实问题不大的。

但随着业务代码量膨胀、复杂程度增加，类的可读性、可维护性必然变差，这时候就需要按照单一职责对类进行类的拆分和重构。









