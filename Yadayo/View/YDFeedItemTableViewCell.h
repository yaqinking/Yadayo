//
//  YDFeedItemTableViewCell.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/6/2.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YDFeedItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@end
