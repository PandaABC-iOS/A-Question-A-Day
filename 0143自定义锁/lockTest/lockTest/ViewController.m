//
//  ViewController.m
//  lockTest
//
//  Created by Song Zhou on 2020/9/21.
//

#import "ViewController.h"
#include <libkern/OSAtomic.h>
#include <stdatomic.h>

typedef struct __lock_t {
    int64_t flag;
} lock_t;

void init(lock_t *lock) {
    // 0 意味着锁是可用的，1 是锁被持有
    lock->flag = 0;
}

void lock(lock_t *lock) {
    /// 比较第一个和第三个参数，如果相等，设置第二个参数到第三个参数
    /// 如果第一个参数等于第三个参数，返回 YES。否则返回 NO
    while (!OSAtomicCompareAndSwap64(0, 1, &lock->flag))
        ;

    
    // OSAtomicCompareAndSwap64 新 API
//    int64_t expected = 0;
//    while(!atomic_compare_exchange_strong((atomic_llong *)&lock->flag,&expected,1))
//        expected=0;
}

void unlock(lock_t *lock) {
    lock->flag = 0;
}

static volatile int count = 0;

@interface ViewController ()
@property (nonatomic) NSThread *thread1;
@property (nonatomic) NSThread *thread2;
@end

@implementation ViewController {
    lock_t _lock;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    init(&_lock);
    
    self.thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(threadStart:) object:@1];
    self.thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(threadStart:) object:@2];
    
    [self.thread1 start];
    [self.thread2 start];
}

- (void)test {
    for (int i = 0; i < 1e7; i++) {
        count += 1;
    }
}

- (void)threadStart:(NSNumber *)sender {
    NSLog(@"thread_%@, count: %d start", sender, count);
    
    // 1. 正常调用
    [self test];
    
    // 2. iOS 系统锁
//    @synchronized (self) {
//        [self test];
//    }

    // 3. 自定义旋转锁
//    lock(&_lock);
//    [self test];
//    unlock(&_lock);
    
    
    NSLog(@"thread_%@, count: %d end", sender, count);
}

@end
