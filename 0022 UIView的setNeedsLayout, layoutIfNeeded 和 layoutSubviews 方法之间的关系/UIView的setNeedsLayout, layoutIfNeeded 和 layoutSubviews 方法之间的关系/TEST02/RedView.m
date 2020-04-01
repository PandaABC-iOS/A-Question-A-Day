//
//  TestView.m
//  TEST02
//
//  Created by Leen on 2019/9/23.
//  Copyright © 2019 Leen. All rights reserved.
//

#import "RedView.h"

@implementation RedView

- (void)drawRect:(CGRect)rect
{
    NSLog(@"RedView--drawRect");

}

- (void)layoutSubviews
{
    NSLog(@"RedView--layoutSubviews");
}

@end
