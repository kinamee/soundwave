//
//  TblContForFileHelper.h
//  repeater
//
//  Created by admin on 2016. 1. 29..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TblContFile.h"
#import "FileInfo.h"

@interface TblContFileHelper : NSObject
{
}

@property (nonatomic, weak) TblContFile* needHelp;

+(TblContFileHelper*)shared;

/*----------------------------
 CHANGE THE EDIT-BUTTON STATE
 -----------------------------*/
- (void)changeButtonState:(NSDictionary*)pDictOfSelected;

/*-------------------------------
 SHOW LATEST PLAYING INFO OR NOT
 --------------------------------*/
- (void)showRecentPlaying:(BOOL)pOnOff;

/*---------------------------------------------
 GET RENEW NAME FROM PROMPT-ALERT-VIEW
 ----------------------------------------------*/
- (void)newNamePrompt:(NSString*)pDefaultName
               title:(NSString*)pTitle
             message:(NSString*)pMessage
        handlerOnComplete:(void(^)(NSString* pNewName))phandlerOnComplete;

/*-------------------
 GET NEXT MOVIE FILE
 --------------------*/
- (NSString*)nextMovieFileIn:(NSDictionary*)pDictFile
                    currFile:(NSString*)pCurrMovieFile;

- (NSString*)randomMovieFileIn:(NSDictionary*)pDictFile
                      currFile:(NSString*)pCurrMovieFile;

/*-------------------
 RESIZE TABLE HEIGHT
 --------------------*/
- (void)resizeTableHeight;

/*-----------------
 GET CELL IDENTITY
 ------------------*/
- (NSString*)cellIdentityString:(FileInfo*)pFifo isEditmode:(BOOL)isEditmode;

/*-------------
 REFRESH TABLE
 --------------*/
- (void)refreshTable;

@end
