//
//  ViewController.m
//  tryCatch_objc
//
//  Created by songzhou on 2020/8/21.
//  Copyright © 2020 songzhou. All rights reserved.
//

#import "ViewController.h"

@interface CustomObject : NSObject

+ (instancetype)objectWithName:(NSString *)name;

@property (nonatomic, copy) NSString *name;

- (void)throw;

@end
@implementation CustomObject

+ (instancetype)objectWithName:(NSString *)name {
    CustomObject *o = [CustomObject new];
    o.name = name;
    return o;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@_%@]", [super description], self.name];
}

- (void)dealloc {
    NSLog(@"%@ - dealloc", self.description);
}

- (void)throw {
    @try {
        NSArray *a = @[];
        NSLog(@"%@", a[0]);
    } @catch (NSException *exception) {
        NSLog(@"%@ catch %@", self, exception);
    } @finally {
        NSLog(@"%@ finally", self);
    }
}

@end

@interface CustomObject2 : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic) CustomObject *object;
@property (nonatomic) CustomObject *object2;

- (void)observe;
- (void)removeObserve;

@end

@implementation CustomObject2

+ (instancetype)objectWithName:(NSString *)name {
    CustomObject2 *o = [CustomObject2 new];
    o.name = name;
    o.object = [CustomObject objectWithName:@"object"];
    o.object2 = [CustomObject objectWithName:@"object2"];
    
    return o;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@_%@]", [super description], self.name];
}

- (void)observe {
    [self.object addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserve {
    NSLog(@"%@ - removeObserve", self);
    [self.object removeObserver:self forKeyPath:@"name"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@ - on observe, %@", self, change);
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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self normalThrow];
//    [self tryWithLocalVariables];
//    [self tryWithLocalVariables2];
    [self tryWithDealloc];
}

- (void)normalThrow {
    NSLog(@"start %s", __func__);
    @try {
        @throw [NSException exceptionWithName:@"foo-exception"
                                       reason:nil
                                     userInfo:nil];
    } @catch (NSException *exception) {
        NSLog(@"catch %@", exception);
    } @finally {
        NSLog(@"finally");
    }
}

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

- (void)tryWithDealloc {
    CustomObject2 *o = [CustomObject2 objectWithName:@"tryWithDealloc"];
    [o observe];
    o.object.name = @"object with new name";
    
    [o removeObserve];
}

@end
