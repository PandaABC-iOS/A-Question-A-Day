//
//  SZLRUCache.h
//  SZLRUCache
//
//  Created by Song Zhou on 2019/10/10.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZLRUCache : NSObject
 
@property (nonatomic, readonly) NSUInteger capacity;

- (instancetype)initWithCapacity:(NSUInteger)capacity;

- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;

- (NSString *)descriptionSync;

@end

NS_ASSUME_NONNULL_END
