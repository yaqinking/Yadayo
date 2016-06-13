//
//  LocalImageDataSource.h
//  Konachan
//
//  Created by 小笠原やきん on 16/5/13.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YDImage;
@class YDTag;

@interface YDLocalImageDataSource : NSObject

- (NSDictionary *)imageDataDictionaryWithTag:(NSString *)tag;
- (void)insertImagesFromResonseObject:(id)responseObject;
- (void)clearImages;
- (NSArray<YDImage *> *)imagesWithTag:(NSString *)tag;

@end
