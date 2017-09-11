//
//  DrawerContentViewController.m
//  ZXDrawerViewControllerDemo
//
//  Created by  on 8/9/2017.
//  Copyright © 2017 Chiba Tech. All rights reserved.
//

#import "DrawerContentViewController.h"

@interface DrawerContentViewController ()

@end

@implementation DrawerContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor redColor]];
    
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    [view setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:view];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aaaa)]];

    
}

-(void) aaaa{
    NSLog(@"cnm");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
