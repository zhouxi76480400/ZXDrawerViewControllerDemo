//
//  ZXDrawerViewController.h
//  ZXDrawerViewControllerDemo
//
//  Created by  on 8/9/2017.
//  Copyright © 2017 Chiba Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXDrawerViewController : UIViewController

typedef NS_ENUM(NSInteger,ZXDrawerViewControllerStatus){
    ZXDrawerViewControllerStatusClose,
    ZXDrawerViewControllerStatusOpen
};

@property (nonatomic,assign) ZXDrawerViewControllerStatus nowDrawerStatus;

@property (nonatomic,strong) __kindof UIViewController * mainViewController;

@property (nonatomic,strong) __kindof UIViewController * drawerViewController;

@property (nonatomic,assign) NSTimeInterval drawerAnimationDuration;

@property (nonatomic,assign) CGFloat containerViewMaxAlpha;

@property (nonatomic,assign,setter=setDrawerWidth:) CGFloat drawerWidth;

@property (nonatomic,assign) BOOL screenEdgePanGestreEnabled;

@property (nonatomic,strong,readonly) UIScreenEdgePanGestureRecognizer *screenEdgePanGesture;

@property (nonatomic,strong,readonly) UIPanGestureRecognizer *panGesture;

@property (nonatomic,strong) UITapGestureRecognizer *containerViewTapGesture;

- (void)setDrawerStatus:(ZXDrawerViewControllerStatus) status AndShowAnimation:(BOOL) isShowAnimation;

- (void)setDrawerWidth:(CGFloat) width;

@end
