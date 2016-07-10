//
//  YDBackgroundFetcher.h
//  Yadayo
//
//  Created by 小笠原やきん on 7/9/16.
//  Copyright © 2016 yaqinking. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YDBackgroundFetcher : NSObject

+ (YDBackgroundFetcher *)sharedFetcher;

- (void)backgroundFetchDataWithCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler;

@end
