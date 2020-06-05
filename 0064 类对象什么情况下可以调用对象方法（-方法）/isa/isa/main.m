//
//  main.m
//  isa
//
//  Created by Leen on 2020/6/5.
//  Copyright © 2020 Leen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Test.h"

@interface Person : NSObject

//+ (void)test;

@end

@implementation Person

//+ (void)test
//{
//    NSLog(@"+[Person test] - %p", self);
//}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"[MJPerson class] - %p", [Person class]);
        NSLog(@"[NSObject class] - %p", [NSObject class]);
        
        [Person test];
     
        // isa -> superclass -> suerpclass -> superclass -> .... superclass == nil
        
        [NSObject test];
        //        objc_msgSend([NSObject class], @selector(test))
        
    }
    return 0;
}
