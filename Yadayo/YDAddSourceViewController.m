//
//  AddSourceViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDAddSourceViewController.h"
#import "AMTagListView.h"
#import "YDCoreDataStackManager.h"

@interface YDAddSourceViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet AMTagListView *categoryTagListView;
@property (strong, nonatomic) IBOutlet UITextField *categoryTextField;
@property (strong, nonatomic) IBOutlet UITextField *siteURLTextField;
@property (strong, nonatomic) IBOutlet UITextField *siteNameTextField;

@property (strong, nonatomic) NSArray *categories;

@end

@implementation YDAddSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.categoryTagListView addTags:self.categories];
    __weak YDAddSourceViewController *weakSelf = self;
    [self.categoryTagListView setTapHandler:^(AMTagView *tagView) {
        weakSelf.categoryTextField.text = tagView.tagText;
    }];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)add:(id)sender {
    NSString *urlString = self.siteURLTextField.text;
    NSString *siteName = self.siteNameTextField.text;
    NSString *categoryName = self.categoryTextField.text;
    YDCoreDataStackManager *dataManager = [YDCoreDataStackManager sharedManager];
    if (![dataManager existEntity:YDSiteEntityName forNameValue:siteName]) {
        YDCategory *category = [dataManager fetchedCategory:categoryName];
        [dataManager addSiteName:siteName
                             URL:urlString
                        category:category
                         success:^{
                             
                         } failure:^(NSError *error) {
                             
                         }];
        NSLog(@"Add Site %@",siteName);
    } else {
        NSLog(@"Exist Site %@", siteName);
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case 1:
            [self.siteNameTextField becomeFirstResponder];
            return NO;
            break;
        case 2:
            [self.categoryTextField becomeFirstResponder];
            return NO;
            break;
        case 3:
            [textField resignFirstResponder];
            if (![self isWhiteText:textField.text]) {
                YDCoreDataStackManager *dataManager = [YDCoreDataStackManager sharedManager];
                NSString *categoryName = textField.text;
                if (![dataManager existEntity:YDCategoryEntityName forNameValue:categoryName]) {
                    [dataManager addCategory:categoryName];
                    NSLog(@"Add Category %@",categoryName);
                    [self.categoryTagListView addTag:textField.text];
                }
            } else {
                NSLog(@"Exist or White %@",textField.text);
            }
            return YES;
            break;
        default:
            break;
    }
    return YES;
}

- (BOOL)isWhiteText:(NSString *)text {
    NSArray *texts = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *joinedtext = [texts componentsJoinedByString:@""];
    return joinedtext.length == 0 ? YES : NO;
}

- (NSArray *)categories {
    if (!_categories) {
        NSArray<YDCategory *> *savedCategories = [[YDCoreDataStackManager sharedManager] categories];
        NSMutableArray *categories = [NSMutableArray new];
        [savedCategories enumerateObjectsUsingBlock:^(YDCategory * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [categories addObject:obj.name];
        }];
        _categories = [categories copy];
    }
    return _categories;
}

@end
