//
//  YDPhotoCollectionViewCell.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDPhotoCollectionViewCell.h"

@implementation YDPhotoCollectionViewCell

- (void)prepareForReuse {
    self.imageView.image = nil;
    [super prepareForReuse];
}

@end
