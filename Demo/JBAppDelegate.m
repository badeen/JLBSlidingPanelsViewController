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

@interface JBAppDelegate ()
<UIApplicationDelegate, JBSideViewControllerDelegate>
@end

@implementation JBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    JLBSlidingPanelViewController *viewController = [[JLBSlidingPanelViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    UITableViewController *tableVC = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    tableVC.title = @"Panelish 1";
    tableVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
    tableVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStyleBordered target:self action:@selector(showRight:)];
    UINavigationController *mainVC = [[UINavigationController alloc] initWithRootViewController:tableVC];
    viewController.mainViewController = mainVC;
    
    JBSideViewController *leftVC = [[JBSideViewController alloc] initWithStyle:UITableViewStylePlain];
    leftVC.textAlignment = NSTextAlignmentLeft;
    leftVC.delegate = self;    
    viewController.leftViewController = leftVC;

    JBSideViewController *rightVC = [[JBSideViewController alloc] initWithStyle:UITableViewStylePlain];
    rightVC.textAlignment = NSTextAlignmentRight;
    rightVC.delegate = self;
    viewController.rightViewController = rightVC;

    return YES;
}

#pragma mark - JBSideViewControllerDelegate

- (void)sideViewController:(JBSideViewController *)sideViewController didSelectCellWithText:(NSString *)text{
    JLBSlidingPanelViewController *viewController = (JLBSlidingPanelViewController *)self.window.rootViewController;
    [[(UINavigationController *)viewController.mainViewController visibleViewController] setTitle:text];
    [viewController hideSides:nil];
}

#pragma mark - Actions

- (void)showLeft:(id)sender
{
    JLBSlidingPanelViewController *viewController = (JLBSlidingPanelViewController *)self.window.rootViewController;
    switch (viewController.state) {
        case JLBSlidingPanelStateLeft:
            [viewController hideSides:sender];
            break;
        case JLBSlidingPanelStateCenter:
            [viewController revealLeft:sender];
        default:
            break;
    }
}

- (void)showRight:(id)sender
{
    JLBSlidingPanelViewController *viewController = (JLBSlidingPanelViewController *)self.window.rootViewController;    
    switch (viewController.state) {
        case JLBSlidingPanelStateRight:
            [viewController hideSides:sender];
            break;
        case JLBSlidingPanelStateCenter:
            [viewController revealRight:sender];
        default:
            break;
    }
}

@end
