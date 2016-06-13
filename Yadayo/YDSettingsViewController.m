//
//  YDSettingsViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDSettingsViewController.h"
#import "YDConstants.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import "MBProgressHUD.h"
#import "YDLocalImageDataSource.h"

@interface YDSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *fetchAmountTextField;
@property (weak, nonatomic) IBOutlet UILabel *cachedSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadThumbWayTextField;
@property (weak, nonatomic) IBOutlet UILabel *downloadImageTypeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *preloadNextPageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *offlineModeSwitch;

@end

@implementation YDSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self calculateCachedPicsSize];
    [self configureFetchAmount];
    [self configurePreloadNextPage];
    [self congigureOfflineMode];
//    [self setupGestures];
}
/*
- (void)setupGestures {
    UITapGestureRecognizer *switchTapGesture = [[UITapGestureRecognizer alloc] init];
    switchTapGesture.numberOfTouchesRequired = 1;
    switchTapGesture.numberOfTapsRequired = 5;
    [switchTapGesture addTarget:self action:@selector(configureSwitchSite)];
    [self.tableView addGestureRecognizer:switchTapGesture];
    
    UISwipeGestureRecognizer *switchToYandereGesture = [[UISwipeGestureRecognizer alloc] init];
    switchToYandereGesture.direction = UISwipeGestureRecognizerDirectionRight;
    switchToYandereGesture.numberOfTouchesRequired = 3;
    [switchToYandereGesture addTarget:self action:@selector(responseToYandereGesture)];
    [self.tableView addGestureRecognizer:switchToYandereGesture];
    
    UISwipeGestureRecognizer *switchToKonachanComGesture = [[UISwipeGestureRecognizer alloc] init];
    switchToKonachanComGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    switchToKonachanComGesture.numberOfTouchesRequired = 3;
    [switchToKonachanComGesture addTarget:self action:@selector(responseToKonachanComGesture)];
    [self.tableView addGestureRecognizer:switchToKonachanComGesture];
    
    UISwipeGestureRecognizer *switchToKonachanNetGesture = [[UISwipeGestureRecognizer alloc] init];
    switchToKonachanNetGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    switchToKonachanNetGesture.numberOfTouchesRequired = 2;
    [switchToKonachanNetGesture addTarget:self action:@selector(responseToKonachanNetGesture)];
    [self.tableView addGestureRecognizer:switchToKonachanNetGesture];
}

- (BOOL)isSwitchSiteON {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSwitchSite];
}
*/

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    switch (indexPath.section) {
        case 0:
            switch (row) {
                case 0:
                    [self clearCache:self];
                    break;
                case 1:
                    break;
                case 2:
                    break;
                case 3:
                    [self changePreviewImageType];
                    break;
                case 4:
                    [self changeDownloadImageType];
                    break;
                case 5:
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)changePreviewImageType {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Change Preview Image Type"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction *loadPreviewImageAction = [UIAlertAction actionWithTitle:@"Load thumbs" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self writeConfigWith:KonachanPreviewImageLoadTypeLoadPreview andKey:kThumbLoadWay];
    }];
    UIAlertAction *loadDownloadImageAction = [UIAlertAction actionWithTitle:@"Predownload pictures" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self writeConfigWith:KonachanPreviewImageLoadTypeLoadDownloaded andKey:kThumbLoadWay];
    }];
    
    [alert addAction:loadPreviewImageAction];
    [alert addAction:loadDownloadImageAction];
    [alert addAction:defaultAction];
    
    [self popoverPresentWith:alert To:self.loadThumbWayTextField];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)popoverPresentWith:(UIAlertController *)alert To:(UILabel *) sender {
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = sender;
    popPresenter.sourceRect = sender.bounds;
}

- (void)changeDownloadImageType {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Change Download Image Type"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    UIAlertAction *loadSampleImageAction = [UIAlertAction actionWithTitle:@"Sample" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self writeConfigWith:KonachanImageDownloadTypeSample andKey:kDownloadImageType];
    }];
    UIAlertAction *loadJPEGImageAction = [UIAlertAction actionWithTitle:@"JPEG" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self writeConfigWith:KonachanImageDownloadTypeJPEG andKey:kDownloadImageType];
    }];
    UIAlertAction *loadFileImageAction = [UIAlertAction actionWithTitle:@"Original" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self writeConfigWith:KonachanImageDownloadTypeFile andKey:kDownloadImageType];
    }];
    [alert addAction:loadSampleImageAction];
    [alert addAction:loadJPEGImageAction];
    [alert addAction:loadFileImageAction];
    [alert addAction:defaultAction];
    
    [self popoverPresentWith:alert To:self.downloadImageTypeLabel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)calculateCachedPicsSize {
    __weak typeof(self) weakSelf = self;
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        weakSelf.cachedSizeLabel.text = [NSString stringWithFormat:@"%.2f M", totalSize/1024.0/1024.0];
    }];
    
}

- (void)configureFetchAmount {
    NSInteger fetchAmount = [[NSUserDefaults standardUserDefaults] integerForKey:kFetchAmount];
    self.fetchAmountTextField.text = [NSString stringWithFormat:@"%lu",fetchAmount];
    
}

- (void)configurePreloadNextPage {
    BOOL isPreloadNextPage = [[NSUserDefaults standardUserDefaults] boolForKey:kPreloadNextPage];
    self.preloadNextPageSwitch.on = isPreloadNextPage;
}

- (void)congigureOfflineMode {
    BOOL isOfflineMode = [[NSUserDefaults standardUserDefaults] boolForKey:kOfflineMode];
    self.offlineModeSwitch.on = isOfflineMode;
}

- (void)clearCache:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear cached image cache?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         SDImageCache *imageCache = [SDImageCache sharedImageCache];
                                                         
                                                         [imageCache clearMemory];
                                                         [imageCache clearDiskOnCompletion:^{
                                                             [self calculateCachedPicsSize];
                                                         }];
                                                         
                                                         YDLocalImageDataSource *dataSource = [[YDLocalImageDataSource alloc] init];
                                                         [dataSource clearImages];
                                                     }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)setFetchAmount:(id)sender {
    NSInteger fetchAmount = [self.fetchAmountTextField.text integerValue];
    
    if ((fetchAmount < kFetchAmountiPadProMin && iPadProPortrait) ||
        (fetchAmount < kFetchAmountiPadProMin && iPadProLandscape)) {
        [self showHUDWithTitle:@"Error >_<"
                       content:@"iPad Pro Min fetch amount is 56"];
        return;
    }
    if (fetchAmount < kFetchAmountDefault && iPad) {
        [self showHUDWithTitle:@"Error >_<"
                       content:@"iPad Min fetch amount is 40"];
        return;
    }
    if (fetchAmount < kFetchAmountMin && iPhone) {
        [self showHUDWithTitle:@"Error >_<"
                       content:@"Min fetch amount is 30"];
        return;
    }
    if (fetchAmount > 100) {
        [self showHUDWithTitle:@"Error >_<"
                       content:@"Max fetch amount is 100"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:fetchAmount forKey:kFetchAmount];
        [self showHUDWithTitle:@"Success!" content:[NSString stringWithFormat:@"Set fetch amount to %li success!",(long)fetchAmount]];
    }
}

- (IBAction)changePreloadNextPageImage:(UISwitch *)sender {
    if (sender.on) {
        [self writeConfigWith:1 andKey:kPreloadNextPage];
    } else {
        [self writeConfigWith:0 andKey:kPreloadNextPage];
    }
}

- (IBAction)changeOfflineMode:(UISwitch *)sender {
    if (sender.on) {
        [self writeConfigWith:1 andKey:kOfflineMode];
    } else {
        [self writeConfigWith:0 andKey:kOfflineMode];
    }
}

- (void) writeConfigWith:(NSInteger) value andKey:(NSString *)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:key];
    [defaults synchronize];
    if ([key isEqualToString:kDownloadImageType]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KonachanDownloadImageTypeDidChangedNotification object:nil];
    }
}

- (void) showHUDWithTitle:(NSString *)title content:(NSString *)content {
    [self dismissNumberPadKeyboard];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = title;
    hud.detailsLabelText = content;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    [self configureFetchAmount];
}

- (void) dismissNumberPadKeyboard {
    [self.fetchAmountTextField resignFirstResponder];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
