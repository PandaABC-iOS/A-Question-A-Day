//
//  NSNumberDemoTests.m
//  NSNumberDemoTests
//
//  Created by songzhou on 2020/6/10.
//  Copyright © 2020 songzhou. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSNumberDemoTests : XCTestCase

@end

@implementation NSNumberDemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    XCTAssert([[self _format:@42] isEqualToString:@"42"]);
    XCTAssert([[self _format:@-42] isEqualToString:@"-42"]);
    XCTAssert([[self _format:@0.1] isEqualToString:@"0.10000000000000001"]);
}

- (NSString *)_format:(NSNumber *)number {
    const char *objCType = number.objCType;
    char anum[256], *aptr = &anum[255];
    
    int isNegative = 0;
    // 8 字节
    unsigned long long ullv;
    long long llv;
    
    switch (objCType[0]) {
        case 'c': case 'i': case 's': case 'l': case 'q': // 有符号整数
            if (CFNumberGetValue((CFNumberRef)number, kCFNumberLongLongType, &llv)) {
                if (llv < 0LL) {
                    ullv = -llv; isNegative = 1;
                } else {
                    ullv = llv; isNegative = 0;
                }
                goto convertNumber;
            } else {
                return nil;
            }
            break;
        case 'C': case 'I': case 'S': case 'L': case 'Q': // 无符号整数
            if (CFNumberGetValue((CFNumberRef)number, kCFNumberLongLongType, &ullv)) {
            convertNumber:
                if (ullv < 10ULL) {
                    *--aptr = ullv + '0';
                } else {
                    while (ullv > 0ULL) {
                        *--aptr = (ullv % 10ULL) + '0';
                        ullv /= 10ULL;
                    }
                }
                
                if (isNegative) {
                    *--aptr = '-';
                }
                

                NSString *str = [NSString stringWithUTF8String:aptr];
                
                return str;
            }
                
            break;
        case 'f': case 'd': { // 浮点数
            double dv;
            if (CFNumberGetValue((CFNumberRef)number, kCFNumberDoubleType, &dv)) {
                if (!isfinite(dv)) {
                    return nil;
                }

                char buffer[255];
                sprintf(buffer, "%.17g", dv);
                
                return [NSString stringWithUTF8String:buffer];
            }
            break;
        }
        default:
            break;
    }
    
    return nil;
}

@end
