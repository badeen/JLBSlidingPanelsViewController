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
@property (nonatomic, getter = isScrollingAnimationEnabled) BOOL scrollingAnimationEnabled;
@property (nonatomic, readwrite) JLBSlidingPanelState state;
@property (nonatomic, weak) UIViewController *visibleBackgroundViewController;
@property (strong, nonatomic) NSMutableSet *disabledViewsInMain;
@property (weak, nonatomic) UIView *faderView;
@property (nonatomic) BOOL overlapEnabled;
@end

@implementation JLBSlidingPanelViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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
    self.shadowRadius = 8.0f;
    self.shadowOpacity = 1.0f;
    self.overlapEnabled = YES;
    self.leftViewWidth = 260.0f;
    self.rightViewWidth = 260.0f;
    self.animateInBackgroundView = YES;    
    self.state = JLBSlidingPanelStateCenter;
    self.scrollingAnimationEnabled = YES;
    self.disabledViewsInMain = [NSMutableSet set];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *faderView = [[UIView alloc] initWithFrame:self.view.bounds];
    faderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    faderView.backgroundColor = [UIColor blackColor];
    faderView.alpha = kJLBMinimumBackgroundAlpha;
    [faderView setHidden:!self.animateInBackgroundView];
    [self.view addSubview:faderView];
    self.faderView = faderView;

    JBPanelScrollView *scrollView = [[JBPanelScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView = scrollView;

    scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0.0f);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;    
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    UIGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewTapped:)];
    tapGR.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGR];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    if(!CGRectEqualToRect(self.scrollView.frame, self.view.bounds)){
        self.scrollingAnimationEnabled = NO;
        self.mainViewController.view.transform = CGAffineTransformIdentity;        
        self.scrollView.frame = self.view.bounds;
        [self resizeScrollViewContentSize];
        CGRect centeredRect = self.scrollView.bounds;
        centeredRect.origin.x = CGRectGetWidth(self.scrollView.bounds);
        self.mainViewController.view.frame = centeredRect;
        self.mainViewController.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.mainViewController.view.bounds] CGPath];
        switch (self.state) {
            case JLBSlidingPanelStateLeft: {
                self.scrollView.contentOffset = CGPointZero;
                self.mainViewController.view.transform = CGAffineTransformMakeTranslation(-(CGRectGetWidth(self.view.bounds) - self.leftViewWidth), 0.0f);
                break;
            } case JLBSlidingPanelStateCenter: {
                self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0.0f);
                break;
            } case JLBSlidingPanelStateRight: {
                self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2.0f, 0.0f);
                self.mainViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.bounds)-self.rightViewWidth, 0.0f);
                break;
            }
        }
        self.scrollingAnimationEnabled = YES;
    }
}

- (void)resizeScrollViewContentSize
{
    CGFloat widthMultiplier = 1;
    if (_leftViewController) {
        widthMultiplier ++;
    }
    if (_rightViewController) {
        widthMultiplier ++;
    }
    CGSize contentSize = self.scrollView.bounds.size;
    contentSize.width *= widthMultiplier;
    self.scrollView.contentSize = contentSize;

    [self.view layoutSubviews];
}

- (BOOL)slidingEnabled{
    return self.scrollView.scrollEnabled;
}

- (void)setSlidingEnabled:(BOOL)slidingEnabled{
    self.scrollView.scrollEnabled = slidingEnabled;
}

- (void)setMainViewController:(UIViewController *)mainViewController
{
    [self setMainViewController:mainViewController animated:NO];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    _shadowOpacity = shadowOpacity;
    self.mainViewController.view.layer.shadowOpacity = shadowOpacity;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    self.mainViewController.view.layer.shadowRadius = shadowRadius;
}

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated
{
    if (_mainViewController != mainViewController) {
        UIViewController *fromVC = _mainViewController;
        [fromVC willMoveToParentViewController:nil];
        [fromVC viewWillDisappear:animated];
        
        _mainViewController = mainViewController;
        
        UIViewController *toVC = _mainViewController;
        if (toVC) {
            [self addChildViewController:toVC];
            CGRect centeredRect = self.scrollView.bounds;
            centeredRect.origin.x = CGRectGetWidth(self.scrollView.bounds);
            toVC.view.frame = centeredRect;

            toVC.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:toVC.view.bounds] CGPath];
            toVC.view.layer.shadowColor = [[UIColor blackColor] CGColor];
            toVC.view.layer.shadowOffset = CGSizeZero;
            toVC.view.layer.shadowRadius = self.shadowRadius;
            toVC.view.layer.shadowOpacity = self.shadowOpacity;

            [toVC viewWillAppear:animated];
        }
            
        if (animated && fromVC) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                switch (self.state) {
                    case JLBSlidingPanelStateLeft: {
                        if (self.leftViewController) {
                            self.mainViewController.view.transform = CGAffineTransformMakeTranslation(-(CGRectGetWidth(self.view.bounds) - self.leftViewWidth), 0.0f);
                        }
                        break;
                    } case JLBSlidingPanelStateCenter: {
                        self.mainViewController.view.transform = CGAffineTransformIdentity;
                        break;
                    } case JLBSlidingPanelStateRight: {
                        if (self.rightViewController) {
                            self.mainViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.bounds) - self.rightViewWidth, 0.0f);
                        }
                        break;
                    }
                }
            } completion:^(BOOL finished) {
                [fromVC.view removeFromSuperview];
                [fromVC viewDidDisappear:animated];
                [fromVC removeFromParentViewController];
                
                [self.scrollView addSubview:toVC.view];
                self.overlapEnabled = NO;
                
                [self hideSidesWithCompletion:^{
                    [toVC viewDidAppear:YES];
                    [toVC didMoveToParentViewController:self];
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
        }
    }
}

- (void)setVisibleBackgroundViewController:(UIViewController *)visibleBackgroundViewController
{
    if (_visibleBackgroundViewController != visibleBackgroundViewController) {
        
        if (_visibleBackgroundViewController) {
            [_visibleBackgroundViewController willMoveToParentViewController:nil];
            [_visibleBackgroundViewController viewWillDisappear:NO];
            _visibleBackgroundViewController.view.transform = CGAffineTransformIdentity;
            [_visibleBackgroundViewController.view removeFromSuperview];
            [_visibleBackgroundViewController viewDidDisappear:NO];
            [_visibleBackgroundViewController removeFromParentViewController];
        }
        
        _visibleBackgroundViewController = visibleBackgroundViewController;
        
        if (_visibleBackgroundViewController) {
            [self addChildViewController:_visibleBackgroundViewController];
            [_visibleBackgroundViewController viewWillAppear:NO];
            [self.view addSubview:_visibleBackgroundViewController.view];
            [self.view sendSubviewToBack:_visibleBackgroundViewController.view];
            [UIView setAnimationsEnabled:NO];
            CGRect rect = (CGRect){CGPointZero, self.view.bounds.size};
            _visibleBackgroundViewController.view.frame = rect;
            [UIView setAnimationsEnabled:YES];
            [_visibleBackgroundViewController didMoveToParentViewController:self];
        }
    }
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (_leftViewController != leftViewController) {
        _leftViewController = leftViewController;
        [self resizeScrollViewContentSize];
    }
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    if (_rightViewController != rightViewController) {
        _rightViewController = rightViewController;
        [self resizeScrollViewContentSize];
    }
}

- (void)setState:(JLBSlidingPanelState)state{
    if(_state != state){
        _state = state;        
        if([self.delegate respondsToSelector:@selector(slidingPanelViewController:didSlideToPanelState:)]){
            [self.delegate slidingPanelViewController:self didSlideToPanelState:state];
        }
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isScrollingAnimationEnabled) {
        CGFloat mainViewWidth = CGRectGetWidth(self.mainViewController.view.frame);
        CGFloat scrollViewOffsetX = scrollView.contentOffset.x;
        CGFloat scrollViewContentSizeWidth = scrollView.contentSize.width;
        CGFloat xOffsetFromCenter = scrollViewOffsetX - mainViewWidth;
        
        if (self.overlapEnabled) {
            CGFloat width = self.rightViewWidth;
            if (scrollViewOffsetX < mainViewWidth) {
                width = self.leftViewWidth;
            }
            CGFloat adjustmentX = (CGRectGetWidth(self.view.bounds) - width) * (xOffsetFromCenter / mainViewWidth);
            self.mainViewController.view.transform = CGAffineTransformMakeTranslation(adjustmentX, 0.0f);
        }
        
        self.state = (scrollViewOffsetX / scrollViewContentSizeWidth) * (scrollViewContentSizeWidth / mainViewWidth);

        if (scrollViewOffsetX < mainViewWidth) {
            self.visibleBackgroundViewController = self.leftViewController;
        } else if (scrollViewOffsetX > mainViewWidth) {
            self.visibleBackgroundViewController = self.rightViewController;
        } else {
            self.visibleBackgroundViewController = nil;
            self.overlapEnabled = YES;
        }

        CGFloat abs = ABS(xOffsetFromCenter / mainViewWidth);
        CGFloat scale = MIN(1.0f, kJLBMinimumBackgroundScale + ((1.0f - kJLBMinimumBackgroundScale) * abs));
        CGFloat alpha = kJLBMinimumBackgroundAlpha + ((1.0f - kJLBMinimumBackgroundAlpha) * ABS(xOffsetFromCenter / mainViewWidth));
        [self setFaderViewAlpha:1-alpha andVisibleBackgroundViewControllerViewTransform:CGAffineTransformMakeScale(scale, scale)];

        if([self.delegate respondsToSelector:@selector(slidingPanelViewController:didSlideWithOffsetFromCenter:)]){
            [self.delegate slidingPanelViewController:self didSlideWithOffsetFromCenter:xOffsetFromCenter];
        }
    }
}

- (void)setAnimateInBackgroundView:(BOOL)animateInBackgroundView{
    _animateInBackgroundView = animateInBackgroundView;
    [self.faderView setHidden:!animateInBackgroundView];
}

- (void)setFaderViewAlpha:(CGFloat)alpha andVisibleBackgroundViewControllerViewTransform:(CGAffineTransform)transform
{
    if (self.animateInBackgroundView) {
        self.visibleBackgroundViewController.view.transform = transform;
        self.faderView.alpha = alpha;
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
    if (!self.leftViewController) {
        return;
    }

    BOOL enableUserInteraction = NO;
    if(self.leftViewController.view.userInteractionEnabled){
        self.leftViewController.view.userInteractionEnabled = NO;
        enableUserInteraction = YES;
    }

    self.visibleBackgroundViewController = self.leftViewController;
    self.scrollingAnimationEnabled = NO;
    [self setFaderViewAlpha:kJLBMinimumBackgroundAlpha andVisibleBackgroundViewControllerViewTransform:CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale)];

    if([self.delegate respondsToSelector:@selector(slidingPanelViewController:willAnimateToPanelState:)]){
        [self.delegate slidingPanelViewController:self willAnimateToPanelState:JLBSlidingPanelStateLeft];
    }

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(-10.0f, 0.0f);
        self.mainViewController.view.transform = CGAffineTransformMakeTranslation(-(CGRectGetWidth(self.view.bounds) - self.leftViewWidth), 0.0f);
        [self setFaderViewAlpha:0 andVisibleBackgroundViewControllerViewTransform:CGAffineTransformIdentity];
    } completion:^(BOOL finished) {
        self.state = JLBSlidingPanelStateLeft;
        self.scrollingAnimationEnabled = YES;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointZero;
        } completion:^(BOOL finished2){
            if(enableUserInteraction){
                self.leftViewController.view.userInteractionEnabled = YES;
            }
        }];
    }];
}

- (IBAction)revealRight:(id)sender
{
    if (!self.rightViewController) {
        return;
    }

    BOOL enableUserInteraction = NO;
    if(self.rightViewController.view.userInteractionEnabled){
        self.rightViewController.view.userInteractionEnabled = NO;
        enableUserInteraction = YES;
    }

    self.visibleBackgroundViewController = self.rightViewController;
    self.scrollingAnimationEnabled = NO;
    [self setFaderViewAlpha:kJLBMinimumBackgroundAlpha andVisibleBackgroundViewControllerViewTransform:CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale)];

    if([self.delegate respondsToSelector:@selector(slidingPanelViewController:willAnimateToPanelState:)]){
        [self.delegate slidingPanelViewController:self willAnimateToPanelState:JLBSlidingPanelStateRight];
    }

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake((CGRectGetWidth(self.scrollView.frame) * 2.0f) + 10.0f, 0.0f);
        self.mainViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.bounds)-self.rightViewWidth, 0.0f);
        [self setFaderViewAlpha:0 andVisibleBackgroundViewControllerViewTransform:CGAffineTransformIdentity];
    } completion:^(BOOL finished) {
        self.state = JLBSlidingPanelStateRight;
        self.scrollingAnimationEnabled = YES;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame) * 2.0f, 0.0f);
        } completion:^(BOOL finished2) {
            if(enableUserInteraction) {
                self.rightViewController.view.userInteractionEnabled = YES;
            }
        }];
    }];
}

- (IBAction)hideSides:(id)sender
{
    if([self.delegate respondsToSelector:@selector(slidingPanelViewController:willAnimateToPanelState:)]){
        [self.delegate slidingPanelViewController:self willAnimateToPanelState:JLBSlidingPanelStateCenter];
    }
    
    [self hideSidesWithCompletion:nil];
}

- (void)hideSidesWithCompletion:(void (^)(void))completion
{
    self.scrollingAnimationEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0.0f);
        self.mainViewController.view.transform = CGAffineTransformIdentity;
        [self setFaderViewAlpha:kJLBMinimumBackgroundAlpha andVisibleBackgroundViewControllerViewTransform:CGAffineTransformMakeScale(kJLBMinimumBackgroundScale, kJLBMinimumBackgroundScale)];
    } completion:^(BOOL finished) {
        self.scrollingAnimationEnabled = YES;
        self.state = JLBSlidingPanelStateCenter;
        self.visibleBackgroundViewController = nil;
        if (completion) {
            completion();
        }
    }];
}

@end
