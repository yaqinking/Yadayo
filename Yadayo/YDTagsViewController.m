//
//  YDTagsViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDTagsViewController.h"
#import "YDCoreDataStackManager.h"
#import "YDPhotosViewController.h"
#import "YDTagTableViewCell.h"

@interface YDTagsViewController ()

@property (nonatomic, strong) UIAlertController *addTagAlertController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation YDTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.site.name;
    if (self.isTagListMode) {
        [self setupTagListModeNavgationItems];
    } else {
        [self setupGeneralNavagationItems];
    }
    NSLog(@"viewDidLoad %i",self.site.tags.count);
//    [self setupTableView];
}

- (void)setupTagListModeNavgationItems {
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
}

- (void)setupGeneralNavagationItems {
    UIBarButtonItem *addTagItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addTag)];
    self.navigationItem.rightBarButtonItem = addTagItem;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addSelectTags)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)addSelectTags {
    NSLog(@"Add Select tags");
    __block YDSite *site = [[YDCoreDataStackManager sharedManager] siteForName:self.site.name];
    NSArray<NSIndexPath *> *selectIndexPaths = self.tableView.indexPathsForSelectedRows;
    [selectIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        YDTag *selectTag = [self tagForRowAtIndexPath:indexPath];
        YDTag *newTag = [NSEntityDescription insertNewObjectForEntityForName:YDTagEntityName inManagedObjectContext:self.managedObjectContext];
        newTag.name = selectTag.name;
        newTag.createDate = [NSDate new];
        newTag.site = site;
    }];
    [[YDCoreDataStackManager sharedManager] saveContext];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setHidesBarsOnSwipe:NO];
    NSLog(@"viewDidAppear %i",self.site.tags.count);
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    CGFloat red = 33.0;
    CGFloat green = 33.0;
    CGFloat blue = 33.0;
    CGFloat alpha = 255.0;
    UIColor *color = [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:(alpha/255.0)];
    
    self.tableView.backgroundColor = color;
    self.tableView.separatorColor  = color;
}

- (void)addTag {
    [self presentViewController:self.addTagAlertController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection %i", self.site.tags.count);
    return self.site.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YDTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YDTagCellIdentifier forIndexPath:indexPath];
    YDTag *tag = [self tagForRowAtIndexPath:indexPath];
    cell.textLabel.text = tag.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        return;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navCon = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YDTagDetailNav"];
    YDTag *tag = [self tagForRowAtIndexPath:indexPath];
    YDPhotosViewController *photosVC = navCon.childViewControllers[0];
    photosVC.tag = tag;
    photosVC.site = self.site;
    if (iPad) {
        if (self.isTagListMode) {
            photosVC.tagListMode = YES;
            [self.navigationController pushViewController:photosVC animated:YES];
        } else {
//            [self.splitViewController presentViewController:navCon animated:YES completion:nil];
            [self.navigationController pushViewController:photosVC animated:YES];
        }
    } else if (iPhone) {
        [self.navigationController pushViewController:photosVC animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%i", editingStyle);
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSLog(@"Insert");
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Delete");
    }
}

- (YDTag *)tagForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:YES];
    return [[self.site.tags sortedArrayUsingDescriptors:@[sortDescriptor]] objectAtIndex:indexPath.row];
}

- (UIAlertController *)addTagAlertController {
    if (!_addTagAlertController) {
        __weak YDTagsViewController *weakSelf = self;
        _addTagAlertController = [UIAlertController alertControllerWithTitle:@"Add Tag"
                                                                     message:@""
                                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              UITextField *tagTextField =  _addTagAlertController.textFields[0];
                                                              NSString *addTagName = tagTextField.text;
                                                              NSArray *tagsArray = [addTagName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                              NSString *tagName = [tagsArray componentsJoinedByString:@""];
                                                              if (![tagName isEqualToString:@""]) {
                                                                  YDTag *newTag = [NSEntityDescription insertNewObjectForEntityForName:YDTagEntityName
                                                                                                              inManagedObjectContext:self.managedObjectContext];
                                                                  newTag.name = tagName;
                                                                  newTag.createDate = [NSDate new];
                                                                  newTag.site = self.site;
                                                                  [self.tableView reloadData];
                                                              }
                                                              tagTextField.text = nil;
                                                          }];
        
        addAction.enabled = NO;
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 _addTagAlertController.textFields[0].text = nil;
                                                             }];
        
        [_addTagAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"Input a tag keyword";
            NSNotificationCenter *notiCen = [NSNotificationCenter defaultCenter];
            [notiCen addObserverForName:UITextFieldTextDidChangeNotification
                                 object:textField
                                  queue:[NSOperationQueue mainQueue]
                             usingBlock:^(NSNotification * _Nonnull note) {
                                 if ([weakSelf isWhiteText:textField.text]) {
                                     addAction.enabled = NO;
                                 } else {
                                     addAction.enabled = YES;
                                 }
                             }];
            [notiCen addObserverForName:UITextFieldTextDidEndEditingNotification
                                 object:textField
                                  queue:[NSOperationQueue mainQueue]
                             usingBlock:^(NSNotification * _Nonnull note) {
                                 addAction.enabled = NO;
                             }];
        }];
        [_addTagAlertController addAction:addAction];
        [_addTagAlertController addAction:cancelAction];
    }
    return _addTagAlertController;
}

- (BOOL)isWhiteText:(NSString *)text {
    NSArray *texts = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *joinedtext = [texts componentsJoinedByString:@""];
    return joinedtext.length == 0 ? YES : NO;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[YDCoreDataStackManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

@end
