//
//  JBPanelViewController.m
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "JLBSlidingPanelViewController.h"

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


const CGFloat kJLBMinimumBackgroundAlpha = 0.4f;
const CGFloat kJLBMinimumBackgroundScale = 0.95f;


@interface JLBSlidingPanelViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) JBPanelScrollView *scrollView;
@property (nonatomic, weak) UIView *mainView;
@property (nonatomic) BOOL overlapEnabled;
@property (nonatomic, getter = isScrollingAnimationEnabled) BOOL scrollingAnimationEnabled;
@property (nonatomic, readwrite) JLBSlidingPanelState state;
@property (nonatomic, weak) UIViewController <JLBSlidingPanelChildViewController> *visibleBackgroundViewController;

@end

@implementation JLBSlidingPanelViewController

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
    self.state = JLBSlidingPanelCenterState;
    self.scrollingAnimationEnabled = YES;
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

- (void)setMainViewController:(UIViewController<JLBSlidingPanelChildViewController> *)mainViewController
{
    [self setMainViewController:mainViewController animated:NO];
}

- (void)setMainViewController:(UIViewController<JLBSlidingPanelChildViewController> *)mainViewController animated:(BOOL)animated
{
    if (_mainViewController != mainViewController) {
        self.view.userInteractionEnabled = NO;
        UIViewController *fromVC = _mainViewController;
        [fromVC willMoveToParentViewController:nil];
        [fromVC viewWillDisappear:animated];
        
        _mainViewController = mainViewController;
        
        UIViewController <JLBSlidingPanelChildViewController> *toVC = _mainViewController;
        if (toVC) {
            [self addChildViewController:toVC];
            CGRect centeredRect = CGRectMake(CGRectGetWidth(self.scrollView.bounds),
                                             0.0f,
                                             CGRectGetWidth(self.scrollView.bounds),
                                             CGRectGetHeight(self.scrollView.bounds));
            toVC.view.frame = centeredRect;
            [toVC viewWillAppear:animated];
        }
            
        if (animated && fromVC) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(self.overlapWidth, 0.0f);
            } completion:^(BOOL finished) {
                [fromVC.view removeFromSuperview];
                [fromVC viewDidDisappear:animated];
                [fromVC removeFromParentViewController];
                
                [self.scrollView addSubview:toVC.view];
                self.overlapEnabled = NO;
                
                [self hideSidesWithCompletion:^{
                    [toVC viewDidAppear:YES];
                    [toVC didMoveToParentViewController:self];
                    self.view.userInteractionEnabled = YES;
                    self.overlapEnabled = YES;
                }];
            }];
        } else {
            [fromVC.view removeFromSuperview];
            [fromVC viewDidDisappear:animated];
            [fromVC removeFromParentViewController];
            
            [self.scrollView addSubview:toVC.view];
            [toVC viewDidAppear:YES];
            [toVC didMoveToParentViewController:self];
            self.view.userInteractionEnabled = YES;
        }
    }
}

- (void)setLeftViewController:(UIViewController<JLBSlidingPanelChildViewController> *)leftViewController
{
    _leftViewController = leftViewController;
    _leftViewController.slidingPanelViewController = self;
}

- (void)setRightViewController:(UIViewController<JLBSlidingPanelChildViewController> *)rightViewController
{
    _rightViewController = rightViewController;
    _rightViewController.slidingPanelViewController = self;
}

- (void)setVisibleBackgroundViewController:(UIViewController<JLBSlidingPanelChildViewController> *)visibleBackgroundViewController
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.mainViewController.view.userInteractionEnabled = NO;
    self.leftViewController.view.userInteractionEnabled = NO;
    self.rightViewController.view.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.mainViewController.view.userInteractionEnabled = YES;
    self.visibleBackgroundViewController.view.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isScrollingAnimationEnabled) {
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
            case JLBSlidingPanelLeftState:
                self.state = JLBSlidingPanelLeftState;
                break;
            case JLBSlidingPanelCenterState:
                self.state = JLBSlidingPanelCenterState;
                break;
            case JLBSlidingPanelRightState:
                self.state = JLBSlidingPanelRightState;
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
            self.overlapEnabled = YES;
        }
        
        CGFloat scale = MIN(1.0f, kJLBMinimumBackgroundScale + ((1.0f - kJLBMinimumBackgroundScale) * ABS(xOffsetFromCenter / mainViewWidth)));
        CGFloat alpha = kJLBMinimumBackgroundAlpha + ((1.0f - kJLBMinimumBackgroundAlpha) * ABS(xOffsetFromCenter / mainViewWidth));
        
        self.visibleBackgroundViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.visibleBackgroundViewController.view.alpha = alpha;
    }
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
    self.visibleBackgroundViewController.view.transform = CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale);
    self.visibleBackgroundViewController.view.alpha = kJLBMinimumBackgroundAlpha;
    self.view.userInteractionEnabled = NO;
    self.scrollingAnimationEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(-10.0f, 0.0f);
        self.visibleBackgroundViewController.view.transform = CGAffineTransformIdentity;
        self.visibleBackgroundViewController.view.alpha = 1.0f;
        self.mainViewController.view.transform = CGAffineTransformMakeTranslation(-self.overlapWidth, 0.0f);
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.state = JLBSlidingPanelLeftState;
        self.scrollingAnimationEnabled = YES;
        self.visibleBackgroundViewController.view.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointZero;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (IBAction)revealRight:(id)sender
{
    self.visibleBackgroundViewController = self.rightViewController;
    self.visibleBackgroundViewController.view.transform = CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale);
    self.visibleBackgroundViewController.view.alpha = kJLBMinimumBackgroundAlpha;
    self.view.userInteractionEnabled = NO;
    self.scrollingAnimationEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake((CGRectGetWidth(self.scrollView.frame) * 2.0f) + 10.0f, 0.0f);
        self.visibleBackgroundViewController.view.transform = CGAffineTransformIdentity;
        self.visibleBackgroundViewController.view.alpha = 1.0f;
        self.mainViewController.view.transform = CGAffineTransformMakeTranslation(self.overlapWidth, 0.0f);
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.state = JLBSlidingPanelRightState;
        self.scrollingAnimationEnabled = YES;
        self.visibleBackgroundViewController.view.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2.0f, 0.0f);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (IBAction)hideSides:(id)sender
{
    [self hideSidesWithCompletion:nil];
}

- (void)hideSidesWithCompletion:(void (^)(void))completion
{
    self.view.userInteractionEnabled = NO;
    self.scrollingAnimationEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0.0f);
        self.visibleBackgroundViewController.view.transform = CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale);
        self.visibleBackgroundViewController.view.alpha = kJLBMinimumBackgroundAlpha;
        self.mainViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.scrollingAnimationEnabled = YES;
        self.state = JLBSlidingPanelCenterState;
        self.visibleBackgroundViewController = nil;
        if (completion) {
            completion();
        }
    }];
}

@end
