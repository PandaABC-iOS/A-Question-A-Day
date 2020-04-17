//
//  TimerViewController.m
//  weakProxy
//
//  Created by songzhou on 2020/4/17.
//  Copyright © 2020 songzhou. All rights reserved.
//

#import "TimerViewController.h"

@interface WeakProxy : NSProxy

+ (instancetype)weakProxyForObject:(id)targetObject;
    
@end

@interface TimerViewController ()

@property (nonatomic) NSTimer *timer;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:[WeakProxy weakProxyForObject:self]
                                            selector:@selector(handleTimer:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)dealloc {
    [_timer invalidate];
}

- (void)handleTimer:(NSTimer *)timer {
      NSLog(@"in block %@, timer:%@", self, timer);
}
@end


@implementation WeakProxy {
    __weak id _target;
}

/// WeakProxy 指定的创建方法
/// 作为 NSProxy 的子类，不响应也不需要 `-init`
/// @param targetObject 实际响应消息的对象
+ (instancetype)weakProxyForObject:(id)targetObject {
    WeakProxy *proxy = [WeakProxy alloc];
    proxy->_target = targetObject;

    return proxy;
}

#pragma mark - Forwarding Messages
/// 返回实际的消息响应对象
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _target;
}

/// 模拟 objc 发送消息返回 nil 的行为
///
/// 在 `_target` 被销毁后， `forwardingTargetForSelector:` 返回 nil，然后会调用这个方法。
/// 这里返回一个无用的方法签名防止 `doesNotRecognizeSelector:` 被调用
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

/// 返回 0/NULL/nil，防止 `doesNotRecognizeSelector:` 被调用
- (void)forwardInvocation:(NSInvocation *)invocation {
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

@end
