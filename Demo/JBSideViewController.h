//
//  JBSideViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/18/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLBSlidingPanelViewController.h"

@interface JBSideViewController : UITableViewController

@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic, weak) JLBSlidingPanelViewController *slidingPanelViewController;

@end
