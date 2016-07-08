//
//  YDConstants.h
//  Yadayo
//
//  Created by 小笠原やきん on 16/5/26.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const YDCategoryEntityName = @"Category";
static NSString * const YDSiteEntityName     = @"Site";
static NSString * const YDTagEntityName      = @"Tag";
static NSString * const YDImageEntityName    = @"Image";
static NSString * const YDKeywordEntityName  = @"Keyword";
static NSString * const YDFeedItemEntityName = @"FeedItem";

static NSString * const kWeekdayUnit = @"weekday";
static NSString * const kCreateDate  = @"createDate";

// FeedItem key
static NSString * const kPubDate = @"pubDate";

// Preference key
static NSString * const kReminderSiteName = @"reminder_site_name";

static NSString * const YDSiteCellIdentifier     = @"SiteCell";
static NSString * const YDPhotoCellIdentifier    = @"PhotoCell";
static NSString * const YDTagCellIdentifier      = @"TagCell";
static NSString * const YDSettingCellIdentifier  = @"Setting Cell";
static NSString * const YDKeywordCellIdentifier  = @"KeywordCell";
static NSString * const YDTorrentCellIdentifier  = @"TorrentCell";
static NSString * const YDFeedItemCellIdentifier = @"FeedItemCell";
static NSString * const YDExportCellIdentifier = @"ExportCell";
static NSString * const YDGalleryModeCellIdentifier = @"GalleryModeCell";

static NSString * const YDShowDanbooruSegueIdentifier      = @"Show Danbooru";
static NSString * const YDShowPhotosSegueIdentifier        = @"Show Photos";
static NSString * const YDAddKeywordSegueIdentifier        = @"Add Keyword";
static NSString * const YDShowKeywordDetailSegueIdentifier = @"Show Keyword Detail";
static NSString * const YDShowItemDetailSegueIdentifier    = @"Show Item Detail";

static NSString * const YDTagAll = @"";

static NSString * const YDParseAppId = @"Yadayo";
static NSString * const YDParseServer = @"http://192.168.1.110:1337/parse";

@interface YDConstants : NSObject
@end

// KonachanAPI https://github.com/yaqinking/Konachan-iOS/

//Debug mode
//YES = 1 NO = 0
#define IS_DEBUG_MODE 1
//Get Post

//get post with limit per page image and page number and tags
#define KONACHAN_POST_LIMIT_PAGE_TAGS @"http://konachan.com/post.json?limit=%i&page=%i&tags=%@"

//safe mode Konachan
#define KONACHAN_SAFE_MODE_POST_LIMIT_PAGE_TAGS @"http://konachan.com/post.json?limit=%i&page=%i&tags=%@+rating:s"

//yande.re
#define YANDERE_POST_LIMIT_PAGE_TAGS  @"https://yande.re/post.json?limit=%i&page=%i&tags=%@"

//Example
//Get saenai_heroine_no_sodatekata Perpage 10 images
//http://konachan.com/post.json?limit=10&page=1&tags=saenai_heroine_no_sodatekata
//Get saenai_heroine_no_sodatekata Perpage 20 images and Page number is 2
//http://konachan.com/post.json?limit=20&page=2&tags=saenai_heroine_no_sodatekata

//get 10 posted images default max=100 per page
#define KONACHAN_POST_LIMIT_DEFAULT      @"http://konachan.com/post.json?limit=10"

//get 10 posted images set you want display page number
#define KONACHAN_POST_LIMIT_DEFAULT_PAGE @"http://konachan.com/post.json?limit=10&page=%i"

//Download illustrate quality key
static NSString * const PreviewURL = @"preview_url";
static NSString * const SampleURL = @"sample_url";
static NSString * const JPEGURL = @"jpeg_url";
static NSString * const FileURL = @"file_url";

//Get illustrate title/tags key
static NSString * const PictureTags = @"tags";

static NSString * const KonachanShortcutItemAddKeyword = @"moe.yaqinking.Konachan.AddKeyword";
static NSString * const KonachanShortcutItemViewAll    = @"moe.yaqinking.Konachan.ViewAll";
static NSString * const KonachanShortcutItemViewLast   = @"moe.yaqinking.Konachan.ViewLast";
static NSString * const KonachanShortcutItemViewSecond = @"moe.yaqinking.Konachan.ViewSecond";

static NSString * const KonachanSegueIdentifierShowTagPhotos = @"Show Tag Photos";
static NSString * const KonachanDownloadImageTypeDidChangedNotification = @"DownloadImageTypeDidChangedNotification";

//Base URL
static NSString * const Konachan_com = @"https://konachan.com";
static NSString * const Yande_re = @"https://yande.re";

typedef NS_ENUM(NSInteger, KonachanImageDownloadType) {
    KonachanImageDownloadTypeUnseted,
    KonachanImageDownloadTypePreview,
    KonachanImageDownloadTypeSample,
    KonachanImageDownloadTypeJPEG,
    KonachanImageDownloadTypeFile
};

typedef NS_ENUM(NSInteger, KonachanSourceSiteType) {
    KonachanSourceSiteTypeUnseted,
    KonachanSourceSiteTypeKonachan_com,
    KonachanSourceSiteTypeKonachan_net,
    KonachanSourceSiteTypeYande_re
};

typedef NS_ENUM(NSInteger, KonachanPreviewImageLoadType) {
    KonachanPreviewImageLoadTypeUnseted,
    KonachanPreviewImageLoadTypeLoadPreview,
    KonachanPreviewImageLoadTypeLoadDownloaded
};

#define SplitViewScreeniPad_Half           507
#define SplitViewScreeniPad_Slide_Over     320
#define SplitViewScreeniPad_Landscape2_3   694
#define SplitViewScreeniPad_Portrait_1_1_2 438

#define SplitViewScreeniPad_Pro_Half           678
#define SplitViewScreeniPad_Pro_Slide_Over     375
#define SplitViewScreeniPad_Pro_Landscape2_3   981
#define SplitViewScreeniPad_Pro_Portrait_1_1_2 639

#define iPad_Width 768
#define iPad_Pro_Width 1024

#define kFetchAmountDefault    60
#define kFetchAmountMin        40
#define kFetchAmountiPadProMin 75

#define kSourceSite   @"source_site"
#define kFetchAmount  @"fetch_amount"
#define kThumbLoadWay @"thumbLoadWay"
#define kDownloadImageType @"download_type"
#define kPreloadNextPage @"preload_next_page"
#define kSwitchSite @"switch_site"
#define kOfflineMode @"offline_mode"

//Ratings
#define kRatingSafe         @"s"
#define kRatingQuestionable @"q"
#define kRatingExplicit     @"e"

//For device adaption
#define iPadProPortrait ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.height == 1366)
#define iPadProLandscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.width == 1366)
#define iPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define iPadPortrait ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.height == 1024)
#define iPadLandscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.width == 1024)
#define iPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define iPhone3_5InchPortrait ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 480)
#define iPhone3_5InchLandscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width == 480)
#define iPhone4InchPortrait ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define iPhone4InchLandscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width == 568)
#define iPhone6Portrait ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 667)
#define iPhone6Landscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width == 667)
#define iPhone6PlusPortrait ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 736)
#define iPhone6PlusLandscape ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.width == 736)


// DMHY API

#ifndef DMHYAPI_h
#define DMHYAPI_h

#define DMHYRSS                       @"https://share.dmhy.org/topics/rss/rss.xml"
#define DMHYSearchByKeyword           @"https://share.dmhy.org/topics/rss/rss.xml?keyword=%@"

#define DMHYdandanplayRSS             @"http://dmhy.dandanplay.com/topics/rss/rss.xml"
#define DMHYdandanplaySearchByKeyword @"http://dmhy.dandanplay.com/topics/rss/rss.xml?keyword=%@"

#define DMHYACGGGRSS                  @"http://bt.acg.gg/rss.xml"
#define DMHYACGGGSearchByKeyword      @"http://bt.acg.gg/rss.xml?keyword=%@"

// BangumiMoe return JSON data. Also can set placeholder to [page][limit].
#define DMHYBangumiMoeRSS             @"https://bangumi.moe/api/v2/torrent/page/1?limit=50"
#define DMHYBangumiMoeSearchByKeyword @"https://bangumi.moe/api/v2/torrent/search?limit=50&p=1&query=%@"

#define DMHYACGRIPRSS                 @"https://acg.rip/.xml"
#define DMHYACGRIPSearchByKeyword     @"https://acg.rip/.xml?term=%@"

#define DMHYKissSubRSS                @"http://www.kisssub.org/rss.xml"
#define DMHYKissSubSearchByKeyword    @"http://www.kisssub.org/rss-%@.xml"

#define kXpathTorrentDownloadShortURL   @"//div[@class='dis ui-tabs-panel ui-widget-content ui-corner-bottom']/a/@href"
#define kXpathTorrentDirectDownloadLink @"//div[@class='dis']//p//a//@href"

#define DMHYURLPrefixFormat             @"https:%@"
#define DMHYDandanplayURLPrefixFormat   @"http:%@"

#define DMHYBangumiMoeAPITorrentPagePrefixFormat  @"https://bangumi.moe/api/v2/torrent/%@"
//#define DMHYBangumiMoeOpenTorrentPagePrefixFormat @"https://bangumi.moe/torrent/%@"

#define DMHY       @"share.dmhy.org"
#define Dandanplay @"dmhy.dandanplay.com"
#define ACGGG      @"bt.acg.gg"
#define BangumiMoe @"bangumi.moe"

#endif /* DMHYAPI_h */