//
//  YDTagTableViewCell.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDTagTableViewCell.h"

@implementation YDTagTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self nightCell];
}

- (void)nightCell {
     CGFloat red = 33.0;
     CGFloat green = 33.0;
     CGFloat blue = 33.0;
     CGFloat alpha = 255.0;
     UIColor *color = [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:(alpha/255.0)];
     self.backgroundColor = color;
     self.textLabel.textColor = [UIColor whiteColor];
}

@end
