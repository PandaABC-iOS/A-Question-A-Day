//
//  SZLRUCacheNode.m
//  SZLRUCache
//
//  Created by Song Zhou on 2019/10/10.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "SZLRUCacheNode.h"

@interface SZLRUCacheNode ()

@property (nonatomic, readwrite) id key;

@end

@implementation SZLRUCacheNode

- (instancetype)initWithValue:(id)value key:(id)key {
    NSParameterAssert(key);
    NSParameterAssert(value);
    
    self = [super init];
    
    if (self) {
        _value = value;
        _key = key;
    }
    
    return self;
}

+ (instancetype)nodeWithValue:(id)value key:(id)key {
    return [[self alloc] initWithValue:value key:key];
}

- (NSString *)description {
    if (self.next) {
        return [NSString stringWithFormat:@"%@ %@", self.value, self.next];
    } else {
        return [NSString stringWithFormat:@"%@", self.value];
    }

}

- (void)setNext:(SZLRUCacheNode *)next {
    if (_next != next) {
        _next = next;
        next.prev = self;
    }
}

@end
