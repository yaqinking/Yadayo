//
//  YDSettingsGalleryModeViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/7/3.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDSettingsGalleryModeViewController.h"
#import "YDCoreDataStackManager.h"
#import "YDTableViewSwitchCell.h"

@interface YDSettingsGalleryModeViewController()

@property (nonatomic, strong) NSArray<YDSite *> *allSites;

@end

@implementation YDSettingsGalleryModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allSites = [[YDCoreDataStackManager sharedManager] allSites];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allSites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDTableViewSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:YDGalleryModeCellIdentifier forIndexPath:indexPath];
    YDSite *site = self.allSites[indexPath.row];
    cell.siteNameLabel.text = site.name;
    cell.siteSwitch.on = site.galleryMode.boolValue;
    [cell.siteSwitch addTarget:self action:@selector(changeGalleryMode:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)changeGalleryMode:(UISwitch *)sender {
    BOOL state = sender.on;
    NSIndexPath *indexPath = [self indexPathForView:sender];
    YDSite *site = self.allSites[indexPath.row];
    site.galleryMode = [NSNumber numberWithBool:state];
    [[YDCoreDataStackManager sharedManager] saveContext];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
    CGPoint hitPoint = [view convertPoint:CGPointZero toView:self.tableView];
    return [self.tableView indexPathForRowAtPoint:hitPoint];
}

@end
