//
//  SentenceFinder.h
//  repeater
//
//  Created by admin on 2016. 1. 25..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SubTitle.h"

@interface SentenceFinder : NSObject

+(SentenceFinder*)shared;

/*----------------
 GET SORTED ARRAY
 -----------------*/
- (NSArray*)sortedKeysFrom:(NSMutableDictionary*)pDict;

/*-------------------------
 CLEAR SENTENCE DICTIONARY
 --------------------------*/
-(void)clearSentenceDict;

-(float)levelOfSound:(UIImage*)pImage rect:(CGRect)pRect;

/*------------------
 CREATE SOUND IMAGE
 -------------------
-(void)createSoundImage:(NSString*)pAudioPath
                 staSec:(float)pStaSec
                 endSec:(float)pEndSec
              imgHeight:(float)pImgHeight
              imgAnalog:(UIImage**)pImgAnalog
              imgDigita:(UIImage**)pImgDigita;*/

/*---------------------------------------------------
 DRAW SENTENCE LAYER ON SPECTRUM IMAGE BY SUBTITLE
 ----------------------------------------------------*/
-(NSMutableDictionary*)findSentenceNDraw:(UIImage*)pImgDigitaOnly
                subTitle:(SubTitle*)pSubTitle
           audioDuration:(float)pAudioDuration
                interval:(float)pInterval
          startSecToFind:(float)pStartSecToFind
            endSecToFind:(float)pEndSecToFind;

/*---------------------------------------------------
 DRAW SENTENCE LAYER ON SPECTRUM IMAGE BY SPECTRUM
 ----------------------------------------------------*/
-(NSMutableDictionary*)findSentenceNDraw:(UIImage*)pImgDigitaOnly
           audioDuration:(float)pAudioDuration
                interval:(float)pInterval
          startSecToFind:(float)pStaSecToFind
            endSecToFind:(float)pEndSecToFind;

/*------------------------------------
 DRAW SENTANCE LAYER ON SPECTRUM IMAGE
 -------------------------------------*/
-(UIImage*)drawSentence:(UIImage*)pImgDigitaOnly
          audioDuration:(float)pAudioDuration
         startSecToFind:(float)pStaSecToFind
           endSecToFind:(float)pEndSecToFind
             dictOfSens:(NSDictionary*)pDictOfSens;

/*-(void)startSecNEndSecOfSentenceByIndex:(NSInteger)pIndex
                                 staSec:(float*)refStaSec
                                 endSec:(float*)refEndSec;*/
/*-(void)indexOfSenByAnySec:(float)pAnySec
                    index:(NSInteger*)refIndex
                    isInBlank:(BOOL*)refIsInBlank;*/

/*-(float)startSecOfCurrSentWithAnySec:(float)pAnySec
                              endSec:(float*)refEndSec
                               index:(NSInteger*)refIndex
                             isBlank:(BOOL*)refIsBlank;*/
/*-(float)endSecOfCurrSentWithAnySec:(float)pAnySec;*/

/*-(float)startSecOfNextSentWithAnySec:(float)pAnySec;*/
//-(float)startSecOfPrevSentWithAnySec:(float)pAnySec;

//-(float)startSecOfCurrSentWithEndSec:(float)pEndSec;
//-(float)startSecOfCurrSentWithEndFrame:(int)pEndFrame;
//-(float)startSecOfNextSentWithEndFrame:(int)pEndFrame;

//@property (nonatomic, retain) NSMutableDictionary* dictStartSec2EndSec;
//@property (nonatomic, retain) NSMutableDictionary* dictEndSec2StartSec;
//@property (nonatomic, retain) NSMutableDictionary* dictEndFrame2StartSec;

@property (nonatomic, assign) BOOL isOnProcessing;
@property (nonatomic, assign) BOOL isQueFull;
@property (nonatomic, assign) BOOL isOnFindingIndex;

@end
