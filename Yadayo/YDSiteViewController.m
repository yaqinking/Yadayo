//
//  ViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDSiteViewController.h"
#import "YDCoreDataStackManager.h"
#import "YDTagsViewController.h"
#import "YDTagTableViewCell.h"
#import "YDRSSViewController.h"
#import "YDKeywordsViewController.h"

@interface YDSiteViewController ()

@property (nonatomic, strong) NSArray<YDCategory *> *categories;

@end

@implementation YDSiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupNavigationBar];
//    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.categories = [[YDCoreDataStackManager sharedManager] categories];
    [self.tableView reloadData];
}

- (void)setupNavigationBar {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor        = [UIColor whiteColor];
    navBar.barTintColor     = nil;
    navBar.shadowImage      = nil;
    navBar.translucent      = YES;
    navBar.barStyle         = UIBarStyleBlackTranslucent;
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (void)setupTableView {
    CGFloat red = 33.0;
    CGFloat green = 33.0;
    CGFloat blue = 33.0;
    CGFloat alpha = 255.0;
    UIColor *color = [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:(alpha/255.0)];
    
    self.tableView.backgroundColor = color;
    self.tableView.separatorColor  = color;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories[section].sites.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categories.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.categories[section].name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YDSiteCellIdentifier];
    YDSite *site = [self siteForRowAtIndexPath:indexPath];
    cell.textLabel.text = site.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    YDSite *site = [self siteForRowAtIndexPath:indexPath];
    NSLog(@"Site %@",site);
    switch (site.type.integerValue) {
        case 1:
            [self performDanbooruSites:site];
            break;
        case 2:
            [self performBTSites:site];
            break;
        case 3:
            [self performRSSSites:site];
            break;
        default:
            [self performRSSSites:site];
            break;
    }
}

- (void)performDanbooruSites:(YDSite *)site {
    YDTagsViewController *tagsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YDDanbooruSites"];
    tagsVC.site = site;
    [self.navigationController pushViewController:tagsVC animated:YES];
}

- (void)performBTSites:(YDSite *)site {
    YDKeywordsViewController *keywordsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YDBTSites"];
    keywordsVC.site = site;
    [self.navigationController pushViewController:keywordsVC animated:YES];
}

- (void)performRSSSites:(YDSite *)site {
    YDRSSViewController *rssVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YDRSSSites"];
    rssVC.site = site;
    [self.navigationController pushViewController:rssVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YDSite *site = [self siteForRowAtIndexPath:indexPath];
        YDCategory *category = self.categories[indexPath.section];
        [category removeSitesObject:site];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[YDCoreDataStackManager sharedManager] saveContext];
    }
}

- (YDSite *)siteForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDCategory *cat = self.categories[indexPath.section];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [[cat.sites sortedArrayUsingDescriptors:@[sortDescriptor]] objectAtIndex:indexPath.row];
}

- (NSArray<YDCategory *> *)categories {
    if (!_categories) {
        _categories = [[YDCoreDataStackManager sharedManager] categories];
    }
    return _categories;
}

@end
