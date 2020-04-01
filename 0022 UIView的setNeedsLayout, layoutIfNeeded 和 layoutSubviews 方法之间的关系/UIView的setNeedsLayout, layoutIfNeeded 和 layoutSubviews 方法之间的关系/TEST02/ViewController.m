//
//  ViewController.m
//  TEST02
//
//  Created by Leen on 2019/2/13.
//  Copyright © 2019年 Leen. All rights reserved.
//

#import "ViewController.h"
#import "RedView.h"
#import "blueView.h"
#import "blueSubView.h"


@interface ViewController ()
{

    __weak IBOutlet blueView *_blueView;
    
}

@end

@implementation ViewController
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [self test0];

   // [self test1];

  //  [self test2];
    
  //  [self test3];
    
  // [self test4];
    
  //  [self test5];

    //  [self test6];
    
//    [self test7];
    
   // [self test8];
    
     // [self test9];
    
    
}

/*
 2020-03-31 16:07:43.232181+0800 TEST02[83633:4343814] blueView--layoutSubviews
 2020-03-31 16:07:43.233277+0800 TEST02[83633:4343814] blueView--drawRect
 */
- (IBAction)test0
{

//    RedView *redView = [[RedView alloc]initWithFrame:CGRectZero];
//    redView.backgroundColor = [UIColor redColor];
//    [_blueView addSubview:redView];
    
    blueSubView *SubView = [[blueSubView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    SubView.backgroundColor = [UIColor redColor];
    [_blueView addSubview:SubView];
}

/*
 
 2020-03-31 16:45:36.346616+0800 TEST02[83786:4409573] blueView--layoutSubviews
 2020-03-31 16:45:36.346740+0800 TEST02[83786:4409573] RedView--layoutSubviews
 2020-03-31 16:45:36.347077+0800 TEST02[83786:4409573] blueView--drawRect
 2020-03-31 16:45:36.349408+0800 TEST02[83786:4409573] RedView--drawRect
 
 */

- (IBAction)test1
{
    RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
    redView.backgroundColor = [UIColor redColor];
    [_blueView addSubview:redView];
}




/*
 
 2019-09-23 16:49:08.651921+0800 TEST02[2064:278560] blueView--layoutSubviews
 2019-09-23 16:49:08.652328+0800 TEST02[2064:278560] blueView--drawRect
 */


- (IBAction)test2
{
    
    RedView *redView = [[RedView alloc]init];
    redView.backgroundColor = [UIColor redColor];
    [_blueView addSubview:redView];
    
}


/*
 2019-09-23 16:51:02.159771+0800 TEST02[2085:280627] blueView--layoutSubviews
 2019-09-23 16:51:02.160265+0800 TEST02[2085:280627] blueView--drawRect
 */

- (IBAction)test3
{
    RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
    redView.backgroundColor = [UIColor redColor];

}



/*

 2019-09-23 16:54:43.539466+0800 TEST02[2131:284370] blueView--layoutSubviews
 2019-09-23 16:54:43.539601+0800 TEST02[2131:284370] RedView--layoutSubviews
 2019-09-23 16:54:43.539915+0800 TEST02[2131:284370] blueView--drawRect
 2019-09-23 16:54:43.541774+0800 TEST02[2131:284370] RedView--drawRect
 
 2019-09-23 16:54:45.531028+0800 TEST02[2131:284370] blueView--layoutSubviews
 2019-09-23 16:54:45.531192+0800 TEST02[2131:284370] RedView--layoutSubviews

 */

- (IBAction)test4
{
    RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
    redView.backgroundColor = [UIColor redColor];
    [_blueView addSubview:redView];
    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        redView.frame = CGRectMake(10, 10, 120, 120);
    });

}



/*
 2019-09-23 16:56:39.959347+0800 TEST02[2154:287211] blueView--layoutSubviews
 2019-09-23 16:56:39.959482+0800 TEST02[2154:287211] RedView--layoutSubviews
 2019-09-23 16:56:39.959798+0800 TEST02[2154:287211] blueView--drawRect
 2019-09-23 16:56:39.961560+0800 TEST02[2154:287211] RedView--drawRect
 */

- (IBAction)test5
{
       RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
       redView.backgroundColor = [UIColor redColor];
       [_blueView addSubview:redView];
       

       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          
           redView.frame = CGRectMake(10, 10, 100, 100);
       });
}



/*

 2019-09-23 16:59:36.014007+0800 TEST02[2222:293718] blueView--layoutSubviews
 2019-09-23 16:59:36.014193+0800 TEST02[2222:293718] RedView--layoutSubviews
 2019-09-23 16:59:36.014636+0800 TEST02[2222:293718] blueView--drawRect
 2019-09-23 16:59:36.016510+0800 TEST02[2222:293718] RedView--drawRect
 */

- (IBAction)test6
{
       RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
       redView.backgroundColor = [UIColor redColor];
       [_blueView addSubview:redView];
       
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          
           redView.frame = CGRectMake(15, 15, 100, 100);
       });
}

/*
 2019-09-23 17:00:36.982898+0800 TEST02[2238:296145] blueView--layoutSubviews
 2019-09-23 17:00:36.983031+0800 TEST02[2238:296145] RedView--layoutSubviews
 2019-09-23 17:00:36.983386+0800 TEST02[2238:296145] blueView--drawRect
 2019-09-23 17:00:36.985296+0800 TEST02[2238:296145] RedView--drawRect
 2019-09-23 17:00:39.172678+0800 TEST02[2238:296145] RedView--layoutSubviews
 */


- (IBAction)test7
{
       RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
       redView.backgroundColor = [UIColor redColor];
       [_blueView addSubview:redView];
    
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

           [redView setNeedsLayout];

       });
}

/*
 2019-09-23 17:01:59.756894+0800 TEST02[2254:297707] blueView--layoutSubviews
 2019-09-23 17:01:59.757036+0800 TEST02[2254:297707] RedView--layoutSubviews
 2019-09-23 17:01:59.760595+0800 TEST02[2254:297707] blueView--drawRect
 2019-09-23 17:01:59.763381+0800 TEST02[2254:297707] RedView--drawRect
 */

- (IBAction)test8
{
       RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
       redView.backgroundColor = [UIColor redColor];
       [_blueView addSubview:redView];
    
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
           [redView layoutIfNeeded];
       });
}



/*
 2019-09-23 17:03:54.179785+0800 TEST02[2272:300125] blueView--layoutSubviews
 2019-09-23 17:03:54.179969+0800 TEST02[2272:300125] RedView--layoutSubviews
 2019-09-23 17:03:54.180222+0800 TEST02[2272:300125] blueView--drawRect
 2019-09-23 17:03:54.181774+0800 TEST02[2272:300125] RedView--drawRect
 2019-09-23 17:03:56.170335+0800 TEST02[2272:300125] RedView--layoutSubviews

 */
- (IBAction)test9
{
       RedView *redView = [[RedView alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
       redView.backgroundColor = [UIColor redColor];
       [_blueView addSubview:redView];
    
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          
           [redView setNeedsLayout];
           [redView layoutIfNeeded];
       });
}




#pragma mark --- 总结

/*
 
1.layoutSubviews对subviews重新布局
 
2.当前View的layoutSubviews方法调用先于当前View的drawRect
 
3.setNeedsLayout在receiver标上一个需要被重新布局的标记，在系统runloop的下一个周期自动调用layoutSubviews //不懂的同学这里可以通过为RunLoop添加监听器, 查看RunLoop的运行状态
 
4.layoutIfNeeded方法如其名，UIKit会判断该receiver是否需要layout.
 
5.layoutIfNeeded遍历的不是superview链，应该是subviews链
 
7.testView 仅仅init初始化不会触发layoutSubviews 但是是用initWithFrame进行初始化时，并且rect的值不为CGRectZero时,并且调用addsubView才会触发 testView的layoutsubviews方法
8.设置testView的Frame会触发 testView layoutSubviews，前提是 testView的frame的size设置前后发生了变化  （前提这个testView已经加入了parentView）。 *** 注意：单单更改testView的位置并不会触发testView以及parentView的layoutsubviews方法

9. layoutIfNeeded不一定会调用layoutSubviews方法。setNeedsLayout一定会调用layoutSubviews方法（有延迟，在下一轮runloop结束前）如果想在当前runloop中立即刷新，调用顺序应该是款1. [self setNeedsLayout]; 2.[self layoutIfNeeded]; 反之可能会出现布局错误的问题。
 
 */


@end
