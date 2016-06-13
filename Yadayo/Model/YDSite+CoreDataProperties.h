//
//  YDSite+CoreDataProperties.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/29.
//  Copyright © 2016年 yaqinking. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YDSite.h"

NS_ASSUME_NONNULL_BEGIN

@interface YDSite (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *postURL;
@property (nullable, nonatomic, retain) NSString *searchURL;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSNumber *uncategoried;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) YDCategory *category;
@property (nullable, nonatomic, retain) NSSet<YDKeyword *> *keywords;
@property (nullable, nonatomic, retain) NSSet<YDTag *> *tags;

@end

@interface YDSite (CoreDataGeneratedAccessors)

- (void)addKeywordsObject:(YDKeyword *)value;
- (void)removeKeywordsObject:(YDKeyword *)value;
- (void)addKeywords:(NSSet<YDKeyword *> *)values;
- (void)removeKeywords:(NSSet<YDKeyword *> *)values;

- (void)addTagsObject:(YDTag *)value;
- (void)removeTagsObject:(YDTag *)value;
- (void)addTags:(NSSet<YDTag *> *)values;
- (void)removeTags:(NSSet<YDTag *> *)values;

@end

NS_ASSUME_NONNULL_END
