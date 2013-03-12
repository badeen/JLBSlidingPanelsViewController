//
//  JBMainViewController.m
//  Panelish
//
//  Created by Jonathan Badeen on 12/18/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "JBMainViewController.h"

@interface JBMainViewController ()

@end

@implementation JBMainViewController

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Sliding panel view child protocol

- (void)setActivePanelView:(BOOL)activePanelView
{
    _activePanelView = activePanelView;
    
    self.visibleViewController.view.userInteractionEnabled = activePanelView;
}

@end
