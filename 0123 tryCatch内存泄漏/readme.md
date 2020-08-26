try catch 内存泄漏

# 局部变量泄漏

```objc
/// foo 会泄漏
- (void)tryWithLocalVariables {
    NSLog(@"start %s", __func__);
    @try {
        CustomObject *foo = [CustomObject objectWithName:@"tryWithLocalVariables"];
        @throw [NSException exceptionWithName:@"foo-exception"
                                       reason:nil
                                     userInfo:nil];
        NSLog(@"in try %@", foo);
    } @catch (NSException *exception) {
        NSLog(@"catch %@", exception);
    } @finally {
        NSLog(@"finally");
    }
}
```

try catch 外不会泄漏 

```objc
/// foo 不会泄漏
- (void)tryWithLocalVariables2 {
    NSLog(@"start %s", __func__);
    CustomObject *foo = [CustomObject objectWithName:@"tryWithLocalVariables2"];
    @try {
        @throw [NSException exceptionWithName:@"foo-exception"
                                       reason:nil
                                     userInfo:nil];
        NSLog(@"%@", foo);
    } @catch (NSException *exception) {
        NSLog(@"catch %@", exception);
    } @finally {
        NSLog(@"finally %@", foo);
    }
}
```

# KVO 泄漏

```objc
@interface CustomObject : NSObject

+ (instancetype)objectWithName:(NSString *)name;

@property (nonatomic, copy) NSString *name;

- (void)throw;

@end

@interface CustomObject2 : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) CustomObject *object;
@property (nonatomic) CustomObject *object2;

- (void)observe;
- (void)removeObserve;

@end

@implementation CustomObject2
- (void)observe {
    [self.object addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserve {
    NSLog(@"%@ - removeObserve", self);
    [self.object removeObserver:self forKeyPath:@"name"];
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", self.description);
    
    @try {
        [self removeObserve];
    } @catch (NSException *exception) {
        NSLog(@"%@ - catch, %@", self, exception);
    } @finally {
        NSLog(@"%@ - finally", self);
    }
}
@end

- (void)tryWithDealloc {
    CustomObject2 *o = [CustomObject2 objectWithName:@"tryWithDealloc"];
    [o observe];
    o.object.name = @"object with new name";
    
    [o removeObserve];
}
```

`CustomObject2` dealloc 会移除 kvo，`tryWithDealloc` 又移除了一次，会抛出异常，导致 `object` 不会被释放。

打印

```
2020-08-26 17:00:52.562838+0800 tryCatch_objc[11991:320880] [<CustomObject2: 0x600000711760>_tryWithDealloc] - on observe, {
    kind = 1;
    new = "object with new name";
}
2020-08-26 17:00:52.562982+0800 tryCatch_objc[11991:320880] [<CustomObject2: 0x600000711760>_tryWithDealloc] - removeObserve
2020-08-26 17:00:52.563081+0800 tryCatch_objc[11991:320880] [<CustomObject2: 0x600000711760>_tryWithDealloc] - dealloc
2020-08-26 17:00:52.563153+0800 tryCatch_objc[11991:320880] [<CustomObject2: 0x600000711760>_tryWithDealloc] - removeObserve
2020-08-26 17:00:52.563290+0800 tryCatch_objc[11991:320880] [<CustomObject2: 0x600000711760>_tryWithDealloc] - catch, Cannot remove an observer <CustomObject2 0x600000711760> for the key path "name" from <CustomObject 0x600000524a10> because it is not registered as an observer.
2020-08-26 17:00:52.563391+0800 tryCatch_objc[11991:320880] [<CustomObject2: 0x600000711760>_tryWithDealloc] - finally
2020-08-26 17:00:52.563480+0800 tryCatch_objc[11991:320880] [<CustomObject: 0x600000524a20>_object2] - dealloc
```

缺少了 `2020-08-26 16:41:41.954785+0800 tryCatch_objc[11557:303204] [<CustomObject: 0x60000333d220>_object with new name] - dealloc` 的打印语句

