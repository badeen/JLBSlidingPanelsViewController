//
//  JBPanelViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JLBSlidingPanelLeftState = 0,
    JLBSlidingPanelCenterState = 1,
    JLBSlidingPanelRightState = 2
} JLBSlidingPanelState;

@protocol JLBSlidingPanelChildViewController;

@interface JLBSlidingPanelViewController : UIViewController

@property (nonatomic, weak) UIViewController <JLBSlidingPanelChildViewController> *mainViewController;
@property (nonatomic, strong) UIViewController <JLBSlidingPanelChildViewController> *leftViewController;
@property (nonatomic, strong) UIViewController <JLBSlidingPanelChildViewController> *rightViewController;
@property (nonatomic) CGFloat overlapWidth;
@property (nonatomic, readonly) JLBSlidingPanelState state;

- (void)setMainViewController:(UIViewController<JLBSlidingPanelChildViewController> *)mainViewController animated:(BOOL)animated;
- (IBAction)revealLeft:(id)sender;
- (IBAction)revealRight:(id)sender;
- (IBAction)hideSides:(id)sender;

@end

@protocol JLBSlidingPanelChildViewController <NSObject>

@property (nonatomic, strong) JLBSlidingPanelViewController *slidingPanelViewController;
@property (nonatomic, getter = isActivePanelView) BOOL activePanelView;

@end
