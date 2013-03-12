//
//  JBAppDelegate.h
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLBSlidingPanelViewController;

@interface JBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JLBSlidingPanelViewController *viewController;

@end
