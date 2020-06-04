JSON 序列化

# 引言
众所周知，因为计算机用二进制表示数字的原因，计算机无法准确表示浮点数。比如 0.1 在双精度浮点数下只能用 0.10000000000000001 来做近似表示。

JSON 对象序列化到字符串后，对浮点数的表现（NSNumber 对象中的浮点数）也遵从了这一点。

# 原理
如果需要得到较为准确的十进制表示，这时候需要吧 JSON 对象中的所有 NSNumber 值转到 NSDecimal，这样 JSON 序列化的时候，就可以类似于 NSNumber stringValue 的表现。

我们可以写这样一个方法做 NSNumber -> NSDecimalNumber 转换:

```objc
	NSNumber *number = @(0.1);
	[NSDecimalNumber decimalNumberWithDecimal:number.decimalValue];
```

# JSON 值替换
```objc
NSNumber *number_18   = @(0.400000005960464485);
NSNumber *number_18_2 = @(0.400000005960464480);
NSNumber *number_17 = @(0.40000000596046448);
NSNumber *number_16 = @(0.4000000059604644);
NSNumber *number_2 = @(0.42);
NSNumber *number_1 = @(0.4);
NSNumber *number_11 = @(0.1);

NSNumber *i1 = @(1.0);
NSNumber *i2 = @(123);
NSDecimalNumber *d1 = [NSDecimalNumber decimalNumberWithString:@"0.42"];
NSNumber *ts = @([[NSDate date] timeIntervalSince1970]*1000);

NSArray *array = @[
	number_11,number_1, number_2, number_16, number_17, number_18_2, number_18, i1, i2,d1,ts
];
        
array = [array ac_mapJSONValues:^id(id value) {
	if ([value isMemberOfClass:[NSDecimalNumber class]]) {
		return nil;
	}

	if ([value isKindOfClass:[NSNumber class]]) {
		return [NSDecimalNumber decimalNumberWithDecimal:[(NSNumber *)value decimalValue]];
	}

	return nil;
}];
    
    
// 简便方法
@implementation NSArray (ACExt)

- (NSArray *)ac_map:(id(^)(id obj))block {
    if (!block) {
        return self;
    }
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id obj in self) {
        [ret addObject:block(obj) ?: [NSNull null]];
    }
    
    return [ret copy];
}
@end

@implementation NSObject (NSDictionary_ObjectMapping)

/// 递归遍历 JSON 对象的值，接收 NSArray 或 NSDictionary
- (id)ac_mapJSONValues:(id(^_Nullable)(id value))mapper {
	NSParameterAssert([self isKindOfClass:[NSDictionary class]] || [self isKindOfClass:[NSArray class]]);
    NSParameterAssert(mapper);
    return [self _ac_mapValues:self mapper:mapper];
}

- (id)_ac_mapValues:(id)object mapper:(id(^_Nullable)(id value))mapper {
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        for (id k in (NSDictionary *)object) {
            id key = k;
            id value = [object valueForKey:key];
            
            id mapped = mapper(value);
            if (mapped) {
                value = mapped;
            }
            
            ret[key] = [self _ac_mapValues:value mapper:mapper];
        }
        
        return ret;
    } else if ([object isKindOfClass:[NSArray class]]) {
        return [(NSArray *)object ac_map:^id(id obj) {
            return [self _ac_mapValues:obj mapper:mapper];
        }];
    } else {
        id mapped = mapper(object);
        if (mapped) {
            object = mapped;
        }
        
        return object;
    }
}
@end

```




