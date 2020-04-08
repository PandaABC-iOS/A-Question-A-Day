//
//  SZLRUCacheNode.h
//  SZLRUCache
//
//  Created by Song Zhou on 2019/10/10.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZLRUCacheNode : NSObject

@property (nonatomic) id value;
@property (nonatomic, readonly) id key;
@property (nullable, nonatomic) SZLRUCacheNode *next;
@property (nullable, nonatomic) SZLRUCacheNode *prev;

+ (instancetype)nodeWithValue:(id)value key:(id)key;
- (instancetype)initWithValue:(id)value key:(id)key;

@end

NS_ASSUME_NONNULL_END
