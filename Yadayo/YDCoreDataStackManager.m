//
//  YDCoreDataStackManager.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDCoreDataStackManager.h"

NSString *const ErrorDomain = @"yaqinking.moe";
NSString *const ContentNameKey = @"moe~yaqinking~yadayo";
NSString *const ApplicationDocumentsDirectoryName = @"yadayo.sqlite";
NSString *const ApplicationCacheDirectoryName = @"yadayo-cache.sqlite";

@implementation YDCoreDataStackManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedManager {
    static YDCoreDataStackManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "moe.yaqinking.Yadayo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Yadayo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // iCloud Sync Persistent Store
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:ApplicationDocumentsDirectoryName];
    NSDictionary *storeOptions = @{NSPersistentStoreUbiquitousContentNameKey: ContentNameKey,
                                   NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSInferMappingModelAutomaticallyOption: @YES};
    NSError *error = nil;
    NSPersistentStore *store = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (!(store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:storeOptions error:&error])) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:ErrorDomain code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // Cache Persistent Store
    NSURL *cacheStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:ApplicationCacheDirectoryName];
    NSDictionary *cacheStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                        NSInferMappingModelAutomaticallyOption: @YES};
    NSPersistentStore *cacheStore = nil;
    NSError *cacheError = nil;
    if (! (cacheStore = [ _persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:@"Cache"
                                                                             URL:cacheStoreURL
                                                                         options:cacheStoreOptions
                                                                           error:&cacheError])) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's cached data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:ErrorDomain code:9235 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved cache error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSURL *finaliCloudURL = [store URL];
    NSLog(@"finaliCloudURL: %@", finaliCloudURL);
    NSURL *finalCacheStoreURL = [cacheStore URL];
    NSLog(@"Cache Store URL %@", finalCacheStoreURL);

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (NSPersistentStore *)cachePersistentStore {
    return [_persistentStoreCoordinator.persistentStores lastObject];
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Helper

- (void)addCategory:(NSString *)name {
    if (name.length) {
        
        YDCategory *category = [NSEntityDescription insertNewObjectForEntityForName:YDCategoryEntityName
                                                             inManagedObjectContext:_managedObjectContext];
        category.name = name;
        category.createDate = [NSDate new];
        [self saveContext];
    }
}


- (BOOL)existEntity:(NSString *)entityName forNameValue:(NSString *)nameValue {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", nameValue];
    NSError *error = nil;
    NSInteger existCount = [self.managedObjectContext countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Count for existEntity:ForNameValue: error %@", [error localizedDescription]);
    }
    return existCount ? YES : NO;
}

- (BOOL)existKeywordNameValue:(NSString *)keywordName forSite:(YDSite *)site {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDKeywordEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@ && site == %@", keywordName, site];
    NSError *error = nil;
    NSInteger existCount = [self.managedObjectContext countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Count for existKeywordNameValue:inSite: error %@", [error localizedDescription]);
    }
    return existCount ? YES : NO;
}

- (YDCategory *)fetchedCategory:(NSString *)name {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDCategoryEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    return [[self.managedObjectContext executeFetchRequest:request error:NULL] firstObject];
}

- (NSArray *)categories {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDCategoryEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES]];
    return [self.managedObjectContext executeFetchRequest:request error:NULL];
}

- (void)addSiteName:(NSString *)name URL:(NSString *)url category:(YDCategory *)category success:(YDAddSiteSuccessBlock)successHanlder failure:(YDAddSiteFailureBlock)failureHandler {
    YDSite *site = [NSEntityDescription insertNewObjectForEntityForName:YDSiteEntityName
                                                 inManagedObjectContext:_managedObjectContext];
    site.name = name;
    site.url = url;
    site.createDate = [NSDate new];
    if (category) {
        site.category = category;
        site.uncategoried = @NO;
    }
    [[self danbooruSites] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([name isEqualToString:obj]) {
            site.type = @1; // Danbooru Site
            *stop = YES;
        }
    }];
    [[self btSites] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([name isEqualToString:obj]) {
            site.type = @2; // BT download site
            *stop = YES;
        }
    }];
    [[self imgSites] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([name isEqualToString:obj]) {
            site.type = @3; // RSS site but need extract summary img url then give a gallery mode like danbooru site
            *stop = YES;
        }
    }];
    if ([name isEqualToString:@"konachan.net"]) {
        site.searchURL = KONACHAN_SAFE_MODE_POST_LIMIT_PAGE_TAGS;
    } else if ([name isEqualToString:@"konachan.com"]) {
        site.searchURL = KONACHAN_POST_LIMIT_PAGE_TAGS;
    } else if ([name isEqualToString:@"yande.re"]) {
        site.searchURL = YANDERE_POST_LIMIT_PAGE_TAGS;
    } else if ([name isEqualToString:@"dmhy"]) {
        site.searchURL = DMHYSearchByKeyword;
        site.url = DMHYRSS;
    } else if ([name isEqualToString:@"kisssub"]) {
        site.searchURL = DMHYKissSubSearchByKeyword;
        site.url = DMHYKissSubRSS;
    } else if ([name isEqualToString:@"acg.rip"]) {
        site.searchURL = DMHYACGRIPSearchByKeyword;
        site.url = DMHYACGRIPRSS;
    } else if ([name isEqualToString:@"acg.gg"]) {
        site.searchURL = DMHYACGGGSearchByKeyword;
        site.url = DMHYACGGGRSS;
    } else if ([name isEqualToString:@"moeimg.net"]) {
        site.url = @"http://moeimg.net/feed";
    }
    [self saveContext];
    NSLog(@"New Site %@ Cat %@", site, category);
}

- (void)addSite:(NSString *)urlString category:(YDCategory *)category success:(YDAddSiteSuccessBlock)successHanlder failure:(YDAddSiteFailureBlock)failureHandler {
    
    
}

- (void)addKeyword:(NSString *)keyword withWeekdayUnit:(NSNumber *)weekday toSite:(YDSite *)site {
    YDKeyword *keywordEntity = [NSEntityDescription insertNewObjectForEntityForName:YDKeywordEntityName inManagedObjectContext:_managedObjectContext];
    keywordEntity.name = keyword;
    keywordEntity.site = site;
    
    // For background fetch use predicate fliter
    keywordEntity.siteName = site.name;
    keywordEntity.weekday = weekday;
    
    [self saveContext];
}

- (NSArray<YDSite *> *)uncategoriedSites {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDSiteEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"uncategoried == %@",@YES];
    return [self.managedObjectContext executeFetchRequest:request error:NULL];
}

- (NSArray<YDTag *> *)tags {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDTagEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES]];
    return [self.managedObjectContext executeFetchRequest:request error:NULL];
}

- (NSArray<YDImage *> *)cachedImages {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDImageEntityName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"image_id" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray<YDImage *> *)cachedImagesUsingPredicate:(NSPredicate *)predicate {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDImageEntityName];
    request.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"image_id" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray<NSString *> *)danbooruSites {
    return @[@"konachan.com",
             @"konachan.net",
             @"yande.re"];
}

- (NSArray<NSString *> *)btSites {
    return @[@"dmhy",
             @"kisssub",
             @"acg.rip",
             @"acg.gg"];
}

- (NSArray<NSString *> *)imgSites {
    return @[@"moeimg.net"];
}

#pragma mark - FeedItem

- (BOOL)existFeedItem:(MWFeedItem *)feedItem {
//    NSString *identifier = feedItem.identifier;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDFeedItemEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", feedItem.identifier];
    NSError *error = nil;
    NSInteger existCount = [self.managedObjectContext countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Count for exist feeditem error %@", [error localizedDescription]);
    }
    return existCount ? YES : NO;
}

- (void)insertFeedItem:(MWFeedItem *)feedItem siteName:(NSString *)site_name siteKeyword:(NSString *)site_keyword {
    YDFeedItem *item = [NSEntityDescription insertNewObjectForEntityForName:YDFeedItemEntityName inManagedObjectContext:_managedObjectContext];
    item.identifier = feedItem.identifier;
    item.pubDate = feedItem.date;
    item.title = feedItem.title;
    item.author = feedItem.author ? feedItem.author : @"";
    item.link = feedItem.link;
    item.enclosure = [[feedItem.enclosures lastObject] valueForKey:@"url"];
    item.summary = feedItem.summary;
    item.content = feedItem.content ? feedItem.content : @"";
    item.site = site_name;
    item.site_keyword = site_keyword;
    [self.managedObjectContext assignObject:item toPersistentStore:self.cachePersistentStore];
}

- (NSArray<YDFeedItem *> *)feedItemsFrom:(NSString *)siteKeyword {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDFeedItemEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"site_keyword == %@", siteKeyword];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kPubDate ascending:NO]];
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Fetch feeditems from siteKeyword error %@", [error localizedDescription]);
    }
    return results;
}

- (NSArray<YDFeedItem *> *)feedItemsFromSiteName:(NSString *)siteName {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDFeedItemEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"site == %@", siteName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kPubDate ascending:NO]];
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Fetch feeditems from siteName error %@", [error localizedDescription]);
    }
    return results;
}

#pragma mark - Keywords (Background fetch check new items)

- (NSArray<YDKeyword *> *)keywordsFromSiteName:(NSString *)siteName weekdayUnit:(NSNumber *)weekdayUnit {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDKeywordEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"weekday == %@ && siteName == %@",weekdayUnit, siteName];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Background fetch keywords error %@", [error localizedDescription]);
    }
    return results;
}

#pragma mark - BT Sites

- (NSArray<YDSite *> *)savedBTSites {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDSiteEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"type == %@", @2];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kCreateDate ascending:YES]];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

- (YDSite *)siteForName:(NSString *)name {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDSiteEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    return [[self.managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

#pragma mark - All Sites

- (NSArray<YDSite *> *)allSites {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDSiteEntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:kCreateDate ascending:YES]];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

#pragma mark - Notification sites

- (NSArray<YDSite *> *)notificationSites {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDSiteEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"notification == %@", @YES];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

@end
