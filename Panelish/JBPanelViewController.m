//
//  JBPanelViewController.m
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "JBPanelViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface JBPanelScrollView : UIScrollView

@end

@implementation JBPanelScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        view = nil;
    }
    return view;
}

@end




@interface JBPanelViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) JBPanelScrollView *scrollView;
@property (nonatomic, weak) UIView *mainView;
@property (nonatomic) BOOL overlapEnabled;
@property (nonatomic, readwrite) JBSlidingPanelState state;

@end

@implementation JBPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.overlapWidth = 60.0f;
    self.overlapEnabled = YES;
    self.state = JBSlidingPanelCenterState;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIScrollView *scrollView = self.scrollView = [[JBPanelScrollView alloc] initWithFrame:self.view.bounds];
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewTapped:)]];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * 3.0f, CGRectGetHeight(self.scrollView.bounds));
    scrollView.pagingEnabled = YES;
    scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0.0f);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
}

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMainViewController:(UIViewController<JBSlidingPanelChildViewController> *)mainViewController
{
    [_mainViewController beginAppearanceTransition:YES animated:NO];
    [_mainViewController removeFromParentViewController];
    [_mainViewController endAppearanceTransition];
    
    _mainViewController = mainViewController;
    [self addChildViewController:mainViewController];
    [_mainViewController beginAppearanceTransition:YES animated:NO];
    CGRect centeredRect = CGRectMake(CGRectGetWidth(self.scrollView.bounds),
                                     0.0f,
                                     CGRectGetWidth(self.scrollView.bounds),
                                     CGRectGetHeight(self.scrollView.bounds));
    _mainViewController.view.frame = centeredRect;
    [self.scrollView addSubview:_mainViewController.view];
    
    
    _mainViewController.activePanelView = YES;
    _leftViewController.activePanelView = NO;
    _rightViewController.activePanelView = NO;
}

- (void)setMainViewController:(UIViewController<JBSlidingPanelChildViewController> *)mainViewController animated:(BOOL)animated
{
    if (animated) {
        [_mainViewController beginAppearanceTransition:YES animated:YES];
        [UIView animateWithDuration:0.1 delay:0.0f options:UIViewAnimationCurveLinear animations:^{
            _mainViewController.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [_mainViewController removeFromParentViewController];
            [_mainViewController endAppearanceTransition];
            self.overlapEnabled = NO;
            _mainViewController = mainViewController;
            //[_mainViewController.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewTapped:)]];
            _mainViewController.view.frame = CGRectMake(CGRectGetWidth(self.scrollView.bounds),
                                                        0.0f,
                                                        CGRectGetWidth(self.scrollView.bounds),
                                                        CGRectGetHeight(self.scrollView.bounds));
            [_mainViewController beginAppearanceTransition:YES animated:NO];
            [self.scrollView addSubview:_mainViewController.view];
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveLinear animations:^{
                self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0.0f);
            } completion:^(BOOL finished) {
                [_mainViewController endAppearanceTransition];
                self.overlapEnabled = YES;
            }];
        }];
    } else {
        self.mainViewController = mainViewController;
    }
}

- (void)setLeftViewController:(UIViewController<JBSlidingPanelChildViewController> *)leftViewController
{
    _leftViewController = leftViewController;
    _leftViewController.slidingPanelViewController = self;
    
    [self addChildViewController:_leftViewController];
    [_leftViewController beginAppearanceTransition:YES animated:NO];
    CGRect rect = CGRectMake(0.0f,
                                     0.0f,
                                     CGRectGetWidth(self.view.bounds),
                                     CGRectGetHeight(self.view.bounds));
    _leftViewController.view.frame = rect;
    [self.view addSubview:_leftViewController.view];
    [self.view sendSubviewToBack:_leftViewController.view];
    [_leftViewController endAppearanceTransition];
}

- (void)setRightViewController:(UIViewController<JBSlidingPanelChildViewController> *)rightViewController
{
    _rightViewController = rightViewController;
    _rightViewController.slidingPanelViewController = self;
    
    [self addChildViewController:_rightViewController];
    [_rightViewController beginAppearanceTransition:YES animated:NO];
    CGRect rect = CGRectMake(0.0f,
                             0.0f,
                             CGRectGetWidth(self.view.bounds),
                             CGRectGetHeight(self.view.bounds));
    _rightViewController.view.frame = rect;
    [self.view addSubview:_rightViewController.view];
    [self.view sendSubviewToBack:_rightViewController.view];
    [_rightViewController endAppearanceTransition];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat mainViewWidth = CGRectGetWidth(self.mainViewController.view.frame);
    CGFloat scrollViewOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewContentSizeWidth = scrollView.contentSize.width;
    CGFloat xOffsetFromCenter = scrollViewOffsetX - mainViewWidth;
    
    if (self.overlapEnabled) {
        CGFloat adjustmentX = self.overlapWidth * (xOffsetFromCenter / mainViewWidth);
        self.mainViewController.view.transform = CGAffineTransformMakeTranslation(adjustmentX, 0.0f);
    }
    
    UIViewController *activeVC = nil;
    NSInteger index = (scrollViewOffsetX / scrollViewContentSizeWidth) * (scrollViewContentSizeWidth / mainViewWidth);
    switch (index) {
        case JBSlidingPanelLeftState:
            self.state = JBSlidingPanelLeftState;
            activeVC = self.leftViewController;
            break;
        case JBSlidingPanelCenterState:
            self.state = JBSlidingPanelCenterState;
            activeVC = self.mainViewController;
            break;
        case JBSlidingPanelRightState:
            self.state = JBSlidingPanelRightState;
            activeVC = self.rightViewController;
            break;
        default:
            break;
    }
    
    for (UIViewController <JBSlidingPanelChildViewController> *vc in @[self.leftViewController, self.rightViewController, self.mainViewController]) {
        if (activeVC == vc) {
            vc.activePanelView = YES;
        } else if (activeVC) {
            vc.activePanelView = NO;
        }
    }
    
    UIView *visibleSideView = nil;
    UIView *hiddenSideView = nil;
    if (scrollViewOffsetX > mainViewWidth) {
        visibleSideView = self.rightViewController.view;
        hiddenSideView = self.leftViewController.view;
    } else {
        visibleSideView = self.leftViewController.view;
        hiddenSideView = self.rightViewController.view;
    }
    
    CGFloat scale = MIN(1.0f, 0.95f + (0.05f * ABS(xOffsetFromCenter / mainViewWidth)));
    CGFloat alpha = 0.4f + (0.6f * ABS(xOffsetFromCenter / mainViewWidth));
    
    visibleSideView.hidden = NO;
    visibleSideView.transform = CGAffineTransformMakeScale(scale, scale);
    visibleSideView.alpha = alpha;
    
    hiddenSideView.hidden = YES;
    hiddenSideView.transform = CGAffineTransformIdentity;
    hiddenSideView.alpha = 1.0f;
    [self.view sendSubviewToBack:hiddenSideView];
}

#pragma mark - Actions

- (void)mainViewTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.scrollView.contentOffset.x != CGRectGetWidth(self.scrollView.frame)) {
        [self hideSides:nil];
    }
}

- (IBAction)revealLeft:(id)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(-10.0f, 0.0f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointZero;
        } completion:nil];
    }];
    //[self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)revealRight:(id)sender
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake((CGRectGetWidth(self.scrollView.frame) * 2.0f) + 10.0f, 0.0f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2.0f, 0.0f);
        } completion:nil];
    }];
    //[self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2.0f, 0.0f) animated:YES];
}

- (IBAction)hideSides:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame), 0.0f) animated:YES];
}

@end
