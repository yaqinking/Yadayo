//
//  YDCoreDataStackManager.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YDCategory.h"
#import "YDSite.h"
#import "YDTag.h"
#import "YDImage.h"
#import "YDConstants.h"
#import "YDKeyword.h"
#import "YDFeedItem.h"

#import "MWFeedItem.h"

typedef void(^YDAddSiteSuccessBlock)();
typedef void(^YDAddSiteFailureBlock)(NSError *error);

@import CoreData;

@interface YDCoreDataStackManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSPersistentStore *cachePersistentStore;

+ (instancetype)sharedManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)addCategory:(NSString *)name;
- (YDCategory *)fetchedCategory:(NSString *)name;
- (NSArray<YDCategory *> *)categories;

- (void)addSiteName:(NSString *)name
                URL:(NSString *)url
           category:(YDCategory *)category
            success:(YDAddSiteSuccessBlock)successHanlder
            failure:(YDAddSiteFailureBlock)failureHandler;

- (NSArray<YDSite *> *)uncategoriedSites;

- (NSArray<YDTag *> *)tags;

- (NSArray<YDImage *> *)cachedImages;
- (NSArray<YDImage *> *)cachedImagesUsingPredicate:(NSPredicate *)predicate;

- (void)addKeyword:(NSString *)keyword
   withWeekdayUnit:(NSNumber *)weekday
            toSite:(YDSite *)site;

- (BOOL)existEntity:(NSString *)entityName forNameValue:(NSString *)nameValue;
- (BOOL)existKeywordNameValue:(NSString *)keywordName forSite:(YDSite *)site;
- (BOOL)existFeedItem:(MWFeedItem *)feedItem;

- (void)insertFeedItem:(MWFeedItem *)feedItem
              siteName:(NSString *)site_name
           siteKeyword:(NSString *) site_keyword;

// For bt site
- (NSArray<YDFeedItem *> *)feedItemsFrom:(NSString *)siteKeyword;
- (NSArray<YDKeyword *> *)keywordsFromSiteName:(NSString *)siteName
                                   weekdayUnit:(NSNumber *)weekdayUnit;

// For normal rss site
- (NSArray<YDFeedItem *> *)feedItemsFromSiteName:(NSString *)siteName;

/*
- (NSArray *)fetchedResultsForEntityForName:(NSString *)entityName
                             usingPredicate:(NSPredicate *)predicate
                            sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors;
*/

// BT Sites

- (NSArray<YDSite *> *)savedBTSites;

@end
