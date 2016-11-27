//
//  MovieInfo.h
//  repeater
//
//  Created by admin on 2016. 2. 10..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MovieInfo : NSObject
{
}

/*---------------------
 LOAD DETAIL PAGE HTML
 ----------------------*/
- (void)loadHtmlOfDetailPage:(NSString*)pUrl
           handlerOnComplete:(void(^)(NSData* pSource))phandlerOnComplete;

/*----------------
 LOAD THUMB-IMAGE
 -----------------*/
- (void)loadThumbImage:(NSString*)pUrl
     handlerOnComplete:(void(^)(NSData* pImage))phandlerOnComplete;

@property (nonatomic, copy) NSString* movieTitle;
@property (nonatomic, copy) NSString* movieDesc;
@property (nonatomic, copy) NSString* linkToDetailPage;
@property (nonatomic, copy) NSString* linkToDownload;
@property (nonatomic, copy) NSString* linkToThumb;
@property (nonatomic, copy) NSString* pubDateTime;
@property (nonatomic, copy) NSString* durationTime;
@property (nonatomic, retain) NSData* imgShot;
@property (nonatomic, retain) NSData* htmlOfDetailPage;

@end
