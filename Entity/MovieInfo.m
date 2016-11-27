//
//  MovieInfo.m
//  repeater
//
//  Created by admin on 2016. 2. 10..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "MovieInfo.h"

@implementation MovieInfo

/*---------------------
 LOAD DETAIL PAGE HTML
 ----------------------*/
- (void)loadHtmlOfDetailPage:(NSString*)pUrl
           handlerOnComplete:(void(^)(NSData* pSource))phandlerOnComplete
{
    NSURL *URL = [NSURL URLWithString:pUrl];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:URL
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error)
      {
          phandlerOnComplete(data);
      }] resume];
}

/*----------------
 LOAD THUMB-IMAGE
 -----------------*/
- (void)loadThumbImage:(NSString*)pUrl
     handlerOnComplete:(void(^)(NSData* pImage))phandlerOnComplete
{
    //NSLog(@"TED 이미지 가져오기");
    //Request image data from the URL:
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:pUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imgData)
            {
                phandlerOnComplete(imgData);
            }
            else
            {
                //Failed to get the image data:
                NSLog(@"이미지 불러오기 오류");
            }
        });
    });
}

@end
