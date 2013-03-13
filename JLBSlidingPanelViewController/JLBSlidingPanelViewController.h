//
//  JBPanelViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ENUM(NSUInteger, JLBSlidingPanelState) {
    JLBSlidingPanelStateLeft,
    JLBSlidingPanelStateCenter,
    JLBSlidingPanelStateRight
};

@interface JLBSlidingPanelViewController : UIViewController

@property (nonatomic, weak) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic) CGFloat overlapWidth;
@property (nonatomic, readonly) enum JLBSlidingPanelState state;

- (void)setMainViewController:(UIViewController *)mainViewController animated:(BOOL)animated;
- (IBAction)revealLeft:(id)sender;
- (IBAction)revealRight:(id)sender;
- (IBAction)hideSides:(id)sender;

@end
