//
//  main.m
//  lockTest
//
//  Created by Song Zhou on 2020/9/21.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);

    }
    
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
