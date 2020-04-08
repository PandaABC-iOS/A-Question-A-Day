//
//  SZLRUCacheTests.m
//  SZLRUCacheTests
//
//  Created by Song Zhou on 2019/10/10.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SZLRUCache.h"

@interface SZLRUCacheTests : XCTestCase

@property (nonatomic) SZLRUCache *cache;

@end

@interface TestClass : NSObject
@property (nonatomic, copy) NSString *value;

+ (instancetype)objectWithValue:(NSString *)value;
@end

@implementation SZLRUCacheTests

- (void)setUp {
    self.cache = [[SZLRUCache alloc] initWithCapacity:5];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCapacity2 {
    SZLRUCache *cache = [[SZLRUCache alloc] initWithCapacity:2];
    NSLog(@"init\n%@", [cache descriptionSync]);
    
    [cache setObject:@1 forKey:@1];
    NSLog(@"add 1\n%@", [cache descriptionSync]);
    
    [cache setObject:@2 forKey:@2];
    NSLog(@"add 2\n%@", [cache descriptionSync]);
    XCTAssert([[cache objectForKey:@1] isEqualToNumber:@1]);
    NSLog(@"access 1\n%@", [cache descriptionSync]);
    
    /// evicts key 2
    [cache setObject:@3 forKey:@3];
    NSLog(@"add 3\n%@", [cache descriptionSync]);
    XCTAssertNil([cache objectForKey:@2]);
    
    /// evicts key 1
    [cache setObject:@4 forKey:@4];
    NSLog(@"add 4\n%@", [cache descriptionSync]);
    XCTAssertNil([cache objectForKey:@1]);
    NSLog(@"access 1\n%@", [cache descriptionSync]);
    XCTAssert([[cache objectForKey:@3] isEqualToNumber:@3]);
    NSLog(@"access 3\n%@", [cache descriptionSync]);
    XCTAssert([[cache objectForKey:@4] isEqualToNumber:@4]);
    NSLog(@"access 4\n%@", [cache descriptionSync]);
}

- (void)testCacheShouldStoreValue {
    
    [self.cache setObject:[self testObj1] forKey:[self key1]];
    XCTAssert([[self.cache objectForKey:[self key1]] isEqual:[self testObj1]], @"cache should store value");
}

- (void)testCacheShouldStoreMultipleValues {
    [self.cache setObject:[self testObj1] forKey:[self key1]];
    [self.cache setObject:[self testObj2] forKey:[self key2]];
    [self.cache setObject:[self testObj3] forKey:[self key3]];
    
    XCTAssert([[self.cache objectForKey:[self key1]] isEqual:[self testObj1]] &&
              [[self.cache objectForKey:[self key2]] isEqual:[self testObj2]] &&
              [[self.cache objectForKey:[self key3]] isEqual:[self testObj3]], @"cache should store multiple values");
}

- (void)testCacheShouldStoreLastValues {
    self.cache = [[SZLRUCache alloc] initWithCapacity:2];
    
    [self.cache setObject:[self testObj1] forKey:[self key1]];
    [self.cache setObject:[self testObj2] forKey:[self key2]];
    [self.cache setObject:[self testObj3] forKey:[self key3]];
    
    XCTAssert([[self.cache objectForKey:[self key2]] isEqual:[self testObj2]] &&
              [[self.cache objectForKey:[self key3]] isEqual:[self testObj3]], @"cache should store last values");
 
    XCTAssertNil([self.cache objectForKey:[self key1]], @"cache should not store value which did not used recently");
    
}

- (void)testCacheShouldNotStoreValueThatWasNotUsedRecently {
    
    self.cache = [[SZLRUCache alloc] initWithCapacity:2];
    
    [self.cache setObject:[self testObj1] forKey:[self key1]];
    [self.cache setObject:[self testObj2] forKey:[self key2]];
    [self.cache setObject:[self testObj3] forKey:[self key3]];

    XCTAssertNil([self.cache objectForKey:[self key1]], @"cache should not store value which did not used recently");
}

- (void)testCacheShouldStoreRecentlyValueEventIfItWasAppendedFirst {
    
    self.cache = [[SZLRUCache alloc] initWithCapacity:2];
    
    [self.cache setObject:[self testObj1] forKey:[self key1]];
    [self.cache setObject:[self testObj2] forKey:[self key2]];
    
    [self.cache objectForKey:[self key1]];
    
    [self.cache setObject:[self testObj3] forKey:[self key3]];
    
    XCTAssert([[self.cache objectForKey:[self key1]] isEqual:[self testObj1]], @"cache should store recently used value even if it was appended earlier");
}

- (void)testCacheShouldNotStoreValueThatWasNotUsedRecentlyEvenIfItWasAppendedLater {
    self.cache = [[SZLRUCache alloc] initWithCapacity:2];
    
    [self.cache setObject:[self testObj1] forKey:[self key1]];
    [self.cache setObject:[self testObj2] forKey:[self key2]];
    
    [self.cache objectForKey:[self key1]];
    
    [self.cache setObject:[self testObj3] forKey:[self key3]];
    
    XCTAssertFalse([self.cache objectForKey:[self key2]], @"cache should not store value which did not used recently, even if it was appended later");
}

- (void)testCacheShouldStoreTheSameValueTwiceWithDifferentKeys {

    TestClass *obj1 = [self testObj1];
    
    [self.cache setObject:obj1 forKey:[self key1]];
    [self.cache setObject:obj1 forKey:[self key2]];
    
    XCTAssert([self.cache objectForKey:[self key1]] != nil &&
              [[self.cache objectForKey:[self key1]] isEqual:[self.cache objectForKey:[self key2]]], @"cache should store the same value with different keys");
    
}

- (void)testCacheShouldNotStoreNilValue {
    XCTAssertThrows([self.cache setObject:nil forKey:[self key1]], @"should throw exception for nil value");
    
    XCTAssertNil([self.cache objectForKey:[self key1]], @"cache should not store nil value");
}

- (void)testCacheShouldNotReplaceValuesWithNilValue {
    self.cache = [[SZLRUCache alloc] initWithCapacity:2];
    
    TestClass *obj3 = nil;
    
    [self.cache setObject:[self testObj1] forKey:[self key1]];
    [self.cache setObject:[self testObj2] forKey:[self key2]];
    
    XCTAssertThrows([self.cache setObject:obj3 forKey:[self key3]], @"should throw exception for nil value");
    XCTAssert([[self.cache objectForKey:[self key1]] isEqual:[self testObj1]] &&
              [[self.cache objectForKey:[self key2]] isEqual:[self testObj2]],  @"cache should not replace values with nil value");
    
}

#pragma mark - Performance
- (void)testPerformanceInsertObjectsInLargeCache {
    self.cache = [[SZLRUCache alloc] initWithCapacity:1000];
    
    [self measureBlock:^{
        for (NSUInteger i=0;i<1000;i++) {
            TestClass *obj = [TestClass objectWithValue:[NSString stringWithFormat:@"value %lu", i]];
            NSString *key = [NSString stringWithFormat:@"key %lu", i];
            [self.cache setObject:obj forKey:key];
        }
    }];
}

- (void)testPerformanceInsertObjectsInSmallCache {
    self.cache = [[SZLRUCache alloc] initWithCapacity:5];
    [self measureBlock:^{
        for (NSUInteger i=0;i<1000;i++) {
            TestClass *obj = [TestClass objectWithValue:[NSString stringWithFormat:@"value %lu", i]];
            NSString *key = [NSString stringWithFormat:@"key %lu", i];
            [self.cache setObject:obj forKey:key];
        }
    }];
}

- (void)testPerformanceReceiveRandomValues {
    self.cache = [[SZLRUCache alloc] initWithCapacity:1000];

    for (NSUInteger i=0;i<1000;i++) {
        TestClass *obj = [TestClass objectWithValue:[NSString stringWithFormat:@"value %lu", i]];
        NSString *key = [NSString stringWithFormat:@"key %lu", i];
        [self.cache setObject:obj forKey:key];
    }
    
    [self measureBlock:^{
        for (NSUInteger i=0;i<1000;i++) {
            NSString *key = [NSString stringWithFormat:@"key %i", arc4random()%1000];
            [self.cache objectForKey:key];
        }
    }];
}

#pragma mark - helper methods

- (TestClass *)testObj1 {
    return [TestClass objectWithValue:@"1"];
}

- (TestClass *)testObj2 {
    return [TestClass objectWithValue:@"2"];
}

- (TestClass *)testObj3 {
    return [TestClass objectWithValue:@"3"];
}

- (NSString *)key1 {
    return @"key1";
}

- (NSString *)key2 {
    return @"key2";
}

- (NSString *)key3 {
    return @"key3";
}
@end

@implementation TestClass
+ (instancetype)objectWithValue:(NSString *)value {
    TestClass *obj = [TestClass new];
    obj.value = value;
    return obj;
}

- (NSUInteger)hash {
    return [self.value hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.value];
}

- (BOOL)isEqual:(TestClass *)object {
    return [self.value isEqualToString:object.value];
}

@end
