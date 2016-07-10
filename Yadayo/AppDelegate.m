//
//  AppDelegate.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "AppDelegate.h"
#import "YDCoreDataStackManager.h"
#import "YDBackgroundFetcher.h"
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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

#pragma mark - User Notifications

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
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
//            NSLog(@"Success upload device token to parse server %@", [currentInstallation deviceToken]);
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
        [[YDBackgroundFetcher sharedFetcher] backgroundFetchDataWithCompletionHandler:completionHandler];
    } else {
        [PFPush handlePush:userInfo];
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

#pragma mark - Background Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[YDBackgroundFetcher sharedFetcher] backgroundFetchDataWithCompletionHandler:completionHandler];
}

#pragma mark - Settigns

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

#pragma mark - Properties

- (YDCoreDataStackManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [YDCoreDataStackManager sharedManager];
    }
    return _dataManager;
}

@end
