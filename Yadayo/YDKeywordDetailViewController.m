//
//  YDKeywordDetailViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/29.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDKeywordDetailViewController.h"
#import "YDTorrentTableViewCell.h"
#import "YDCoreDataStackManager.h"
#import "MWFeedParser.h"
#import "YDUtil.h"

@interface YDKeywordDetailViewController ()

@property (nonatomic, strong) MWFeedParser *feedParser;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) YDCoreDataStackManager *dataManager;

// For different persistent store fetch predicate
@property (nonatomic, strong) NSString *siteName;
@property (nonatomic, strong) NSString *siteKeyword;

@end

@implementation YDKeywordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self setupParsingData];
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

- (void)setupParsingData {
    self.siteName = self.site.name;
    self.siteKeyword = [NSString stringWithFormat:@"%@ %@", self.site.name, self.keyword.name];
}

- (void)fetchSavedData {
    self.items = [self.dataManager feedItemsFrom:self.siteKeyword];
    [self.tableView reloadData];
}

- (void)setupFeedParser {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.refreshControl beginRefreshing];
    NSString *feedURLString = [[NSString stringWithFormat:self.site.searchURL, self.keyword.name] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *feedURL = [NSURL URLWithString:feedURLString];
    self.feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL
                                            parsedItemBlock:^(MWFeedParser *feedParser, MWFeedInfo *feedInfo, MWFeedItem *feedItem) {
                                                if (feedItem) {
                                                    if (![self.dataManager existFeedItem:feedItem]) {
                                                        if (IS_DEBUG_MODE) {
                                                            NSLog(@"Insert %@",feedItem.title);
                                                        }
                                                        [self.dataManager insertFeedItem:feedItem
                                                                                siteName:self.siteName
                                                                             siteKeyword:self.siteKeyword];
                                                    }
                                                }
                                                
                                            } finisedBlock:^{
                                                [self.dataManager saveContext];
                                                [self fetchSavedData];
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                [self.refreshControl endRefreshing];
                                            } failureBlock:^(NSError *error) {
                                                NSLog(@"Failure");
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                [self.refreshControl endRefreshing];
                                            }];
}

- (void)refreshData {
    [self setupFeedParser];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDTorrentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YDTorrentCellIdentifier forIndexPath:indexPath];
    YDFeedItem *item = self.items[indexPath.row];
    cell.pubDateLabel.text = [[YDUtil sharedUtil] formatedDateStringFromDate:item.pubDate];
    cell.titleLabel.text = item.title;
    return cell;
}

- (YDCoreDataStackManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [YDCoreDataStackManager sharedManager];
    }
    return _dataManager;
}

@end
