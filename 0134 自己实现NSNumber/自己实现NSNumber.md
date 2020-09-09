## 自己实现NSNumber

### 第一个思路，NSObject封装NSValue

我们知道NSNumber继承自NSValue,NSValue可以存取所有的基本数据类型，但是NSValue是一个系统抽象类，我没有找到方法通过继承的方式直接利用NSValue的子类对数据进行存取。于是还是创建了NSObject的子类，将NSValue作为成员变量对NSValue存取数据的操作进行封装，实现了NSNumber同样的效果.

### 第二个思路，NSObject封装共用体

代码只做了NSInteger和float的处理，其他数据类型代码相同。

```objectivec
union Data {
    NSInteger integer;
    float f;
};

typedef enum : NSUInteger {
    GLNumberTypeInteger,
    GLNumberTypeFloat
} GLNumberType;

@interface GLNumber ()
@property (nonatomic, assign) GLNumberType type;
@property (nonatomic, assign) union Data data;
@end
@implementation GLNumber 

+ (GLNumber *)numberWithInteger:(NSInteger)value {
    union Data data;
    data.integer = value;
    GLNumber *number = [GLNumber new];
    number.type = GLNumberTypeInteger;
    number.data = data;
    return number;
}

+ (GLNumber *)numberWithFloat:(float)value {
    union Data data;
    data.f = value;
    GLNumber *number = [GLNumber new];
    number.type = GLNumberTypeFloat;
    number.data = data;
    return number;
}

- (NSInteger)integerValue {
    NSInteger data;
    switch (self.type) {
        case GLNumberTypeInteger:
            data = self.data.integer;
            break;
        case GLNumberTypeFloat:
            data = (NSInteger)self.data.f;
            break;
        default:
            break;
    }
    return data;
}

- (float)floatValue {
    NSInteger data;
    switch (self.type) {
        case GLNumberTypeInteger:
            data = (float)self.data.integer;
            break;
        case GLNumberTypeFloat:
            data = self.data.f;
            break;
        default:
            break;
    }
    return data;
}
@end
```