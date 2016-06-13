//
//  YDEPReminderSettingViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/30.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDEPReminderSettingViewController.h"
#import "YDCoreDataStackManager.h"

@interface YDEPReminderSettingViewController ()

@property (nonatomic, strong) NSArray<YDSite *> *btSites;
@property (nonatomic, strong) NSString *reminderSiteName;
@property (nonatomic, copy) NSIndexPath *reminderIndexPath;

@end

@implementation YDEPReminderSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reminderSiteName = [[NSUserDefaults standardUserDefaults] stringForKey:kReminderSiteName];
    self.btSites = [[YDCoreDataStackManager sharedManager] savedBTSites];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.btSites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YDSiteCellIdentifier forIndexPath:indexPath];
    YDSite *site = self.btSites[indexPath.row];
    cell.textLabel.text = site.name;
    if (self.reminderSiteName && [site.name isEqualToString:self.reminderSiteName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.reminderIndexPath = indexPath;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.reminderIndexPath) {
        UITableViewCell *reminderCell = [self.tableView cellForRowAtIndexPath:self.reminderIndexPath];
        reminderCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.reminderIndexPath = indexPath;
        NSString *reminderSiteName = [[self.btSites objectAtIndex:indexPath.row] name];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:reminderSiteName forKey:kReminderSiteName];
        [defaults synchronize];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
