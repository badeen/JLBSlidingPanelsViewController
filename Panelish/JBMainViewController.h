//
//  JBMainViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/18/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLBSlidingPanelViewController.h"

@interface JBMainViewController : UINavigationController <JLBSlidingPanelChildViewController>

/*
 Properties for complying with the JBSlidingPanelChildViewController protocol
 */
@property (nonatomic, strong) JLBSlidingPanelViewController *slidingPanelViewController;
@property (nonatomic, getter = isActivePanelView) BOOL activePanelView;

@end
