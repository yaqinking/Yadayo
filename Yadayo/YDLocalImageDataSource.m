//
//  LocalImageDataSource.m
//  Konachan
//
//  Created by 小笠原やきん on 16/5/13.
//  Copyright © 2016年 yaqinking. All rights reserved.
//

#import "YDLocalImageDataSource.h"
#import "YDImage.h"
#import "AppDelegate.h"
#import "Picture.h"
#import "YDCoreDataStackManager.h"
#import "YDConstants.h"
@interface YDLocalImageDataSource()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStore *cachePersistentStore;
@property (nonatomic, strong) NSManagedObjectContext *privateContext;

@end

@implementation YDLocalImageDataSource

- (NSString *)fliterWithTag:(NSString *)tag {
    return ([tag isEqualToString:@"post"] || [tag isEqualToString:@"all"]) ? @"": tag;
}

- (NSDictionary *)imageDataDictionaryWithTag:(NSString *)tag {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    NSString *fliter = [self fliterWithTag:tag];
    if (fliter.length != 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"tags CONTAINS %@", fliter];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"image_id" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSArray<YDImage *> *fetchedResults = [self.managedObjectContext executeFetchRequest:request error:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    __block NSInteger downloadImageType = [userDefaults integerForKey:kDownloadImageType];
    __block NSInteger thumbLoadWay = [[NSUserDefaults standardUserDefaults] integerForKey:kThumbLoadWay];
    
    __block NSMutableArray<NSURL *> *previewURLs = [NSMutableArray new];
    __block NSMutableArray<Picture *> *photos = [NSMutableArray new];
    [fetchedResults enumerateObjectsUsingBlock:^(YDImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Picture *photoPic;
        switch (downloadImageType) {
            case KonachanImageDownloadTypeSample:
                photoPic = [[Picture alloc] initWithURL:[NSURL URLWithString:obj.sample_url]];
                break;
            case KonachanImageDownloadTypeJPEG:
                photoPic = [[Picture alloc] initWithURL:[NSURL URLWithString:obj.jpeg_url]];
                break;
            case KonachanImageDownloadTypeFile:
                photoPic = [[Picture alloc] initWithURL:[NSURL URLWithString:obj.file_url]];
                break;
            default:
                photoPic = [[Picture alloc] initWithURL:[NSURL URLWithString:obj.sample_url]];
                break;
        }
        photoPic.caption = obj.tags;
        [photos addObject:photoPic];
        
        switch (thumbLoadWay) {
            case KonachanPreviewImageLoadTypeLoadPreview:
                [previewURLs addObject:[NSURL URLWithString:obj.preview_url]];
                break;
            case KonachanPreviewImageLoadTypeLoadDownloaded:
                switch (downloadImageType) {
                    case KonachanImageDownloadTypeSample:
                        [previewURLs addObject:[NSURL URLWithString:obj.sample_url]];
                        break;
                    case KonachanImageDownloadTypeJPEG:
                        [previewURLs addObject:[NSURL URLWithString:obj.jpeg_url]];
                        break;
                    case KonachanImageDownloadTypeFile:
                        [previewURLs addObject:[NSURL URLWithString:obj.file_url]];
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
    }];
    NSDictionary *dataDictionary = @{@"preview_urls": previewURLs,
                                     @"photos": photos};
    return dataDictionary;
}

- (NSArray<YDImage *> *)imagesWithTag:(NSString *)tag {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    NSString *fliter = [self fliterWithTag:tag];
    if (fliter.length != 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"tags CONTAINS %@", fliter];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"image_id" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSArray<YDImage *> *fetchedResults = [self.managedObjectContext executeFetchRequest:request error:nil];
    return fetchedResults;
}

- (void)insertImagesFromResonseObject:(id)responseObject {
    //[历史笔记]由于这里是从 TagPhotosViewController 创建的 data queue 里过来的，而 MOC（ManagedObjectContext） 不能在非创建时的 queue 里使用，有一定几率（数据变化量大的话，绝对）会出现 *** Terminating app due to uncaught exception 'NSGenericException', reason: '*** Collection <__NSCFSet: 0x5e0b930> was mutated while being enumerated... 错误，而我这个 MOC 是 main queue 的，So，返回主线程执行。
    /*
     2016/07/15 使用 PrivateContext 来把原本在 main queue 里执行的方法转移到 private queue 中，减少主线程等待时间。（可以使用 Instruments 的 Time Profiler 来查看每个方法执行的时间，记得勾选 Call Tree tab 里的 Top Functions、Hide　Sytem　Libraries）
     参考：
     1. Core Data Programming Guide: Concurrency https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/Concurrency.html
     2. Core Data Tutorial: Multiple Managed Object Contexts https://www.raywenderlich.com/113489/core-data-tutorial-multiple-managed-object-contexts
    */
    if ([responseObject isKindOfClass:[NSArray class]]) {
        [responseObject enumerateObjectsUsingBlock:^(NSDictionary *picDict, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *previewURLString = picDict[PreviewURL];
            NSString *sampleURLString  = picDict[SampleURL];
            NSString *jpegURLString = picDict[JPEGURL];
            NSString *fileURLString = picDict[FileURL];
            NSString *picTitle         = picDict[PictureTags];
            NSString *md5 = picDict[@"md5"];
            NSInteger create_at = [picDict[@"created_at"] integerValue];
            NSInteger image_id = [picDict[@"id"] integerValue];
            NSString *rating = picDict[@"rating"];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:YDImageEntityName];
            request.predicate = [NSPredicate predicateWithFormat:@"image_id == %i",image_id];
            
            [self.privateContext performBlockAndWait:^{
                NSArray *fetchedImages = [[self.privateContext executeFetchRequest:request error:NULL] copy];
                if (fetchedImages.count == 0) {
                    YDImage *image = [NSEntityDescription insertNewObjectForEntityForName:YDImageEntityName inManagedObjectContext:self.privateContext];
                    image.image_id = [NSNumber numberWithInteger:image_id];
                    image.create_at = [NSNumber numberWithInteger:create_at];
                    image.md5 = md5;
                    image.tags = picTitle;
                    image.preview_url = previewURLString;
                    image.sample_url = sampleURLString;
                    image.file_url = fileURLString;
                    image.jpeg_url = jpegURLString;
                    image.rating = rating;
                    [self.privateContext assignObject:image toPersistentStore:self.cachePersistentStore];
                } else {
                    *stop = YES;
                }
            }];
        }];
        [self.privateContext performBlock:^{
            NSError *error = nil;
            if (![self.privateContext save:&error]) {
                NSLog(@"PrivateContext save error %@", [error localizedDescription]);
            }
        }];
    }
}

- (NSManagedObjectContext *)privateContext {
    if (!_privateContext) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateContext setParentContext:self.managedObjectContext];
    }
    return _privateContext;
}

- (void)clearImages {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Image"];
    NSArray<YDImage *> *fetchedResults = [self.managedObjectContext executeFetchRequest:request error:nil];
    [fetchedResults enumerateObjectsUsingBlock:^(YDImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.managedObjectContext deleteObject:obj];
    }];
    [self saveChanges];
}

- (void)saveChanges {
    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Local Image Data Source Error when saving %@", [error localizedDescription]);
        }
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[YDCoreDataStackManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

- (NSPersistentStore *)cachePersistentStore {
    if (!_cachePersistentStore) {
        _cachePersistentStore = [[YDCoreDataStackManager sharedManager] cachePersistentStore];
    }
    return _cachePersistentStore;
}

@end
