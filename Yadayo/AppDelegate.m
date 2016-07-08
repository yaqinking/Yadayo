//
//  AppDelegate.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "AppDelegate.h"
#import "YDCoreDataStackManager.h"
#import "MWFeedParser.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@property (nonatomic, strong) YDCoreDataStackManager *dataManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [self registeLocalNotification];
    if (application.applicationState != UIApplicationStateBackground) {
        [self configureSettings];
    }
    [self congigureParse];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.dataManager saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.dataManager saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self.dataManager saveContext];
}

- (void)fetchNewFeedItemFrom:(NSString *)siteName completionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate new];
    NSDateComponents *compoments = [calendar components:NSCalendarUnitWeekday fromDate:now];
    NSInteger keywordWeekday = [self keywordWeekdayFromCompoments:compoments];
    NSArray<YDKeyword *> *todayKeywords = [self.dataManager keywordsFromSiteName:siteName weekdayUnit:[NSNumber numberWithInteger:keywordWeekday]];
    __block BOOL isHaveNewData = NO;
    if (todayKeywords.count == 0) {
        completionHandler(UIBackgroundFetchResultFailed);
    }
    [todayKeywords enumerateObjectsUsingBlock:^(YDKeyword * _Nonnull keyword, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *feedURLString = [[NSString stringWithFormat:keyword.site.searchURL, keyword.name] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *feedURL = [NSURL URLWithString:feedURLString];
        __unused MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL
                                                                  parsedItemBlock:^(MWFeedParser *feedParser, MWFeedInfo *feedInfo, MWFeedItem *feedItem) {
                                                                      if (![self.dataManager existFeedItem:feedItem]) {
                                                                          [self.dataManager insertFeedItem:feedItem siteName:siteName siteKeyword:[NSString stringWithFormat:@"%@ %@",siteName,keyword.name]];
                                                                          UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                                                                          localNotification.alertBody = feedItem.title;
                                                                          [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                                                                          isHaveNewData = YES;
                                                                      }
                                                                  } finisedBlock:^{
                                                                      if (idx == (todayKeywords.count-1)) {
                                                                          if (isHaveNewData) {
                                                                              [self.dataManager saveContext];
                                                                              completionHandler(UIBackgroundFetchResultNewData);
                                                                          } else {
                                                                              completionHandler(UIBackgroundFetchResultNoData);
                                                                          }
                                                                      }
                                                                  } failureBlock:^(NSError *error) {
                                                                      if (idx == (todayKeywords.count-1)) {
                                                                          if (!isHaveNewData) {
                                                                              completionHandler(UIBackgroundFetchResultFailed);
                                                                          }
                                                                      }
                                                                  }];
    }];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSString *siteName = [[NSUserDefaults standardUserDefaults] stringForKey:kReminderSiteName];
    if (siteName) {
        [self fetchNewFeedItemFrom:siteName completionHandler:completionHandler];
    } else {
        completionHandler(UIBackgroundFetchResultFailed);
    }
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

- (void)configureSettings {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults registerDefaults:@{ kPreloadNextPage : @YES,
                                      kSwitchSite : @NO,
                                      kOfflineMode : @NO}];
    NSInteger fetchAmount = [userDefaults integerForKey:kFetchAmount];
    if ((fetchAmount == 0 && iPadProPortrait) || (fetchAmount == 0 && iPadProLandscape)) {
        //        NSLog(@"iPad Pro");
        [userDefaults setInteger:kFetchAmountiPadProMin forKey:kFetchAmount];
    } else if (fetchAmount == 0 && iPad) {
        //        NSLog(@"iPad Retina");
        //iPad need load more pictures in order to get pull up to load more pictures.
        [userDefaults setInteger:kFetchAmountDefault forKey:kFetchAmount];
    } else if (fetchAmount == 0 && iPhone) {
        [userDefaults setInteger:kFetchAmountMin forKey:kFetchAmount];
    }
    
    NSInteger thumbLoadWay = [userDefaults integerForKey:kThumbLoadWay];
    NSInteger downloadImageType = [userDefaults integerForKey:kDownloadImageType];
    if (thumbLoadWay == KonachanPreviewImageLoadTypeUnseted) {
        [userDefaults setInteger:KonachanPreviewImageLoadTypeLoadPreview forKey:kThumbLoadWay];
    }
    if (downloadImageType == KonachanImageDownloadTypeUnseted) {
        [userDefaults setInteger:KonachanImageDownloadTypeSample forKey:kDownloadImageType];
    }
    [userDefaults synchronize];
    
}

- (void)congigureParse {
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration) {
        configuration.applicationId = YDParseAppId;
        configuration.server = YDParseServer;
    }]];
}


#pragma mark - Notification

- (void) registeLocalNotification {
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    NSLog(@"Token %@", token);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Success upload device token to parse server %@", [currentInstallation deviceToken]);
        } else {
            NSLog(@"Save device tokent error %@", [error localizedDescription]);
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registe remote notifications error %@", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSInteger contentAvailable = [[userInfo valueForKeyPath:@"aps.content-available"] integerValue];
    if (contentAvailable == 1) {
        NSString *siteName = [[NSUserDefaults standardUserDefaults] stringForKey:kReminderSiteName];
        if (siteName) {
            NSLog(@"Remote Notification Wake Fetch %@", siteName);
            [self fetchNewFeedItemFrom:siteName completionHandler:completionHandler];
        } else {
            completionHandler(UIBackgroundFetchResultFailed);
        }
    } else {
        NSLog(@"PFPush handle push %@", userInfo);
        [PFPush handlePush:userInfo];
    }
}

- (YDCoreDataStackManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [YDCoreDataStackManager sharedManager];
    }
    return _dataManager;
}

@end
