//
//  JBSideViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/18/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JBPanelViewController.h"

@interface JBSideViewController : UITableViewController <JBSlidingPanelChildViewController>

@property (nonatomic) NSTextAlignment textAlignment;

/*
 Properties for complying with the JBSlidingPanelChildViewController protocol
 */
@property (nonatomic, strong) JBPanelViewController *slidingPanelViewController;
@property (nonatomic, getter = isActivePanelView) BOOL activePanelView;

@end
