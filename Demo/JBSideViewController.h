//
//  JBSideViewController.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/18/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JLBSlidingPanelViewController.h"

@protocol JBSideViewControllerDelegate;

@interface JBSideViewController : UITableViewController

@property (nonatomic, weak) id<JBSideViewControllerDelegate> delegate;
@property (nonatomic, weak) JLBSlidingPanelViewController *slidingPanelViewController;
@property (nonatomic) NSTextAlignment textAlignment;

@end

@protocol JBSideViewControllerDelegate <NSObject>

- (void)sideViewController:(JBSideViewController *)sideViewController didSelectCellWithText:(NSString *)text;

@end
