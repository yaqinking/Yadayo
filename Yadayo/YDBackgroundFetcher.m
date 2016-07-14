//
//  YDBackgroundFetcher.m
//  Yadayo
//
//  Created by 小笠原やきん on 7/9/16.
//  Copyright © 2016 yaqinking. All rights reserved.
//

#import "YDBackgroundFetcher.h"
#import "YDCoreDataStackManager.h"
#import "MWFeedParser.h"


@interface YDBackgroundFetcher()

@property (nonatomic, strong) YDCoreDataStackManager *dataManager;

@end

@implementation YDBackgroundFetcher


+ (YDBackgroundFetcher *)sharedFetcher {
    static YDBackgroundFetcher *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [YDBackgroundFetcher new];
    });
    return sharedInstance;
}

- (void)backgroundFetchDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSArray *notificationSites = [[YDCoreDataStackManager sharedManager] notificationSites];
    if (notificationSites.count > 0) {
        [self fetchNewFeedItemFromSites:notificationSites completionHandler:completionHandler];
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
}

- (void)fetchNewFeedItemFromSites:(NSArray<YDSite *> *)sites completionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    __block NSUInteger finisedURLCount = 0;
    __block NSUInteger totalURLCount = 0;
    __block BOOL haveNewData = NO;
    [sites enumerateObjectsUsingBlock:^(YDSite * _Nonnull site, NSUInteger idx, BOOL * _Nonnull stop) {
        if (site.type.integerValue == YDSiteTypeBtSite) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *now = [NSDate new];
            NSDateComponents *compoments = [calendar components:NSCalendarUnitWeekday fromDate:now];
            NSInteger keywordWeekday = [self keywordWeekdayFromCompoments:compoments];
            NSArray<YDKeyword *> *todayKeywords = [self.dataManager keywordsFromSiteName:site.name weekdayUnit:[NSNumber numberWithInteger:keywordWeekday]];
            if (todayKeywords.count == 0) {
                finisedURLCount ++;
                return;
            }
            [todayKeywords enumerateObjectsUsingBlock:^(YDKeyword * _Nonnull keyword, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *feedURLString = [[NSString stringWithFormat:keyword.site.searchURL, keyword.name] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSURL *feedURL = [NSURL URLWithString:feedURLString];
                totalURLCount++;
                __unused MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL
                                                                          parsedItemBlock:^(MWFeedParser *feedParser, MWFeedInfo *feedInfo, MWFeedItem *feedItem) {
                                                                              if (![self.dataManager existFeedItem:feedItem]) {
                                                                                  haveNewData = YES;
                                                                                  [self.dataManager insertFeedItem:feedItem siteName:site.name siteKeyword:[NSString stringWithFormat:@"%@ %@",site.name,keyword.name]];
//                                                                                  NSLog(@"New Torrent Item %@", feedItem.title);
                                                                                  UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                                                                  localNotification.alertBody = feedItem.title;
                                                                                  [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                                                                              } else {
                                                                                  [feedParser stopParsing];
                                                                              }
                                                                          } finisedBlock:^{
                                                                              finisedURLCount ++;
                                                                              if (finisedURLCount == totalURLCount) {
//                                                                                  NSLog(@"All sites fetched BT");
                                                                                  if (haveNewData) {
                                                                                      [self.dataManager saveContext];
                                                                                      completionHandler(UIBackgroundFetchResultNewData);
                                                                                  } else {
                                                                                      completionHandler(UIBackgroundFetchResultNoData);
                                                                                  }
                                                                              }
                                                                          } failureBlock:^(NSError *error) {
                                                                              
                                                                          }];
            }];
        } else {
            NSURL *feedURL = [NSURL URLWithString:site.url];
            totalURLCount++;
            __unused MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL
                                                                      parsedItemBlock:^(MWFeedParser *feedParser, MWFeedInfo *feedInfo, MWFeedItem *feedItem) {
                                                                          if (![self.dataManager existFeedItem:feedItem]) {
                                                                              haveNewData = YES;
                                                                              [self.dataManager insertFeedItem:feedItem siteName:site.name siteKeyword:nil];
                                                                              UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                                                              localNotification.alertBody = feedItem.title;
                                                                              [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                                                                          } else {
                                                                              [feedParser stopParsing];
                                                                          }
                                                                      } finisedBlock:^{
                                                                          finisedURLCount++;
                                                                          if (finisedURLCount == totalURLCount) {
//                                                                              NSLog(@"All sites fetched Normal RSS");
                                                                              if (haveNewData) {
                                                                                  [self.dataManager saveContext];
                                                                                  completionHandler(UIBackgroundFetchResultNewData);
                                                                              } else {
                                                                                  completionHandler(UIBackgroundFetchResultNoData);
                                                                              }
                                                                          }
                                                                      } failureBlock:^(NSError *error) {
                                                                      }];
        }
    }];
}

- (NSInteger )keywordWeekdayFromCompoments:(NSDateComponents *)compoments {
    NSInteger weekdayNow = [compoments weekday];
    switch (weekdayNow) {
        case 1: return 7;
        case 2: return 1;
        case 3: return 2;
        case 4: return 3;
        case 5: return 4;
        case 6: return 5;
        case 7: return 6;
        default:
            break;
    }
    return 0;
}

- (YDCoreDataStackManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [YDCoreDataStackManager sharedManager];
    }
    return _dataManager;
}

@end
