//
//  SentGroup.h
//  repeater
//
//  Created by admin on 2016. 5. 19..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SentInfo.h"
#import "SentenceFinder.h"

/*-----------------------------------
 TYPE OF DIRECTION TO FIND SENTENCE
 ------------------------------------*/
typedef NS_OPTIONS(NSUInteger, Type_DirectionToFind) {
    DIRECTION_RIGHT      = 1 << 0,
    DIRECTION_LEFT       = 1 << 1,
    DIRECTION_NEW        = 1 << 2,
    DIRECTION_NEW_PLUS   = 1 << 3
};

@protocol protocolSentGroup <NSObject>
@required
- (void)onCreateSenGroupComplete:(UIImage*)pTotImageAnalog
                  totImageDigita:(UIImage*)pTotImageDigita
                  totImageSenten:(UIImage*)pTotImageSenten
           staSecOfTotSoundGraph:(float)pStaSecOfTotSoundGraph
           endSecOfTotSoundGraph:(float)pEndSecOfTotSoundGraph
                         currSec:(float)pCurrSec;
@end

@interface SentGroup : NSObject

+ (SentGroup*)shared;

@property (nonatomic, weak) id <protocolSentGroup> delegate;

/*------------------
 병합된 문장 인덱스 검사
 -------------------*/
- (BOOL)checkIndexOfAllSen;

- (BOOL)isCompleteFindAllSen;

/*--------------------------------------------------------------
 기존 문장에 덧붙여 특정 방향의 문장들을 만든다 또는 특정 위치에서 새롭게 제작한다
 ---------------------------------------------------------------*/
- (void)createSentGroup:(NSString*)pMediaPath
              audioPath:(NSString*)pAudioPath
            audioDura:(float)pTotDuration
              direction:(Type_DirectionToFind)pDirection
                currSec:(float)pCurrSec;

/*------------------
 쓰레드 사용하여 제작한다
 -------------------*/
- (void)createSentGroupInThread:(NSString*)pMediaPath
                      audioPath:(NSString*)pAudioPath
                             audioDura:(float)pAudioDura
                             direction:(Type_DirectionToFind)pDirection
                               currSec:(float)pCurrSec;

- (void)getSentImageIn80Sec:(float)pTotDuration
                 currSec:(float)pCurrSec
               analogImg:(UIImage**)pAnalogImg
               digitaImg:(UIImage**)pDigitaImg
               sentenImg:(UIImage**)pSentenImg;

/*--------------------------
 현재까지 병합된 이미지들을 반환한다
 ---------------------------*/
- (void)getSentenceImageTotAmt:(UIImage**)pAnalogImg
                     digitaImg:(UIImage**)pDigitaImg
                     sentenImg:(UIImage**)pSentenImg;

- (NSInteger)countOfallSen;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;

- (void)clear;
- (void)add:(SentInfo*)pSen;
- (void)deleteLastSen;
- (void)deleteAfterSec:(float)pSec;

- (SentInfo*)getLastSen;
- (SentInfo*)getFirstSen;
- (SentInfo*)getByIndex:(NSInteger)pIndex;
- (SentInfo*)getBySecond:(float)pAnySec;
- (SentInfo*)getBySecond:(float)pAnySec nextIfInBlank:(BOOL)pNextSenIfInBlank;
- (SentInfo*)getBySecond:(float)pAnySec prevIfInBlank:(BOOL)pPrevSenIfInBlank;
- (SentInfo*)getNextSenFromBlankSec:(float)pBlankSec;
- (SentInfo*)getPrevSenFromBlankSec:(float)pBlankSec;

- (void)printAllSen;
- (void)printSummary:(NSInteger)pNammigNum;
- (float)getFrmAmtPer1Sec;

@property (nonatomic, retain) NSMutableDictionary* dictOfSent;
@property (nonatomic, assign) Type_DirectionToFind directionTypeToFind;

@property (nonatomic, retain) UIImage* imgTotGraphDigita;
@property (nonatomic, retain) UIImage* imgTotGraphAnalog;
@property (nonatomic, retain) UIImage* imgTotGraphSenten;

@property (nonatomic, assign) float staSecOfTotSoundGraph;
@property (nonatomic, assign) float endSecOfTotSoundGraph;

@property (nonatomic, assign) BOOL isNomoreRightSen;
@property (nonatomic, assign) BOOL isNomoreLeftSen;

@property (nonatomic, copy) NSString* mediaPath;
@property (nonatomic, copy) NSString* audioPath;
@property (nonatomic, assign) float audioDura;
@property (nonatomic, assign) float secOfCurrPlaying;

@property (nonatomic, assign) BOOL isProcessingNow;
@property (nonatomic, assign) BOOL isConvertedComplete;

@end
