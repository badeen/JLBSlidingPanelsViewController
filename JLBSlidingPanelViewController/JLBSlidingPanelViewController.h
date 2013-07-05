//
//  JBPanelViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JLBSlidingPanelState) {
    JLBSlidingPanelStateLeft,
    JLBSlidingPanelStateCenter,
    JLBSlidingPanelStateRight
};

@protocol JLBSlidingPanelViewControllerDelegate;

@interface JLBSlidingPanelViewController : UIViewController

@property (nonatomic, weak) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, readonly) JLBSlidingPanelState state;
@property (nonatomic, weak) id<JLBSlidingPanelViewControllerDelegate> delegate;
@property (nonatomic) CGFloat rightViewWidth;
@property (nonatomic) CGFloat leftViewWidth;
@property (nonatomic) BOOL slidingEnabled;
@property (nonatomic) BOOL animateInBackgroundView;

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated;
- (IBAction)revealLeft:(id)sender;
- (IBAction)revealRight:(id)sender;
- (IBAction)hideSides:(id)sender;

@end

@protocol JLBSlidingPanelViewControllerDelegate <NSObject>

@optional
- (void)slidingPanelViewController:(JLBSlidingPanelViewController *)slidingPanelViewController
              didSlideToPanelState:(JLBSlidingPanelState)slideToPanelState;

@end
