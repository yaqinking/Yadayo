//
//  YDTag+CoreDataProperties.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YDTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface YDTag (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createDate;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) YDSite *site;

@end

NS_ASSUME_NONNULL_END
