//
//  YDPhotosViewController.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@class YDSite;
@class YDTag;

@interface YDPhotosViewController : UICollectionViewController<MWPhotoBrowserDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) YDTag *tag;
@property (nonatomic, strong) YDSite *site;

@end
