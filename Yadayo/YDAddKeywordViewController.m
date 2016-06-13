//
//  YDAddKeywordViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/29.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDAddKeywordViewController.h"
#import "YDCoreDataStackManager.h"

@interface YDAddKeywordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *keywordTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weekdayControl;

@end

@implementation YDAddKeywordViewController

- (IBAction)addKeyword:(id)sender {
    NSString *keyword = self.keywordTextField.text;
    NSInteger weekday = self.weekdayControl.selectedSegmentIndex;
    YDCoreDataStackManager *dataManager = [YDCoreDataStackManager sharedManager];
    if (![dataManager existKeywordNameValue:keyword forSite:self.site]) {
        [dataManager addKeyword:keyword withWeekdayUnit:[NSNumber numberWithInteger:weekday] toSite:self.site];
        NSLog(@"Add Keyword %@",keyword);
    } else {
        NSLog(@"Exist Keyword %@",keyword);
    }
}

@end
