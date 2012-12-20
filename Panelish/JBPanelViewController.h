//
//  JBPanelViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JBSlidingPanelLeftState = 0,
    JBSlidingPanelCenterState = 1,
    JBSlidingPanelRightState = 2
} JBSlidingPanelState;

@protocol JBSlidingPanelChildViewController;

@interface JBPanelViewController : UIViewController

@property (nonatomic, weak) UIViewController <JBSlidingPanelChildViewController> *mainViewController;
@property (nonatomic, weak) UIViewController <JBSlidingPanelChildViewController> *leftViewController;
@property (nonatomic, weak) UIViewController <JBSlidingPanelChildViewController> *rightViewController;
@property (nonatomic) CGFloat overlapWidth;
@property (nonatomic, readonly) JBSlidingPanelState state;

- (void)setMainViewController:(UIViewController<JBSlidingPanelChildViewController> *)mainViewController animated:(BOOL)animated;
- (IBAction)revealLeft:(id)sender;
- (IBAction)revealRight:(id)sender;
- (IBAction)hideSides:(id)sender;

@end

@protocol JBSlidingPanelChildViewController <NSObject>

@property (nonatomic, strong) JBPanelViewController *slidingPanelViewController;
@property (nonatomic, getter = isActivePanelView) BOOL activePanelView;

@end
