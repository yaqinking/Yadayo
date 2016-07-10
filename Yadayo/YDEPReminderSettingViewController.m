//
//  YDEPReminderSettingViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/30.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDEPReminderSettingViewController.h"
#import "YDCoreDataStackManager.h"
#import "YDTableViewSwitchCell.h"

@interface YDEPReminderSettingViewController ()

@property (nonatomic, strong) NSArray<YDSite *> *sites;

@end

@implementation YDEPReminderSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sites = [[YDCoreDataStackManager sharedManager] allSites];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDTableViewSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:YDSiteCellIdentifier forIndexPath:indexPath];
    YDSite *site = self.sites[indexPath.row];
    cell.siteNameLabel.text = site.name;
    [cell.siteSwitch setOn:site.notification.boolValue animated:YES];
    [cell.siteSwitch addTarget:self action:@selector(changeNotifications:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)changeNotifications:(UISwitch *)sender {
    BOOL state = sender.on;
    NSIndexPath *indexPath = [self indexPathForView:sender];
    YDSite *site = self.sites[indexPath.row];
    site.notification = [NSNumber numberWithBool:state];
    [[YDCoreDataStackManager sharedManager] saveContext];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
    CGPoint hitPoint = [view convertPoint:CGPointZero toView:self.tableView];
    return [self.tableView indexPathForRowAtPoint:hitPoint];
}

@end
