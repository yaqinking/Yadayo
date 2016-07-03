//
//  YDRSSDetailViewController.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/6/4.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YDFeedItem;
@class YDSite;

@interface YDRSSDetailViewController : UIViewController

@property (nonatomic, strong) YDFeedItem *item;

+ (void)navigationController:(UINavigationController *)navCon pushGalleryWithItem:(YDFeedItem *)item prefetch:(BOOL )prefetch;

@end
