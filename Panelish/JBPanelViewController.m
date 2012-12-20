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
@property (nonatomic, weak) UIViewController <JBSlidingPanelChildViewController> *visibleBackgroundViewController;

@end

@implementation JBPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
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
    
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * 3.0f, CGRectGetHeight(self.scrollView.bounds));
    scrollView.pagingEnabled = YES;
    scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0.0f);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    UIGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(mainViewTapped:)];
    [self.scrollView addGestureRecognizer:tapGR];
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

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return self.shouldAutomaticallyForwardAppearanceMethods && self.shouldAutomaticallyForwardRotationMethods;
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
}

- (void)setRightViewController:(UIViewController<JBSlidingPanelChildViewController> *)rightViewController
{
    _rightViewController = rightViewController;
    _rightViewController.slidingPanelViewController = self;
}

- (void)setVisibleBackgroundViewController:(UIViewController<JBSlidingPanelChildViewController> *)visibleBackgroundViewController
{
    if (_visibleBackgroundViewController != visibleBackgroundViewController) {
        
        if (_visibleBackgroundViewController) {
            [_visibleBackgroundViewController willMoveToParentViewController:nil];
            [_visibleBackgroundViewController viewWillDisappear:NO];
            _visibleBackgroundViewController.view.transform = CGAffineTransformIdentity;
            _visibleBackgroundViewController.view.alpha = 1.0f;
            [_visibleBackgroundViewController.view removeFromSuperview];
            [_visibleBackgroundViewController viewDidDisappear:NO];
            [_visibleBackgroundViewController removeFromParentViewController];
            _visibleBackgroundViewController.activePanelView = NO;
        }
        
        _visibleBackgroundViewController = visibleBackgroundViewController;
        
        if (_visibleBackgroundViewController) {
            [self addChildViewController:_visibleBackgroundViewController];
            [_visibleBackgroundViewController viewWillAppear:NO];
            [self.view addSubview:_visibleBackgroundViewController.view];
            [self.view sendSubviewToBack:_visibleBackgroundViewController.view];
            [UIView setAnimationsEnabled:NO];
            CGRect rect = CGRectMake(0.0f,
                                     0.0f,
                                     CGRectGetWidth(self.view.bounds),
                                     CGRectGetHeight(self.view.bounds));
            _visibleBackgroundViewController.view.frame = rect;
            [UIView setAnimationsEnabled:YES];
            [_visibleBackgroundViewController didMoveToParentViewController:self];
            _visibleBackgroundViewController.activePanelView = YES;
            self.mainViewController.activePanelView = NO;
        } else {
            self.mainViewController.activePanelView = YES;
        }
    }
}

#pragma mark - Scroll view delegate

const CGFloat kJLBMinimumBackgroundAlpha = 0.4f;
const CGFloat kJLBMinimumBackgroundScale = 0.95f;

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
    
    NSInteger index = (scrollViewOffsetX / scrollViewContentSizeWidth) * (scrollViewContentSizeWidth / mainViewWidth);
    switch (index) {
        case JBSlidingPanelLeftState:
            self.state = JBSlidingPanelLeftState;
            break;
        case JBSlidingPanelCenterState:
            self.state = JBSlidingPanelCenterState;
            break;
        case JBSlidingPanelRightState:
            self.state = JBSlidingPanelRightState;
            break;
        default:
            break;
    }
    
    if (scrollViewOffsetX < mainViewWidth) {
        self.visibleBackgroundViewController = self.leftViewController;
    } else if (scrollViewOffsetX > mainViewWidth) {
        self.visibleBackgroundViewController = self.rightViewController;
    } else {
        self.visibleBackgroundViewController = nil;
    }
    
    CGFloat scale = MIN(1.0f, kJLBMinimumBackgroundScale + ((1.0f - kJLBMinimumBackgroundScale) * ABS(xOffsetFromCenter / mainViewWidth)));
    CGFloat alpha = kJLBMinimumBackgroundAlpha + ((1.0f - kJLBMinimumBackgroundAlpha) * ABS(xOffsetFromCenter / mainViewWidth));
    
    self.visibleBackgroundViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    self.visibleBackgroundViewController.view.alpha = alpha;
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
    self.visibleBackgroundViewController = self.leftViewController;
    self.leftViewController.view.transform = CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale);
    self.leftViewController.view.alpha = kJLBMinimumBackgroundAlpha;
    self.mainViewController.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(-10.0f, 0.0f);
        self.leftViewController.view.transform = CGAffineTransformIdentity;
        self.leftViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.mainViewController.view.userInteractionEnabled = YES;
        self.state = JBSlidingPanelLeftState;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointZero;
            
        } completion:^(BOOL finished) {
            
            
        }];
    }];
}

- (IBAction)revealRight:(id)sender
{
    self.visibleBackgroundViewController = self.rightViewController;
    self.rightViewController.view.transform = CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale);
    self.rightViewController.view.alpha = kJLBMinimumBackgroundAlpha;
    self.mainViewController.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake((CGRectGetWidth(self.scrollView.frame) * 2.0f) + 10.0f, 0.0f);
        self.rightViewController.view.transform = CGAffineTransformIdentity;
        self.rightViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.mainViewController.view.userInteractionEnabled = YES;
        self.state = JBSlidingPanelRightState;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2.0f, 0.0f);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (IBAction)hideSides:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame), 0.0f) animated:YES];
}

@end
