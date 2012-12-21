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
#import "JBMainViewController.h"

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
    tableVC.title = @"Panelish";
    tableVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
    tableVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStyleBordered target:self action:@selector(showRight:)];
    JBMainViewController *mainVC = [[JBMainViewController alloc] initWithRootViewController:tableVC];
    self.viewController.mainViewController = mainVC;
    
    mainVC.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:mainVC.view.bounds] CGPath];
    mainVC.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    mainVC.view.layer.shadowOffset = CGSizeZero;
    mainVC.view.layer.shadowRadius = 8.0f;
    mainVC.view.layer.shadowOpacity = 1.0f;
    
    JBSideViewController *leftVC = [[JBSideViewController alloc] initWithStyle:UITableViewStylePlain];
    leftVC.textAlignment = NSTextAlignmentLeft;
    self.viewController.leftViewController = leftVC;
    
    JBSideViewController *rightVC = [[JBSideViewController alloc] initWithStyle:UITableViewStylePlain];
    rightVC.textAlignment = NSTextAlignmentRight;
    self.viewController.rightViewController = rightVC;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
