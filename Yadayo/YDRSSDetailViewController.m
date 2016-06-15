//
//  YDRSSDetailViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/6/4.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDRSSDetailViewController.h"
#import "YDFeedItem.h"
#import "MWPhotoBrowser.h"
#import "Ono.h"
#import "SDWebImagePrefetcher.h"

@import WebKit;
@import SafariServices;

@interface YDRSSDetailViewController ()<MWPhotoBrowserDelegate>

@property (strong, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableArray<NSURL *> *prefetchURLs;

@end

@implementation YDRSSDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavbarItems];
    self.title = self.item.title;
    NSString *htmlString = self.item.content.length > 0 ? self.item.content : self.item.summary;
    NSString *header = @"<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><style type=\"text/css\"> img { width: 100%; } </style></head><body>";
    NSString *footer = @"</body></html>";
    htmlString = [NSString stringWithFormat:@"%@%@%@",header, htmlString, footer];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollScreenDistance:)];
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.numberOfTapsRequired = 1;
    [self.webView addGestureRecognizer:tapGesture];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.hidesBarsOnSwipe = YES;
}

- (void)setupNavbarItems {
    UIBarButtonItem *safariVC = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SafariItem"] style:UIBarButtonItemStylePlain target:self action:@selector(viewInSafariViewController)];
    UIBarButtonItem *galleryVC = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ThumbnailsItem"] style:UIBarButtonItemStylePlain target:self action:@selector(viewInGallery)];
    self.navigationItem.rightBarButtonItems =@[safariVC, galleryVC];
}

- (void)viewInSafariViewController {
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:self.item.link]];
    [self presentViewController:safariVC animated:YES completion:nil];
}

- (void)viewInGallery {
    NSLog(@"Content %@",self.item.content);
    [self setupPhotos];
    if (self.photos.count > 0) {
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:self.photos];
        browser.delegate = self;
        browser.enableGrid = NO;
        browser.displayNavArrows = YES;
        browser.zoomPhotosToFill = YES;
        browser.enableSwipeToDismiss = YES;
        [self.navigationController pushViewController:browser animated:YES];
        self.navigationController.hidesBarsOnSwipe = NO;
        [self prefetchImages];
    }
}

- (void)setupPhotos {
    NSString *htmlString = self.item.content.length > 0 ? self.item.content : self.item.summary;
    if (self.photos.count == 0) {
        ONOXMLDocument *doc = [ONOXMLDocument HTMLDocumentWithString:htmlString encoding:NSUTF8StringEncoding error:nil];
        [doc enumerateElementsWithXPath:@"//img/@src" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            if ([[element stringValue] containsString:@"http://ad"]) return ;
            NSURL *url = [NSURL URLWithString:[element stringValue]];
            MWPhoto *photo = [MWPhoto photoWithURL:url];
            [self.photos addObject:photo];
            [self.prefetchURLs addObject:url];
        }];
    }
}

- (void)prefetchImages {
    SDWebImagePrefetcher *fetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
    fetcher.maxConcurrentDownloads = 5;
    [fetcher prefetchURLs:self.prefetchURLs];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count){
        return [self.photos objectAtIndex:index];
    }
    return nil;
}

- (NSMutableArray *)photos {
    if (!_photos) {
        _photos = [NSMutableArray new];
    }
    return _photos;
}

- (NSMutableArray<NSURL *> *)prefetchURLs {
    if (!_prefetchURLs) {
        _prefetchURLs = [NSMutableArray new];
    }
    return _prefetchURLs;
}

- (void)scrollScreenDistance:(UITapGestureRecognizer *)recongizer {
    NSLog(@"Taped");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
