
使用 Extract Method 将 switch 语句提炼到一个独立函数中，再以Move Method将它搬移到需要多态性的那个类里。此时你必须决定是否使用Replace Type Code with Subclasses 或 Replace Type Code With State/Strategy。一旦这样完成继承结构之后，你就可以运用Replace Conditional with Polymorphism了。
