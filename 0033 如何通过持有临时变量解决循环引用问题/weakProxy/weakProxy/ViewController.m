//
//  ViewController.m
//  weakProxy
//
//  Created by songzhou on 2020/4/17.
//  Copyright © 2020 songzhou. All rights reserved.
//

#import "ViewController.h"
#import "TimerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"root";
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onNext:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)onNext:(id)sender {

    TimerViewController *vc = [TimerViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
