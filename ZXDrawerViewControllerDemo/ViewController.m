//
//  ViewController.m
//  ZXDrawerViewControllerDemo
//
//  Created by  on 8/9/2017.
//  Copyright © 2017 Chiba Tech. All rights reserved.
//

#import "ViewController.h"
#import "ZXDrawerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel * label = [[UILabel alloc] init];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor blueColor]];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:label];
    NSDictionary * labelDic = @{@"label":label};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:kNilOptions metrics:nil views:labelDic]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label]-0-|" options:kNilOptions metrics:nil views:labelDic]];
    
    [label setText:@"我是背景viewController"];
    
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openOrCloseDrawer)];
    [self.navigationItem setLeftBarButtonItem:item];
    [self.navigationItem setTitle:@"造轮子"];

}

- (void)openOrCloseDrawer {
    __kindof UIViewController * vc = self.parentViewController.parentViewController;
    if(vc && [vc isKindOfClass:[ZXDrawerViewController class]]){
        ZXDrawerViewController * drawerVC = vc;
        if(drawerVC.nowDrawerStatus == ZXDrawerViewControllerStatusClose){
            [drawerVC setDrawerStatus:ZXDrawerViewControllerStatusOpen AndShowAnimation:YES];
        }else if(drawerVC.nowDrawerStatus == ZXDrawerViewControllerStatusOpen){
            [drawerVC setDrawerStatus:ZXDrawerViewControllerStatusClose AndShowAnimation:YES];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
