//
//  YDImage+CoreDataProperties.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YDImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface YDImage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *create_at;
@property (nullable, nonatomic, retain) NSString *file_url;
@property (nullable, nonatomic, retain) NSNumber *image_id;
@property (nullable, nonatomic, retain) NSString *jpeg_url;
@property (nullable, nonatomic, retain) NSString *md5;
@property (nullable, nonatomic, retain) NSString *preview_url;
@property (nullable, nonatomic, retain) NSString *rating;
@property (nullable, nonatomic, retain) NSString *sample_url;
@property (nullable, nonatomic, retain) NSString *site;
@property (nullable, nonatomic, retain) NSString *tags;

@end

NS_ASSUME_NONNULL_END
