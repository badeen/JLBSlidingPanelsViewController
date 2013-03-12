//
//  JBSideViewController.m
//  Panelish
//
//  Created by Jonathan Badeen on 12/18/12.
//  Copyright (c) 2012 Jonathan Badeen. All rights reserved.
//

#import "JBSideViewController.h"

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

    if ([self.delegate respondsToSelector:@selector(sideViewController:didSelectCellWithText:)]) {
        [self.delegate sideViewController:self didSelectCellWithText:[NSString stringWithFormat:@"Item %i", indexPath.row + 1]];
    }
}

@end
