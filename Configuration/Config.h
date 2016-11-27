//
//  KSPlistMgr.h
//  repeater
//
//  Created by admin on 2015. 12. 27..
//  Copyright © 2015년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*--------------------------------
 TYPE OF ACTION AFTER PLAYING END
 ---------------------------------*/
typedef NS_OPTIONS(NSUInteger, OPTION_TypeOnPlayEnd) {
    OPTION_PLY_NEXT     = 1 << 0,
    OPTION_PLY_REPEAT   = 1 << 1,
    OPTION_PLY_RANDOM   = 1 << 2
};
/*---------------
 TYPE OF GESTURE
 ----------------*/
typedef NS_OPTIONS(NSUInteger, OPTION_TypeOnGesture) {
    OPTION_GES_SINGLE   = 1 << 0,
    OPTION_GES_DOUBLE   = 1 << 1,
    OPTION_GES_LEFT     = 1 << 2,
    OPTION_GES_RIGHT    = 1 << 3,
    OPTION_GES_UP       = 1 << 4,
    OPTION_GES_DOWN     = 1 << 5
};
/*--------------------------------
 TYPE OF ACTION AFTER PLAYING END
 ---------------------------------*/
typedef NS_OPTIONS(NSUInteger, OPTION_TypeOnGestureAction) {
    OPTION_GAT_NONE   = 1 << 0,
    OPTION_GAT_PLAY   = 1 << 1,
    OPTION_GAT_MENU   = 1 << 2,
    OPTION_GAT_PREV   = 1 << 3,
    OPTION_GAT_NEXT   = 1 << 4,
    OPTION_GAT_PASS   = 1 << 5,
    OPTION_GAT_BACK   = 1 << 6,
    OPTION_GAT_SAME   = 1 << 7
};

@interface Config : NSObject {
}

+ (Config*)shared;
- (void)copyConfigToDoc;
- (void)writeToFile;

/*-------------------------
 TRANSLATE KOREAN INTO ENG
 --------------------------*/
- (NSString*)trans:(NSString*)pMessage;

/*---------------------
 GETTER GESTURE ACTION
 ----------------------*/
- (OPTION_TypeOnGestureAction)getGesture:(OPTION_TypeOnGesture)pGesture;

/*-------------------------------
 CHECK IS THE SUPPORTED MOV FILE
 --------------------------------*/
- (BOOL)isSupportedFile:(NSString*)pFileExe;

/*-----------------------------------------
 GETTER & SETTER WAITING SEC BEFORE PLAYER
 ------------------------------------------*/
- (float)getWaitingSec;
- (void)setWaitingSec:(float)pSec;

/*------------------------------
 SAVE CURRENT FILE INTO HISTORY
 -------------------------------*/
- (void)insertIntoHistory:(NSString*)pFilePath currSec:(float)pCurrSec;
- (void)removeFromHistory:(NSString*)pFilePath;
- (float)secFromHistory:(NSString*)pFilePath;
- (void)clearHistoryGabage;

/*---------------------------------
 SAVE CURRENT FILE AS A LATEST ONE
 ----------------------------------*/
- (void)setRecentPlaying:(NSString*)pFilePath
                fileSize:(NSString*)pFileSize
                curreSec:(float)pCurreSec
                totalSec:(float)pTotalSec;
/*---------------------------------
 LOAD CURRENT FILE AS A LATEST ONE
 ----------------------------------*/
- (void)getRecentPlaying:(NSString**)pFilePath
                fileSize:(NSString**)pFileSize
              currentSec:(NSString**)pCurreSec
                totalSec:(NSString**)pTotalSec;
- (NSString*)getRecentFile;
- (BOOL)isBeingRecentFile;
- (float)getRecentSec;
- (void)setRecentFile:(NSString*)pFilePath;

/*------------------------------
 GETTER & SETTER CAPTION ON-OFF
 -------------------------------*/
- (BOOL)getCaptionOnOFF;
- (void)setCaptionOnOFF:(BOOL)pOnOFF;

/*-------------------------------------------
 GETTER & SETTER OF REPEAT INFINITELY ON-OFF
 --------------------------------------------*/
- (BOOL)getRepeatInfiniteOnOff;
- (void)setRepeatInfiniteOnOff:(BOOL)pOnOff;

/*--------------------------------
 GETTER & SETTER OF REPEAT ON-OFF
 ---------------------------------*/
- (BOOL)getRepeatOnOff;
- (void)setRepeatOnOff:(BOOL)pOnOff;

/*-------------------------------
 GETTER & SETTER OF REPEAT COUNT
 --------------------------------*/
- (int)getRepeatCount;
- (void)setRepeatCount:(int)pCount;

/*------------------------------------------
 GETTER & SETTER OF MINUMUM SENTENCE SECOND
 -------------------------------------------*/
- (float)getMinimumSenSec;
- (void)setMinimumSenSec:(float)pSec;

/*---------------------------------------
 GETTER & SETTER OF AFTER END OF PLAYING
 ----------------------------------------*/
- (OPTION_TypeOnPlayEnd)getAfterEndOfPlay;
- (void)setAfterEndOfPlay:(OPTION_TypeOnPlayEnd)pNextPlayType;

/*----------------------------------
 CHANGE TOTAL SECONS TO TIME-FORMAT
 -----------------------------------*/
- (NSString*)timeFormatted:(int)totalSeconds;
- (float)timeFormattedToSec:(NSString*)pTimeFormat;

/*---------------------
 CHECK WIFI CONNECTION
 ----------------------*/
- (BOOL)isWiFiConnect;

@property (nonatomic, assign) float playSpeed;
@property (nonatomic, assign) BOOL isVolumeMuted;
@property (nonatomic, assign) BOOL isFirstExec;

@property (nonatomic, retain) NSMutableDictionary* dictToConf;
@property (nonatomic, retain) NSMutableDictionary* dictToHist;
@property (nonatomic, retain) NSMutableDictionary* dictToTran;

@property (nonatomic, retain) NSString* language;
@property (nonatomic, retain) NSMutableArray* arrRepeatCount;
@property (nonatomic, retain) NSMutableArray* arrMinSentenceLen;

@end
