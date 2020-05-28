//
//  signDemoTests.m
//  signDemoTests
//
//  Created by Song Zhou on 2020/5/26.
//  Copyright © 2020 Song Zhou. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface signDemoTests : XCTestCase

@end

@implementation signDemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDisplaySet {
    [self _displayCharset:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self _displayCharset:[NSCharacterSet URLPathAllowedCharacterSet]];
}

- (void)testURLEncoding {
    NSString *a = @"http://www.baidu.com/ac-common/common/getCurTimeStamp?key1=value1&key2=value2";
    NSString *ad = [a stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    NSString *b = @"http://www.baidu.com/ac-common/common/getCurTimeStamp?key1=value1&key2=中文";
    NSString *bd = [b stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // 歧义情况,"val&ue"
    NSString *c = @"http://www.baidu.com/ac-common/common/getCurTimeStamp?key1=val&ue1&key2=value2";
    NSString *cd = [c stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@", ad);
    NSLog(@"%@", bd);
    NSLog(@"cd: %@", cd);
    
    /// "val&ue" 处理
    /// ===========
    
    // 所有字符编码
    NSString *cv = [@"val&ue" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@""]];
    // val&ue=%76%61%6C%26%75%65
    NSLog(@"cv: %@", cv);
    
    // 再次编码后 "%" 会被编码到 %25
    NSString *d = [NSString stringWithFormat:@"http://www.baidu.com/ac-common/common/getCurTimeStamp?key1=%@&key2=value", cv];
    d = [d stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    // val&ue=%2576 %2561 %256C %2526 %2575 %2565
    NSLog(@"d: %@", d);
    
    /// 正确解码
    NSString *dd1 = [d stringByRemovingPercentEncoding];
    //解码第一次：val&ue=%76%61%6C%26%75%65
    NSLog(@"%@", dd1);
    NSString *dd2 = [dd1 stringByRemovingPercentEncoding];
    //解码第二次：val&ue=val&ue
    NSLog(@"%@", dd2);
}

- (void)testJavaEncoding {
    NSString *alphaNumeric = @"abcABC0123";
    NSString *reversedChars = @".-*_";
    NSString *space = @" ";
    NSString *chinese = @"中文";

    XCTAssert([[self _encoding:alphaNumeric] isEqualToString:alphaNumeric]);
    XCTAssert([[self _encoding:reversedChars] isEqualToString:reversedChars]);
    XCTAssert([[self _encoding:space] isEqualToString:@"+"]);
    XCTAssert([[self _encoding:@"a b"] isEqualToString:@"a+b"]);
    XCTAssert([[self _encoding:chinese] isEqualToString:@"%E4%B8%AD%E6%96%87"]);
}

- (void)testServerExample {
    NSString *t1 = @"/ac-common/common/getCurTimeStamp?address=美国&id=123&name=xiaoming&nonce=C9F15CBFF4AC4A6CB54DF51ABF4B5B44&timestamp=1525872629832";
    XCTAssert([[self _encoding:t1] isEqualToString:@"%2Fac-common%2Fcommon%2FgetCurTimeStamp%3Faddress%3D%E7%BE%8E%E5%9B%BD%26id%3D123%26name%3Dxiaoming%26nonce%3DC9F15CBFF4AC4A6CB54DF51ABF4B5B44%26timestamp%3D1525872629832"]);
    
    NSString *t2 = @"/ac-common/common/user?age=12&birdate=2019-05-11&name=xiaoming&nonce=C9F15CBFF4AC4A6CB54DF51ABF4B5B44&timestamp=1525872629832";
    XCTAssert([[self _encoding:t2] isEqualToString:@"%2Fac-common%2Fcommon%2Fuser%3Fage%3D12%26birdate%3D2019-05-11%26name%3Dxiaoming%26nonce%3DC9F15CBFF4AC4A6CB54DF51ABF4B5B44%26timestamp%3D1525872629832"]);
}

- (NSString *)_encoding:(NSString *)str {
    NSMutableCharacterSet *charset = [[NSMutableCharacterSet alloc] init];
    [charset addCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"];
    [charset addCharactersInString:@".-*_ "];


    NSString *encoded = [str stringByAddingPercentEncodingWithAllowedCharacters:charset];
    encoded = [encoded stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSLog(@"%@", encoded);
    return encoded;
}

- (void)_displayCharset:(NSCharacterSet *)charset {
    NSMutableArray *array = [NSMutableArray array];
    for (int plane = 0; plane <= 16; plane++) {
        if ([charset hasMemberInPlane:plane]) {
            UTF32Char c;
            for (c = plane << 16; c < (plane+1) << 16; c++) {
                if ([charset longCharacterIsMember:c]) {
                    UTF32Char c1 = OSSwapHostToLittleInt32(c); // To make it byte-order safe
                    NSString *s = [[NSString alloc] initWithBytes:&c1 length:4 encoding:NSUTF32LittleEndianStringEncoding];
                    [array addObject:s];
                }
            }
        }
    }
    
    NSLog(@"%@", array);
    NSLog(@"%@", [array componentsJoinedByString:@""]);
}

- (void)testURLComponent {
    NSURL *url = [NSURL URLWithString:@"https://api.aircourses.com/ac-common/common/getCurTimeStamp?id=123&name=xiaoming&address=america"];
    
    NSURL *url2 = [NSURL URLWithString:@"https://api.aircourses.com/ac-common/common/getCurTimeStamp"];
    NSURL *url3 = [NSURL URLWithString:@"https://api.aircourses.com/ac-common/common/getCurTimeStamp?id"];
    
    NSLog(@"path: %@", url.path);
    NSLog(@"path: %@", url2.path);
    NSLog(@"path: %@", url3.path);
}
@end
