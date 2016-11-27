//
//  SubTitle.h
//  repeater
//
//  Created by admin on 2016. 3. 4..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubTitleCaption.h"

@interface SubTitle : NSObject
{
    
}

+(SubTitle*)shared;

- (void)loadSRT:(NSString*)pMoviePath;

- (SubTitleCaption*)captionOfindexAt:(NSInteger)pIndex;
- (SubTitleCaption*)captionAtSec:(float)pSec;
- (SubTitleCaption*)firstCaptionGreaterThanAtSec:(float)pSec;

@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, retain) NSMutableDictionary* dictCaption;

@end
