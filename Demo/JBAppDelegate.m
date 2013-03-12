//
//  JBAppDelegate.m
//  Panelish
//
//  Created by Jonathan Badeen on 12/17/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "JBAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

#import "JLBSlidingPanelViewController.h"
#import "JBSideViewController.h"

@implementation JBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    self.viewController  = [[JLBSlidingPanelViewController alloc] init];
    self.window.rootViewController = self.viewController;
    
    UITableViewController *tableVC = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tableVC.title = @"Panelish 1";
    tableVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
    tableVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStyleBordered target:self action:@selector(showRight:)];
    UINavigationController *mainVC = [[UINavigationController alloc] initWithRootViewController:tableVC];
    self.viewController.mainViewController = mainVC;
    
    JBSideViewController *leftVC = [[JBSideViewController alloc] initWithStyle:UITableViewStylePlain];
    leftVC.slidingPanelViewController = self.viewController;
    leftVC.textAlignment = NSTextAlignmentLeft;
    self.viewController.leftViewController = leftVC;
    
    JBSideViewController *rightVC = [[JBSideViewController alloc] initWithStyle:UITableViewStylePlain];
    rightVC.slidingPanelViewController = self.viewController;
    rightVC.textAlignment = NSTextAlignmentRight;
    self.viewController.rightViewController = rightVC;
    
    return YES;
}

#pragma mark - Actions

- (void)showLeft:(id)sender
{
    switch (self.viewController.state) {
        case JLBSlidingPanelLeftState:
            [self.viewController hideSides:sender];
            break;
        case JLBSlidingPanelCenterState:
            [self.viewController revealLeft:sender];
        default:
            break;
    }
}

- (void)showRight:(id)sender
{
    switch (self.viewController.state) {
        case JLBSlidingPanelRightState:
            [self.viewController hideSides:sender];
            break;
        case JLBSlidingPanelCenterState:
            [self.viewController revealRight:sender];
        default:
            break;
    }
}

@end
