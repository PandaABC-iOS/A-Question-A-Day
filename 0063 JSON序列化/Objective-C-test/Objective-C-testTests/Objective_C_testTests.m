//
//  Objective_C_testTests.m
//  Objective-C-testTests
//
//  Created by songzhou on 2020/6/2.
//  Copyright © 2020 songzhou. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSArray<ObjectType> (ACExt)

- (NSArray *)ac_map:(id(^)(ObjectType obj))block;
- (NSArray<ObjectType> *)ac_filter:(BOOL(^)(ObjectType obj))block;

@end

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


- (NSArray *)ac_filter:(BOOL(^)(id obj))block {
    if (!block) {
        return self;
    }
    
    NSMutableArray *ret = [@[] mutableCopy];
    for (id obj in self) {
        if (block(obj)) {
            [ret addObject:obj];
        }
    }
    
    return ret;
}
@end


@interface NSObject (NSDictionary_ObjectMapping)

@end

@implementation NSObject (NSDictionary_ObjectMapping)
- (NSString*)getJSONString
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (nil == data)
        return nil;

    NSString* strResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    strResult = [strResult stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return strResult;
}

- (id)ac_mapJSONValues:(id(^_Nullable)(id value))mapper {
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

@interface Objective_C_testTests : XCTestCase

@end

@implementation Objective_C_testTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (NSDecimalNumber *)_decimalNumberFromNumber:(NSNumber *)number {
    NSDecimalNumber *d = [NSDecimalNumber decimalNumberWithDecimal:number.decimalValue];
    
    return d;
}

- (NSString *)_stringFromNumber:(NSNumber *)number {
    return [NSDecimalNumber decimalNumberWithDecimal:number.decimalValue].stringValue;
}

- (void)testFoundation2JSON {
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
    
    double number_2d = number_2.doubleValue;
    
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

    
    // [0.40000000000000002,0.41999999999999998,0.40000000596046442,0.40000000596046448]
    NSString *httpBody = [array getJSONString];
    
    NSString *numberStr = [httpBody stringByReplacingOccurrencesOfString:@"[" withString:@""];
    numberStr = [numberStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
    NSArray *numberArray = [numberStr componentsSeparatedByString:@","];
    
    for (int i = 0;i < array.count;i++) {
        NSNumber *n = array[i];
        NSString *str = [self _stringFromNumber:n];
        NSString *target = numberArray[i];
        NSLog(@"compare:\n%@\n%@", target,str);
        XCTAssert([str isEqualToString:target]);
    }
}

@end
