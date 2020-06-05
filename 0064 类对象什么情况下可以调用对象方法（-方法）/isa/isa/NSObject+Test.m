//
//  NSObject+Test.m
//  isa
//
//  Created by Leen on 2020/6/5.
//  Copyright © 2020 Leen. All rights reserved.
//

#import "NSObject+Test.h"

@implementation NSObject (Test)

//+ (void)test
//{
//    NSLog(@"+[NSObject test] - %p", self);
//}

- (void)test
{
    NSLog(@"-[NSObject test] - %p", self);
}


@end
