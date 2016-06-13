//
//  YDRSSDetailViewController.m
//  Yadayo
//
//  Created by 小笠原やきん on 16/6/4.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDRSSDetailViewController.h"
#import "WebKit/WKWebView.h"
#import "YDFeedItem.h"

@interface YDRSSDetailViewController ()

@property (strong, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation YDRSSDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.item.title;
    self.navigationController.hidesBarsOnSwipe = YES;
    
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