//
//  TblContVOAHelper.h
//  repeater
//
//  Created by admin on 2016. 2. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieInfo.h"
#import "TblContTED.h"

@interface TblContTEDHelper : NSObject
{
}

@property (nonatomic, weak) TblContTED* needHelp;

+ (TblContTEDHelper*)shared;

- (void)analizeHtml:(NSString*)pUrl
  handlerOnComplete:(void(^)(NSDictionary* pMovieInfo))phandlerOnComplete;

- (void)newNamePrompt:(NSString*)pDefaultName
                title:(NSString*)pTitle
              message:(NSString*)pMessage
    handlerOnComplete:(void(^)(NSString* pNewName))phandlerOnComplete;

/*----------------------------------------
 FIND A LINK TO DOWNLOAD WITH HTML-SOURCE
 -----------------------------------------*/
- (NSString*)findLinkToDownload:(NSData*)pHtmlData;

@end
