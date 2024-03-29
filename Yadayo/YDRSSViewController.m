//
//  YDRSSViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/27.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDRSSViewController.h"
#import "MWFeedParser.h"
#import "YDCoreDataStackManager.h"
#import "YDFeedItemTableViewCell.h"
#import "YDUtil.h"
#import "YDRSSDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface YDRSSViewController ()

@property (nonatomic, strong) MWFeedParser *feedParser;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableArray *parsedItems;
@property (nonatomic, strong) YDCoreDataStackManager *dataManager;

@end

@implementation YDRSSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.site.name;
    [self setupTableView];
    [self fetchSavedData];
    [self setupFeedParser];
}

- (void)setupTableView {
    self.tableView.estimatedRowHeight = 64;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)fetchSavedData {
    self.items = [self.dataManager feedItemsFromSiteName:self.site.name];
    [self.tableView reloadData];
}

- (void)refreshData {
    [self setupFeedParser];
}

- (void)setupFeedParser {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.refreshControl beginRefreshing];
    NSURL *feedURL = [NSURL URLWithString:self.site.url];
    self.feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL
                                            parsedItemBlock:^(MWFeedParser *feedParser, MWFeedInfo *feedInfo, MWFeedItem *feedItem) {
                                                if (feedInfo) {
                                                    self.title = feedInfo.title;
                                                }
                                                if (feedItem) {
                                                    if (![self.dataManager existFeedItem:feedItem]) {
                                                        [self.dataManager insertFeedItem:feedItem
                                                                                siteName:self.site.name
                                                                             siteKeyword:nil];
                                                    } else {
                                                        [self.feedParser stopParsing];
                                                    }
                                                }
                                            } finisedBlock:^{
                                                [self.dataManager saveContext];
                                                [self fetchSavedData];
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                [self.refreshControl endRefreshing];
                                                [self.feedParser clear]; // clear block memory issues
                                                
                                            } failureBlock:^(NSError *error) {
                                                NSLog(@"Failure");
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                [self.refreshControl endRefreshing];
                                            }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.hidesBarsOnSwipe = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.feedParser stopParsing];
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDFeedItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YDFeedItemCellIdentifier forIndexPath:indexPath];
    YDFeedItem *item = self.items[indexPath.row];
    cell.pubDateLabel.text = [[YDUtil sharedUtil] formatedDateStringFromDate:item.pubDate];
    cell.titleLabel.text = item.title;
    cell.authorLabel.text = item.author;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.site.galleryMode.boolValue) {
        [YDRSSDetailViewController navigationController:self.navigationController pushGalleryWithItem:[self.items objectAtIndex:indexPath.row] prefetch:YES];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return self.site.galleryMode.boolValue ? NO : YES;// 如果是看图模式，不显示条目详情页面，直接进入单张图片展示图库页面
}

- (YDCoreDataStackManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [YDCoreDataStackManager sharedManager];
    }
    return _dataManager;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:YDShowItemDetailSegueIdentifier]) {
        YDRSSDetailViewController *itemVC = segue.destinationViewController;
        itemVC.item = [self.items objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
}

@end
