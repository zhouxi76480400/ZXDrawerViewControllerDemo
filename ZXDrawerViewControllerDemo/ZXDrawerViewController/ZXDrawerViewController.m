//
//  ZXDrawerViewController.m
//  ZXDrawerViewControllerDemo
//
//  Created by  on 8/9/2017.
//  Copyright © 2017 Chiba Tech. All rights reserved.
//

#import "ZXDrawerViewController.h"

#define kDrawerShadowRadius 5.0f
#define kDrawerShadowOpacity 0.4f

#define kDrawerAnimationDurationDefault 0.2f
#define kContainerViewMaxAlpha 0.2f

@interface ZXDrawerViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong, nullable) NSLayoutConstraint * drawerConstraint;

@property (nonatomic, strong, nullable) NSLayoutConstraint * drawerWidthConstraint;

@property (nonatomic, strong, nullable) NSNumber *isAnimationRunningNow;

@property (readwrite, strong, nonatomic) UIScreenEdgePanGestureRecognizer *screenEdgePanGesture;

@property (readwrite, strong, nonatomic) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGPoint panStartLocation;

@property (nonatomic, assign) CGFloat panDelta;

@end

@implementation ZXDrawerViewController

@synthesize screenEdgePanGesture = _screenEdgePanGesture;
@synthesize panGesture = _panGesture;
@synthesize containerViewTapGesture = _containerViewTapGesture;

- (instancetype)init {
    self = [super init];
    if(self){
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self  = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.displayingViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.displayingViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.displayingViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.displayingViewController endAppearanceTransition];
}

- (UIViewController *)displayingViewController {
    switch (self.nowDrawerStatus) {
        case ZXDrawerViewControllerStatusClose:
            return self.mainViewController;
        case ZXDrawerViewControllerStatusOpen:
            return self.drawerViewController;
        default:
            return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.screenEdgePanGesture];
    [self.view addGestureRecognizer:self.panGesture];
    [self.view addSubview:self.containerView];
    NSDictionary * containerViewDic = @{@"_containerView":self.containerView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_containerView]-0-|" options:kNilOptions metrics:nil views:containerViewDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_containerView]-0-|" options:kNilOptions metrics:nil views:containerViewDic]];
    [self.containerView setHidden:YES];
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor clearColor];
        [view addGestureRecognizer:self.containerViewTapGesture];
        _containerView = view;
    }
    return _containerView;
}

- (void)commonInit {
    _drawerWidth = 0;
    _drawerAnimationDuration = kDrawerAnimationDurationDefault;
    _containerViewMaxAlpha = kContainerViewMaxAlpha;
    _screenEdgePanGestreEnabled = YES;
}

- (void)setMainViewController:(__kindof UIViewController *)mainViewController {
    if(self.mainViewController){
        [self.mainViewController willMoveToParentViewController:nil];
        [self.mainViewController.view removeFromSuperview];
        [self.mainViewController removeFromParentViewController];
    }
    _mainViewController = mainViewController;
    if(!mainViewController){
        return;
    }
    [self addChildViewController:_mainViewController];
    [_mainViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view insertSubview:_mainViewController.view atIndex:0];
    //set AutoLayout constraint
    NSDictionary * dic = @{@"main":_mainViewController.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[main]-0-|" options:kNilOptions metrics:nil views:dic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[main]-0-|" options:kNilOptions metrics:nil views:dic]];
    [_mainViewController didMoveToParentViewController:self];
}

- (void)setDrawerViewController:(__kindof UIViewController *)drawerViewController {
    if(self.drawerViewController){
        [self.drawerViewController willMoveToParentViewController:nil];
        [self.drawerViewController.view removeFromSuperview];
        [self.drawerViewController removeFromParentViewController];
    }
    _drawerViewController = drawerViewController;
    if(!drawerViewController){
        return;
    }
    [self addChildViewController:_drawerViewController];
    _drawerViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _drawerViewController.view.layer.shadowOpacity = kDrawerShadowOpacity;
    _drawerViewController.view.layer.shadowRadius = kDrawerShadowRadius;
    _drawerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:_drawerViewController.view];
    //set AutoLayout constraint
    //set drawer width
    if(!_drawerWidthConstraint){
        [self createDrawerConstraint];
    }
    [_drawerViewController.view addConstraint:_drawerWidthConstraint];
    NSLayoutAttribute from,to;
    from = NSLayoutAttributeRight;
    to = NSLayoutAttributeLeft;
    self.drawerConstraint = [NSLayoutConstraint constraintWithItem:_drawerViewController.view attribute:from relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:to multiplier:1 constant:0];
    [self.containerView addConstraint:_drawerConstraint];
    NSDictionary *dic = @{@"drawer":_drawerViewController.view};
    [self.containerView
     addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[drawer]-0-|" options:kNilOptions metrics:nil views:dic]];
    [self.containerView updateConstraints];
    [_drawerViewController updateViewConstraints];
    [_drawerViewController didMoveToParentViewController:self];
}

- (void)setDrawerStatus:(ZXDrawerViewControllerStatus) status AndShowAnimation:(BOOL) isShowAnimation {
    self.containerView.hidden = NO;
    NSTimeInterval duration = isShowAnimation ? self.drawerAnimationDuration : 0;
    BOOL isAnimationRunningNow = (status == ZXDrawerViewControllerStatusOpen);
    if(!_isAnimationRunningNow || [_isAnimationRunningNow boolValue] != isAnimationRunningNow) {
        _isAnimationRunningNow = [NSNumber numberWithBool:isAnimationRunningNow];
        [self.drawerViewController beginAppearanceTransition:isAnimationRunningNow animated:isShowAnimation];
        [self.mainViewController beginAppearanceTransition:!isAnimationRunningNow animated:isShowAnimation];
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (status == ZXDrawerViewControllerStatusClose) {
            self.drawerConstraint.constant = 0;
            self.containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        }
        else if (status == ZXDrawerViewControllerStatusOpen) {
            CGFloat constant = self.drawerWidth;
            self.drawerConstraint.constant = constant;
            self.containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:self.containerViewMaxAlpha];
        }
        [self.containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (status == ZXDrawerViewControllerStatusClose) {
            self.containerView.hidden = YES;
        }
        [self.drawerViewController endAppearanceTransition];
        [self.mainViewController endAppearanceTransition];
        self.isAnimationRunningNow = nil;
        
        // add delegate
        
    }];
}

- (void)setDrawerWidth:(CGFloat) width{
    if(_drawerViewController){
        if(!_drawerWidthConstraint){
            [self createDrawerConstraint];
        }
        _drawerWidth = width;
        _drawerWidthConstraint.constant = _drawerWidth;
    }
}

- (ZXDrawerViewControllerStatus)nowDrawerStatus{
    ZXDrawerViewControllerStatus isHidden = self.containerView.hidden ? ZXDrawerViewControllerStatusClose : ZXDrawerViewControllerStatusOpen;
    return isHidden;
}

-(void) createDrawerConstraint{
    self.drawerWidthConstraint = [NSLayoutConstraint constraintWithItem:_drawerViewController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:self.drawerWidth];
}

- (void)setNowDrawerStatus:(ZXDrawerViewControllerStatus) status{
    [self setDrawerStatus:status AndShowAnimation:NO];
}

- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGesture {
    if(!_screenEdgePanGesture){
        _screenEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
        _screenEdgePanGesture.edges = UIRectEdgeLeft;
        [_screenEdgePanGesture setDelegate:self];
    }
    return _screenEdgePanGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if(!_panGesture){
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
        [_panGesture setDelegate:self];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)containerViewTapGesture {
    if (!_containerViewTapGesture) {
        _containerViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContainerView:)];
        [_containerViewTapGesture setDelegate:self];
    }
    return _containerViewTapGesture;
}

-(void)handlePanAction:(id) sender {
    self.containerView.hidden = NO;
    if (![sender isKindOfClass:[UIGestureRecognizer class]]) {
        return;
    }
    UIGestureRecognizer *gesture = sender;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.panStartLocation = [gesture locationInView:self.view];
    }
    CGFloat delta = [gesture locationInView:self.view].x - self.panStartLocation.x;
    CGFloat constant;
    CGFloat backGroundAlpha;
    ZXDrawerViewControllerStatus drawerStatus = ZXDrawerViewControllerStatusOpen;
    drawerStatus = self.panDelta <= 0 ? ZXDrawerViewControllerStatusClose : ZXDrawerViewControllerStatusOpen;
    constant = fmin(self.drawerConstraint.constant + delta, self.drawerWidth);
    backGroundAlpha = fmin(self.containerViewMaxAlpha, self.containerViewMaxAlpha * fabs(constant) / self.drawerWidth);
    self.drawerConstraint.constant = constant;
    self.containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:backGroundAlpha];
    if (gesture.state == UIGestureRecognizerStateChanged) {
        BOOL isAnimationRunningNow = drawerStatus != ZXDrawerViewControllerStatusOpen;
        if (_isAnimationRunningNow == nil) {
            _isAnimationRunningNow = @(isAnimationRunningNow);
            [self.drawerViewController beginAppearanceTransition:isAnimationRunningNow animated:YES];
            [self.mainViewController beginAppearanceTransition:!isAnimationRunningNow animated:YES];
        }
        
        self.panStartLocation = [gesture locationInView:self.view];
        self.panDelta = delta;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self setDrawerStatus:drawerStatus AndShowAnimation:YES];
    }
}

- (void)didTapContainerView:(id)sender {
    [self setDrawerStatus:ZXDrawerViewControllerStatusClose AndShowAnimation:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.panGesture) {
        return self.nowDrawerStatus == ZXDrawerViewControllerStatusOpen;
    }else if (gestureRecognizer == self.screenEdgePanGesture) {
        return self.screenEdgePanGestreEnabled ? (self.nowDrawerStatus == ZXDrawerViewControllerStatusClose) : NO;
    }else {
        return touch.view == gestureRecognizer.view;
    }
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

@end
