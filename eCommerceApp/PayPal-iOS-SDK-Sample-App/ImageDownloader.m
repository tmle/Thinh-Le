//
//  ImageDownloader.m
//  eCommerce-App
//
//  Created by Thinh Le on 2015-05-28.
//  Copyright (c) 2015 Skin Tree. All rights reserved.
//

#import "ImageDownloader.h"

// 1
@interface ImageDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
//@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;
@property (nonatomic, readwrite, strong) PhotoRecord2 *photoRecord;

@end

@implementation ImageDownloader
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize photoRecord = _photoRecord;

#pragma mark -
#pragma mark - Life Cycle

- (id)initWithPhotoRecord:(PhotoRecord2 *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {
    
    if (self = [super init]) {
        // 2
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

#pragma mark -
#pragma mark - Downloading image

// 3
- (void)main {
    
    // 4
    @autoreleasepool {
        
        if (self.isCancelled)
            return;
        
        //NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];
        NSData *thumbnailData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.recordThumbnailURL];
        
        if (self.isCancelled) {
            thumbnailData = nil;
            //imageData = nil;
            return;
        }
        
        if (thumbnailData) {
        //if (imageData) {
            //UIImage *downloadedImage = [UIImage imageWithData:imageData];
            UIImage *downloadedImage = [UIImage imageWithData:thumbnailData];

            //self.photoRecord.image = downloadedImage;
            self.photoRecord.recordThumbnailData = downloadedImage;

        }
        else {
            self.photoRecord.failed = YES;
        }
        //imageData = nil;
        thumbnailData = nil;

        if (self.isCancelled)
            return;
        
        // 5
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}

@end