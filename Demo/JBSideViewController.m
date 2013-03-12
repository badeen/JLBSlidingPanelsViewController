//
//  JBSideViewController.m
//  Panelish
//
//  Created by Jonathan Badeen on 12/18/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "JBSideViewController.h"

#import "JBMainViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation JBSideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor blackColor];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.textLabel.textAlignment = self.textAlignment;
    cell.textLabel.text = [NSString stringWithFormat:@"Item %i", indexPath.row + 1];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.textAlignment == NSTextAlignmentRight) {
        self.slidingPanelViewController.providesPresentationContextTransitionStyle = YES;
        self.slidingPanelViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        UITableViewController *vc = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.title = [NSString stringWithFormat:@"Item %i", indexPath.row + 1];
        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)];
        
        JBMainViewController *presentedVC = [[JBMainViewController alloc] initWithRootViewController:vc];
        [self.slidingPanelViewController presentViewController:presentedVC animated:NO completion:^{
            presentedVC.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.slidingPanelViewController.view.frame), 0.0f);
            presentedVC.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:presentedVC.view.bounds] CGPath];
            presentedVC.view.layer.shadowColor = [[UIColor blackColor] CGColor];
            presentedVC.view.layer.shadowOffset = CGSizeZero;
            presentedVC.view.layer.shadowRadius = 8.0f;
            presentedVC.view.layer.shadowOpacity = 1.0f;
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationCurveLinear animations:^{
                self.slidingPanelViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(self.slidingPanelViewController.view.frame), 0.0f);
                self.slidingPanelViewController.view.alpha = 0.3f;
                presentedVC.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
    } else {
        NSString *vcTitle = [NSString stringWithFormat:@"Panelish %i", indexPath.row + 1];
        if ([self.slidingPanelViewController.mainViewController.title isEqualToString:vcTitle]) {
            [self.slidingPanelViewController hideSides:nil];
        } else {
            UITableViewController *tableVC = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            tableVC.title = vcTitle;
            tableVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
            tableVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Right" style:UIBarButtonItemStyleBordered target:self action:@selector(showRight:)];
            JBMainViewController *mainVC = [[JBMainViewController alloc] initWithRootViewController:tableVC];
            
            mainVC.view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:mainVC.view.bounds] CGPath];
            mainVC.view.layer.shadowColor = [[UIColor blackColor] CGColor];
            mainVC.view.layer.shadowOffset = CGSizeZero;
            mainVC.view.layer.shadowRadius = 8.0f;
            mainVC.view.layer.shadowOpacity = 1.0f;
            
            [self.slidingPanelViewController setMainViewController:mainVC animated:YES];
        }
    }
}

#pragma mark - Actions

- (void)showLeft:(id)sender
{
    switch (self.slidingPanelViewController.state) {
        case JLBSlidingPanelLeftState:
            [self.slidingPanelViewController hideSides:sender];
            break;
        case JLBSlidingPanelCenterState:
            [self.slidingPanelViewController revealLeft:sender];
        default:
            break;
    }
}

- (void)showRight:(id)sender
{
    switch (self.slidingPanelViewController.state) {
        case JLBSlidingPanelRightState:
            [self.slidingPanelViewController hideSides:sender];
            break;
        case JLBSlidingPanelCenterState:
            [self.slidingPanelViewController revealRight:sender];
        default:
            break;
    }
}

- (void)close:(id)sender
{
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationCurveLinear animations:^{
        self.slidingPanelViewController.presentedViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.slidingPanelViewController.view.frame), 0.0f);
        self.slidingPanelViewController.view.transform = CGAffineTransformIdentity;
        self.slidingPanelViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.slidingPanelViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
            self.slidingPanelViewController.providesPresentationContextTransitionStyle = NO;
            self.slidingPanelViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        }];
    }];
}

@end
