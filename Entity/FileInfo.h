//
//  FileInfo.h
//  repeater
//
//  Created by admin on 2016. 2. 23..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FileInfo : NSObject

/*----------------------------------------------------
 GET DURATION. IF THE FILE IS NOT PLAYABLE RETURN NIL
 -----------------------------------------------------*/
- (NSString*)durationSec;
- (NSString*)durationTimeFormatted;

/*----------------------------------
 GET THUMB IMAGE FROM VIDEO AT 5SEC
 -----------------------------------*/
-(UIImage *)loadThumb:(float)pCurrSec;

@property (nonatomic, copy) NSString* fileNameOnly;
@property (nonatomic, copy) NSString* fileNameFull;
@property (nonatomic, copy) NSString* fileExtention;
@property (nonatomic, copy) NSString* directoryPath;
@property (nonatomic, copy) NSString* fileSize;
@property (nonatomic, copy) NSString* dateCreated;
//@property (nonatomic, copy) NSString* durationSec;
//@property (nonatomic, copy) NSString* durationTimeFormatted;
@property (nonatomic, assign) BOOL isTypeOfDir;
@property (nonatomic, copy) NSDate* dateCreatedRaw;

-(NSString*)fileNamefullByNewExt:(NSString*)pNewExt;

-(void)printLog;

@end
