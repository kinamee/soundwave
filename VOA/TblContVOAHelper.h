//
//  TblContVOAHelper.h
//  repeater
//
//  Created by admin on 2016. 2. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieInfo.h"
#import "TblContVOA.h"

@interface TblContVOAHelper : NSObject

@property (nonatomic, weak) TblContVOA* needHelp;

@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL isError;

+ (TblContVOAHelper*)shared;

- (void)analizeHtml:(NSString*)pURL
  handlerOnComplete:(void(^)(NSDictionary* pMovieInfo))phandlerOnComplete;

- (void)analizeHtmlForDuration:(NSString*)pURL
             handlerOnComplete:(void(^)(NSString* pDuration))phandlerOnComplete;

- (NSString*)findDuration:(NSData*)pHtmlData;
- (NSString*)findScript:(NSData*)pHtmlData;

- (void)newNamePrompt:(NSString*)pDefaultName
                title:(NSString*)pTitle
              message:(NSString*)pMessage
    handlerOnComplete:(void(^)(NSString* pNewName))phandlerOnComplete;

/*----------------------------------------
 FIND A LINK TO DOWNLOAD WITH HTML-SOURCE
 -----------------------------------------*/
- (NSString*)findLinkToDownload:(NSData*)pHtmlData;

@end
