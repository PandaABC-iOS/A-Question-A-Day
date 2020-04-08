//
//  SZLRUCache.m
//  SZLRUCache
//
//  Created by Song Zhou on 2019/10/10.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "SZLRUCache.h"
#import "SZLRUCacheNode.h"

static const char *kLRUCacheQueue = "come.songzhou.LRUCacheQueue";

@interface SZLRUCache ()

@property (nonatomic) NSMutableDictionary<id, SZLRUCacheNode *> *dictionary;

/// dummy head node
@property (nonatomic) SZLRUCacheNode *head;
/// dummy tail node
@property (nonatomic) SZLRUCacheNode *tail;

@property (nonatomic) NSUInteger size;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation SZLRUCache

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    
    if (self) {
        _capacity = capacity;
        _size = 0;
        
        _head = [SZLRUCacheNode nodeWithValue:@"[HEAD]" key:@"__HEAD__"];
        _tail = [SZLRUCacheNode nodeWithValue:@"[TAIL]" key:@"__TAIL__"];
        
        _head.next = _tail;
        _tail.prev = _head;
        
        _dictionary = [NSMutableDictionary dictionary];
        _queue = dispatch_queue_create(kLRUCacheQueue, DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.head];
}

- (NSString *)descriptionSync {
    __block NSString *desc;
    dispatch_sync(self.queue, ^{
        desc = [self description];
    });
    
    return desc;
}

#pragma mark - set Object / get object
- (void)setObject:(id)object forKey:(id)key {
    NSParameterAssert(object);
    
    dispatch_async(self.queue, ^{
        SZLRUCacheNode *node = self.dictionary[key];
        
        if (node == nil) {
            SZLRUCacheNode *newNode = [SZLRUCacheNode nodeWithValue:object key:key];
            
            self.dictionary[key] = newNode;
            [self addNode:newNode];
            
            self.size += 1;
            
            [self checkSpace];
        } else {
            node.value = object;
            [self moveToHead:node];
        }
    });
}

- (id)objectForKey:(id)key {
    __block SZLRUCacheNode *node = nil;
    
    dispatch_sync(self.queue, ^{
        node = self.dictionary[key];
        
        if (node) {
            [self moveToHead:node];
        }
    });
    
    return node.value;
}

#pragma mark - Helper
/// add the new node right after head
/// @param node node to be added
- (void)addNode:(SZLRUCacheNode *)node {
    node.prev = _head;
    node.next = _head.next;
    
    _head.next.prev = node;
    _head.next = node;
}

///  remove an existing node from the double linked list
/// @param node node to be removed
- (void)removeNode:(SZLRUCacheNode *)node {
    node.prev.next = node.next;
    node.next.prev = node.prev;
}

- (void)moveToHead:(SZLRUCacheNode *)node {
    [self removeNode:node];
    [self addNode:node];
}

- (SZLRUCacheNode *)popTail {
    SZLRUCacheNode *node = self.tail.prev;
    [self removeNode:node];
    
    return node;
}

- (void)checkSpace {
    if (self.size > self.capacity) {
        SZLRUCacheNode *tail = [self popTail];
        
        [self.dictionary removeObjectForKey:tail.key];
        self.size -= 1;
    }
}
@end
