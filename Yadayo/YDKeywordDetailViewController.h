//
//  YDKeywordDetailViewController.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/29.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YDKeyword;
@class YDSite;

@interface YDKeywordDetailViewController : UITableViewController

@property (nonatomic, strong) YDKeyword *keyword;
@property (nonatomic, strong) YDSite *site;

@end
