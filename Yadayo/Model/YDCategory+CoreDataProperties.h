//
//  YDCategory+CoreDataProperties.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YDCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface YDCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cat_id;
@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<YDSite *> *sites;

@end

@interface YDCategory (CoreDataGeneratedAccessors)

- (void)addSitesObject:(YDSite *)value;
- (void)removeSitesObject:(YDSite *)value;
- (void)addSites:(NSSet<YDSite *> *)values;
- (void)removeSites:(NSSet<YDSite *> *)values;

@end

NS_ASSUME_NONNULL_END
