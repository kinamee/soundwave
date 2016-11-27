//
//  SentGroup.m
//  repeater
//
//  Created by admin on 2016. 5. 19..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "SentGroup.h"
#import "AudioFromVideo.h"
#import "UIImage+Category.h"
#import "VCMoviePlayer.h"
#import "VCLoading.h"
#import "TblContFileHelper.h"
#import "Config.h"
#import "KSPath.h"

static SentGroup* instance = nil;

@implementation SentGroup

+(SentGroup*)shared {
    if (instance == nil) {
        instance = [[SentGroup alloc] init];
        instance.dictOfSent = [[NSMutableDictionary alloc] init];
    }
    return instance;
}

- (void)clear {
    [self.dictOfSent removeAllObjects];
    
    self.imgTotGraphSenten = nil;
    self.imgTotGraphAnalog = nil;
    self.imgTotGraphDigita = nil;
    
    self.isNomoreLeftSen  = NO;
    self.isNomoreRightSen = NO;
    
    self.isProcessingNow = NO;
}

/*------------------
 병합된 문장 인덱스 검사
 -------------------*/
- (BOOL)checkIndexOfAllSen
{
    if ([self countOfallSen] == 0)
        return YES;
    
    SentInfo* sen;
    for (NSInteger i = 0; i < self.dictOfSent.count; i++) {
        sen = [self getByIndex:i];
        if (sen == nil) {
            NSLog(@"인덱스 오류 발생");
            return NO;
        }
        if (i != sen.index) {
            NSLog(@"인덱스 오류 발생");
            return NO;
        }
        if (sen.staFrame < 0)
        {
            NSLog(@"프레임 오류 발생");
            return NO;
        }
    }
    
    sen = [self getFirstSen];
    if (sen.index != 0) {
        NSLog(@"인덱스 오류 발생 시작점이 ZERO 가 아님");
        return NO;
    }
    
    sen = [self getLastSen];
    if (sen.index != (self.dictOfSent.count -1)) {
        NSLog(@"인덱스 오류 발생 끝점이 전체카운트와 차이가 발생");
        return NO;
    }
    
    return YES;
}

/*----------------------------------
 기존 문장그룹에 새로 만든 문장그룹을 병합한다
 -----------------------------------*/
- (void)mergeSenGroup:(NSDictionary*)pTempSenGroup {
    
    if (pTempSenGroup.count == 0) {
        //NSLog(@"새로 만들어진 문장 개수가 0 이므로 문장병합 안함");
        return;
    }
    
    //NSLog(@"병합 전 문장 총개수(%li), 추가할 문장개수(%li)", [self countOfallSen], pTempSenGroup.count);
    if (self.directionTypeToFind == DIRECTION_NEW) {
        self.dictOfSent = [[NSMutableDictionary alloc] initWithDictionary:pTempSenGroup];
    }
    
    if (self.directionTypeToFind == DIRECTION_RIGHT) {
        for (NSInteger i = 0; i < pTempSenGroup.count; i++) {
            SentInfo* sen = [pTempSenGroup valueForKey:@(i).description];
            [self add:sen];
        }
    }
    if (self.directionTypeToFind == DIRECTION_LEFT) {
        for (NSInteger i = self.dictOfSent.count -1; i > -1 ; i--) {
            SentInfo* sen = [self.dictOfSent valueForKey:@(i).description];
            NSInteger preIndex = sen.index;
            NSInteger newIndex = preIndex + pTempSenGroup.count;
            
            sen.index = newIndex;
            [self.dictOfSent setValue:sen forKey:@(newIndex).description];
            [self.dictOfSent removeObjectForKey:@(preIndex).description];
        }
        
        for (NSInteger i = 0; i < pTempSenGroup.count; i++) {
            SentInfo* sen = [pTempSenGroup valueForKey:@(i).description];
            [self.dictOfSent setValue:sen forKey:@(i).description];
        }
    }
    
    //NSLog(@"-");
    //NSLog(@"문장 병합작업 끝");
    BOOL hasNoIndexError = [self checkIndexOfAllSen];
    //NSLog(@"문장 정합성 검사결과: %@", (hasNoIndexError)?@"정상":@"오류");
    //NSLog(@"병합 후 문장 총개수(%li)", [self countOfallSen]);
    
    if (hasNoIndexError == NO) {
        NSLog(@"-");
        NSLog(@"문장 인덱스 정합성 오류발생");
        //NSLog(@"-");
        //[self printAllSen];
        [self printSummary:0];
    }
}

- (void)add:(SentInfo*)pSen {
    pSen.index = self.dictOfSent.count;
    [self.dictOfSent setValue:pSen forKey:@(pSen.index).description];
}

- (void)deleteLastSen {    
    [self.dictOfSent removeObjectForKey:@([self getLastSen].index).description];
}

- (void)printAllSen {
    for (int i = 0; i < self.dictOfSent.count; i++) {
        [[self getByIndex:i] printLog];
        NSLog(@"-");
    }
}

- (void)deleteAfterSec:(float)pSec {
    NSString* secToFind = [NSString stringWithFormat:@"%.1f", pSec];
    
    SentInfo* senInfo = [self getBySecond:secToFind.floatValue nextIfInBlank:YES];
    
    NSInteger indexToDel = senInfo.index;
    while ((self.dictOfSent.count - 1) >= indexToDel)
        [self deleteLastSen];
}

- (NSInteger)countOfallSen {
    return self.dictOfSent.count;
}

- (SentInfo*)getByIndex:(NSInteger)pIndex {
    SentInfo* senByIndex = [self.dictOfSent valueForKey:@(pIndex).description];
    return senByIndex;
}

- (BOOL)isEmpty {
    return (self.dictOfSent.count == 0);
}

- (BOOL)isNotEmpty {
    return ([self isEmpty] == NO);
}

- (SentInfo*)getFirstSen {
    if ([self isEmpty])
        return nil;
    
    return [self getByIndex:0];
}

- (SentInfo*)getLastSen {
    if ([self isEmpty])
        return nil;
    
    return [self.dictOfSent valueForKey:@(self.dictOfSent.count - 1).description];
}

- (SentInfo*)getBySecond:(float)pAnySec {
    
    for (NSInteger i = 0; i < self.dictOfSent.count; i++) {
        SentInfo* senInfo = [self getByIndex:i];
        if ([senInfo isBeingInSec:pAnySec])
            return senInfo;
    }
    
    return nil;
}

- (SentInfo*)getBySecond:(float)pAnySec nextIfInBlank:(BOOL)pNextSenIfInBlank {
    SentInfo* sen = [self getBySecond:pAnySec];
    if (sen == nil)
        if (pNextSenIfInBlank)
            sen = [self getNextSenFromBlankSec:pAnySec];
                if (sen == nil)
                    sen = [self getLastSen];
    
    if (sen == nil) {
        NSLog(@"문장찾기 결과 없음 - 찾는시간(%.2f)", pAnySec);
        [self printAllSen];
    }
    
    return sen;
}

- (SentInfo*)getBySecond:(float)pAnySec prevIfInBlank:(BOOL)pPrevSenIfInBlank {
    SentInfo* sen = [self getBySecond:pAnySec];
    if (sen == nil)
        if (pPrevSenIfInBlank)
            sen = [self getPrevSenFromBlankSec:pAnySec];
    if (sen == nil)
        sen = [self getFirstSen];
    
    if (sen == nil) {
        NSLog(@"문장찾기 결과 없음 - 찾는시간(%.2f)", pAnySec);
        [self printAllSen];
    }
    
    return sen;
}

- (SentInfo*)getNextSenFromBlankSec:(float)pBlankSec {
    NSString* secToFind = [NSString stringWithFormat:@"%.1f", pBlankSec];
    
    for (NSInteger i = 0; i < self.dictOfSent.count; i++) {
        SentInfo* senInfo = [self getByIndex:i];
        if (senInfo.staSec > secToFind.floatValue)
            return senInfo;
    }
    
    return nil;
}

- (SentInfo*)getPrevSenFromBlankSec:(float)pBlankSec {
    NSString* secToFind = [NSString stringWithFormat:@"%.1f", pBlankSec];
    
    for (NSInteger i = (self.dictOfSent.count - 1); i > -1; i--) {
        SentInfo* senInfo = [self getByIndex:i];
        if (senInfo.endSec < secToFind.floatValue)
            return senInfo;
    }
    
    return nil;
}

/*---------------------------
 우측방향으로 문장 만들기 쓰레드 이용
 ----------------------------*/
- (void)createSentGroupInThread:(NSString*)pMediaPath
                      audioPath:(NSString*)pAudioPath
                           audioDura:(float)pAudioDura
                             direction:(Type_DirectionToFind)pDirection
                               currSec:(float)pCurrSec {
    self.mediaPath = pMediaPath;
    self.audioPath = pAudioPath;
    self.audioDura = pAudioDura;
    self.secOfCurrPlaying = pCurrSec;
    self.directionTypeToFind = pDirection;
    
    NSThread *thread;
    if (pDirection == DIRECTION_RIGHT) {
        thread = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(createSentGroupToRightByThread)
                                           object:nil];
    }
    if (pDirection == DIRECTION_LEFT) {
        thread = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(createSentGroupToLeftByThread)
                                           object:nil];
    }
    if (pDirection == DIRECTION_NEW) {
        thread = [[NSThread alloc] initWithTarget:self
                                         selector:@selector(createSentGroupTobeNewByThread)
                                           object:nil];
    }
    [thread start];
}

/*-------------------
 새롭게 문장 만들기 쓰레드
 --------------------*/
- (void)createSentGroupTobeNewByThread {
    
    [self createSentGroup:self.mediaPath
                audioPath:self.audioPath
                audioDura:self.audioDura
                direction:DIRECTION_NEW
                  currSec:self.secOfCurrPlaying];
}

/*---------------------------
 좌측방향으로 문장 만들기 쓰레드
 ----------------------------*/
- (void)createSentGroupToLeftByThread {
    
    [self createSentGroup:self.mediaPath
                audioPath:self.audioPath
                audioDura:self.audioDura
                direction:DIRECTION_LEFT
                  currSec:self.secOfCurrPlaying];
}

/*---------------------------
 우측방향으로 문장 만들기 쓰레드
 ----------------------------*/
- (void)createSentGroupToRightByThread {
    
    [self createSentGroup:self.mediaPath
                audioPath:self.audioPath
                audioDura:self.audioDura
                direction:DIRECTION_RIGHT
                  currSec:self.secOfCurrPlaying];
}

- (BOOL)isCompleteFindAllSen {
    return (self.isNomoreRightSen && self.isNomoreLeftSen);
}

/*--------------------------------------------------------------
 기존 문장에 덧붙여 특정 방향의 문장들을 만든다 또는 특정 위치에서 새롭게 제작한다
 ---------------------------------------------------------------*/
- (void)createSentGroup:(NSString*)pMediaPath
              audioPath:(NSString*)pAudioPath
              audioDura:(float)pTotDuration
              direction:(Type_DirectionToFind)pDirection
                currSec:(float)pCurrSec
{
    if (self.isProcessingNow) {
        //NSLog(@"문장 분석작업 진행중에 요청들어옴");
        return;
    }
    
    // 작업 시작됨을 알림
    self.isProcessingNow = YES;
    
    self.mediaPath = pMediaPath;
    self.audioPath = pAudioPath;
    self.audioDura = pTotDuration;
    self.directionTypeToFind = pDirection;
    self.secOfCurrPlaying = pCurrSec;
    
    // 지금까지 병합된 양이 너무 많다면 클리어하자 30분 임계
    float mergedDura = (self.endSecOfTotSoundGraph - self.staSecOfTotSoundGraph);
    if (mergedDura > (60 * 60 * 2))
        pDirection = DIRECTION_NEW;
    
    // 1. SET TIME TO FIND
    float staSecToFind = -1.0;
    float endSecToFind = -1.0;
    
    if (pDirection == DIRECTION_NEW) {
        [self clear];
        staSecToFind = pCurrSec - 40.0;
        endSecToFind = pCurrSec + 40.0;
    }
    
    // 이미 모든 문장이 분석완료 되었다면..?
    if ([self isCompleteFindAllSen]) {
        //NSLog(@"-");
        //NSLog(@"모든 문장 분석완료");
        //NSLog(@"전체 분석 완료길이: %.2f", self.endSecOfTotSoundGraph - self.staSecOfTotSoundGraph);
        //NSLog(@"전체 분석 요청길이: %.2f", pTotDuration);
        //[self printSummary:0];
        self.isProcessingNow = NO;
        return;
    }
    
    if (pDirection == DIRECTION_RIGHT) {
        
        if (self.isNomoreRightSen) {
            self.isProcessingNow = NO;
            return;
        }
        staSecToFind = self.endSecOfTotSoundGraph;
        endSecToFind = staSecToFind + 80.0;
    }
    
    if (pDirection == DIRECTION_LEFT) {
        
        if (self.isNomoreLeftSen) {
            self.isProcessingNow = NO;
            return;
        }
        endSecToFind = self.staSecOfTotSoundGraph;
        staSecToFind = endSecToFind - 80;
    }
    
    if (staSecToFind < 0) {
        staSecToFind = 0;
        self.isNomoreLeftSen = YES;
    }
    if (endSecToFind > pTotDuration) {
        endSecToFind = pTotDuration;
        self.isNomoreRightSen = YES;
    }
    
    // 시작점 끝점 계산상의 오류가 있다..?
    // 더 분석할 문장이 없다는 의미가 된다
    if (staSecToFind == endSecToFind) {
        self.isProcessingNow = NO;
        return;
    }
    
    //NSLog(@"문장찾기 시작(%@)(%.2f) 종료(%@)(%.2f)",
    //      [[Config shared] timeFormatted:staSecToFind], staSecToFind,
    //      [[Config shared] timeFormatted:endSecToFind], endSecToFind);
    
    /*------------------------------------
     1 - 정해진 간격만큼 비디오에서 오디오를 만들자
     -------------------------------------*/
    NSString* extention = [self.mediaPath pathExtension].uppercaseString;
    if ([extention isEqualToString:@"MP4"] ||
        [extention isEqualToString:@"MOV"])
    {
        // 임시 오디오 파일 지우고 다시 만든다
        if ([[KSPath shared] isExistPath:self.audioPath])
            [[KSPath shared] deleteFile:self.audioPath];
        [[AudioFromVideo shared] conversionMP4ToM4A:self.mediaPath
                                       destFM4APath:self.audioPath
                                             staSec:staSecToFind
                                             endSec:endSecToFind];
    }
    
    /*----------------------------------------------
     2 - 정해진 간격만큼 잘래낸 오디오로부터 스펙트럼 이미지 제작
     -----------------------------------------------*/
    float heightOfImage = [VCMoviePlayer shared].imgSpectrum.frame.size.height;
    UIImage* imgPartDigita = nil;
    UIImage* imgPartAnalog = nil;
    
    if ([extention isEqualToString:@"MP4"] ||
        [extention isEqualToString:@"MOV"])
    {
        imgPartAnalog = [[GraphFromAudio shared]
                         renderPNGAudioPictogramLogForAsset:self.audioPath
                         height:heightOfImage
                         simplePNG:&imgPartDigita];
    }
    
    /*------------------------------------------------------------------------
     오디오 파일은 제작된 임시파일이 없기 때문에 오디오로부터 직접 필요한 부분만큼 스펙트럼을 만든다
     -------------------------------------------------------------------------*/
    if ([extention isEqualToString:@"M4A"] ||
        [extention isEqualToString:@"MP3"])
    {
        imgPartAnalog = [[GraphFromAudio shared]
                         renderPNGAudioPictogramLogForAsset:self.audioPath
                         height:heightOfImage
                         staSec:staSecToFind endSec:endSecToFind simplePNG:&imgPartDigita];
    }
    
    //NSString* imgPath = [NSString stringWithFormat:@"%@/image.png", [[KSPath shared] documentPath]];
    //[UIImagePNGRepresentation(imgPartDigita) writeToFile:imgPath atomically:YES];
    //사운드스펙트럼이미지저장해보자!
    
    /*-------------------------------
     3 - 스펙트럼 이미지를 이용해 문장 만들기
     --------------------------------*/
    float minimumSentenceLen = [[Config shared] getMinimumSenSec];
    NSDictionary* dictOfNewSens;
    if ([SubTitle shared].isLoaded)
    {
        dictOfNewSens = [[SentenceFinder shared] findSentenceNDraw:imgPartDigita
                                          subTitle:[SubTitle shared]
                                     audioDuration:pTotDuration
                                          interval:minimumSentenceLen
                                    startSecToFind:staSecToFind
                                      endSecToFind:endSecToFind];
    } else
    {
        dictOfNewSens = [[SentenceFinder shared] findSentenceNDraw:imgPartDigita
                                     audioDuration:pTotDuration
                                          interval:minimumSentenceLen
                                    startSecToFind:staSecToFind
                                      endSecToFind:endSecToFind];
    }
    //NSLog(@"오디오에서 문장 추출 끝");
    
    /*----------------------------------
     4 - 만들어진 문장을 이용해 문장 이미지 제작
     -----------------------------------*/
    UIImage* imgPartSenten = [[SentenceFinder shared] drawSentence:imgPartDigita
                                                     audioDuration:pTotDuration
                                                    startSecToFind:staSecToFind
                                                      endSecToFind:endSecToFind
                                                        dictOfSens:dictOfNewSens];
    // 새로만들어진 문장을 기존문장들에 병합
    [self mergeSenGroup:dictOfNewSens];
    
    /*------------------------------
     세가지 이미지 모두 앞뒤 공백을 잘라낸다
     -------------------------------*/
    SentInfo* senFirs = [dictOfNewSens objectForKey:@"0"];
    SentInfo* senLast = [dictOfNewSens objectForKey:@(dictOfNewSens.count -1).description];
    
    // 기본적으로는 찾아진 문장만큼 병합한다
    CGRect cropRect = CGRectMake(senFirs.staFrame, 0.0,
                                 (senLast.endFrame - senFirs.staFrame), // 끝프레임이 아니라 길이!
                                 imgPartSenten.size.height);
    
    if (pDirection == DIRECTION_NEW) {
        
        self.staSecOfTotSoundGraph = senFirs.staSec;
        self.endSecOfTotSoundGraph = senLast.endSec;
        
        if (endSecToFind == pTotDuration) {
            cropRect = CGRectMake(senFirs.staFrame, 0.0,
                                  imgPartSenten.size.width - senFirs.staFrame,
                                  imgPartSenten.size.height);
            self.endSecOfTotSoundGraph = pTotDuration;
        }
        if (staSecToFind == 0) {
            cropRect = CGRectMake(0.0, 0.0,
                                  senLast.endFrame, imgPartSenten.size.height);
            self.staSecOfTotSoundGraph = 0.0;
        }
        
        if (dictOfNewSens.count == 0) {
            self.staSecOfTotSoundGraph = staSecToFind;
            self.endSecOfTotSoundGraph = endSecToFind;
            
            cropRect = CGRectMake(0.0, 0.0,
                                  imgPartSenten.size.width, imgPartSenten.size.height);
        }
        
        if ((staSecToFind == 0) && (endSecToFind == pTotDuration)) {
            cropRect = CGRectMake(0, 0.0,
                                  imgPartSenten.size.width,
                                  imgPartSenten.size.height);
        }
    }
    
    if (pDirection == DIRECTION_RIGHT) {
        
        cropRect = CGRectMake(0.0, 0.0,
                              senLast.endFrame, imgPartSenten.size.height);
        self.endSecOfTotSoundGraph = senLast.endSec;
        
        if (endSecToFind == pTotDuration) {
            cropRect = CGRectMake(0.0, 0.0,
                                  imgPartSenten.size.width, imgPartSenten.size.height);
            self.endSecOfTotSoundGraph = pTotDuration;
        }
        
        if (dictOfNewSens.count == 0) {
            self.endSecOfTotSoundGraph = endSecToFind;
            cropRect = CGRectMake(0.0, 0.0,
                                  imgPartSenten.size.width, imgPartSenten.size.height);
        }
    }
    if (pDirection == DIRECTION_LEFT) {
        
        cropRect = CGRectMake(senFirs.staFrame, 0.0,
                              imgPartSenten.size.width - senFirs.staFrame,
                              imgPartSenten.size.height);
        self.staSecOfTotSoundGraph = senFirs.staSec;
        
        if (staSecToFind == 0) {
            cropRect = CGRectMake(0.0, 0.0,
                                  imgPartSenten.size.width, imgPartSenten.size.height);
            self.staSecOfTotSoundGraph = 0.0;
        }
        
        if (dictOfNewSens.count == 0) {
            self.staSecOfTotSoundGraph = staSecToFind;
            cropRect = CGRectMake(0.0, 0.0,
                                  imgPartSenten.size.width, imgPartSenten.size.height);
        }
    }
    
    imgPartDigita = [imgPartDigita crop:cropRect];
    imgPartAnalog = [imgPartAnalog crop:cropRect];
    imgPartSenten = [imgPartSenten crop:cropRect];
    
    /*----------------------------------
    5 - 사운드 스펙트럼 이미지 기존 이미지에 병합
     -----------------------------------*/
    if (pDirection == DIRECTION_NEW) {
        // 처음 제작이라면
        self.imgTotGraphAnalog = [UIImage imageWithData:UIImagePNGRepresentation(imgPartAnalog)];
        self.imgTotGraphDigita = [UIImage imageWithData:UIImagePNGRepresentation(imgPartDigita)];
        self.imgTotGraphSenten = [UIImage imageWithData:UIImagePNGRepresentation(imgPartSenten)];
    }
    if (pDirection == DIRECTION_RIGHT) {
        
        self.imgTotGraphAnalog = [self.imgTotGraphAnalog mergeToRight:imgPartAnalog];
        self.imgTotGraphDigita = [self.imgTotGraphDigita mergeToRight:imgPartDigita];
        self.imgTotGraphSenten = [self.imgTotGraphSenten mergeToRight:imgPartSenten];
    }
    if (pDirection == DIRECTION_LEFT) {
        
        self.imgTotGraphAnalog = [self.imgTotGraphAnalog mergeToLeft:imgPartAnalog];
        self.imgTotGraphDigita = [self.imgTotGraphDigita mergeToLeft:imgPartDigita];
        self.imgTotGraphSenten = [self.imgTotGraphSenten mergeToLeft:imgPartSenten];
    }
    
    /*NSLog(@"문장 병합 이후에 파악한 초당 프레임");
    NSLog(@"문장 병합 후 초당 프레임 (부분): %.2f", (imgPartDigita.size.width)/(senLast.endSec - senFirs.staSec));
    NSLog(@"문장 병합 후 초당 프레임 (전체): %.2f", (self.imgTotGraphDigita.size.width)/
          (self.endSecOfTotSoundGraph - self.staSecOfTotSoundGraph));
    NSLog(@"문장 병합 후 이미지 길이 (부분): %.2f", imgPartDigita.size.width);
    NSLog(@"문장 병합 후 이미지 길이 (전체): %.2f", self.imgTotGraphDigita.size.width);
    NSLog(@"문장 병합 후 시간 길이 (부분): %.2f", (senLast.endSec - senFirs.staSec));
    NSLog(@"문장 병합 후 시간 길이 (전체): %.2f", (self.endSecOfTotSoundGraph - self.staSecOfTotSoundGraph));
    NSLog(@"문장 병합 후 부분시간 시작(%.2f) 종료(%.2f)", staSecToFind, endSecToFind);
    NSLog(@"문장 병합 후 전체시간 시작(%.2f) 종료(%.2f)", self.staSecOfTotSoundGraph, self.endSecOfTotSoundGraph);
    NSLog(@"문장 병합 후 문장시간 시작(%.2f) 종료(%.2f)", senFirs.staSec, senLast.endSec);*/
    /*-----------------
     8 - 완료되었음을 알림
     ------------------*/
    self.isProcessingNow = NO;
    [self.delegate onCreateSenGroupComplete:self.imgTotGraphAnalog
                             totImageDigita:self.imgTotGraphDigita
                             totImageSenten:self.imgTotGraphSenten
                      staSecOfTotSoundGraph:self.staSecOfTotSoundGraph
                      endSecOfTotSoundGraph:self.endSecOfTotSoundGraph
                                    currSec:self.secOfCurrPlaying];
    
    /*-------------------------------------------
     발견된 문장이 없거나 2개 미만이면 다시한번 찾기 시도한다
     --------------------------------------------*/
    if ([self countOfallSen] < 2) {
        
        // 왜 중간지점에서 시작할 때는 플레이어에서 정확한 이미지 위치를 못찾을까..?
        if ((pDirection == DIRECTION_NEW) || (pDirection == DIRECTION_RIGHT)) {
            
            // NEW 일때 RIGHT 으로 가면..? 기존문장들이 지워지질 않잖아!
            // 하지만 NEW 인데 문장이 찾아지질 않았잖아..?
            
            NSLog(@"-");
            NSLog(@"발견된 문장이 없어서 다시 찾기 시도");
            [self createSentGroup:pMediaPath
                        audioPath:pAudioPath
                        audioDura:pTotDuration
                        direction:DIRECTION_RIGHT
                          currSec:endSecToFind];
        }
        if (pDirection == DIRECTION_LEFT) {
            
            NSLog(@"-");
            NSLog(@"발견된 문장이 없어서 다시 찾기 시도");
            [self createSentGroup:pMediaPath
                        audioPath:pAudioPath
                        audioDura:pTotDuration
                        direction:DIRECTION_LEFT
                          currSec:staSecToFind];
        }
    }
}

/*--------------------------
 현재까지 병합된 이미지들을 반환한다
 ---------------------------*/
- (void)getSentenceImageTotAmt:(UIImage**)pAnalogImg
                     digitaImg:(UIImage**)pDigitaImg
                     sentenImg:(UIImage**)pSentenImg
{
    *pAnalogImg = [UIImage imageWithData:UIImagePNGRepresentation(self.imgTotGraphAnalog)];
    *pDigitaImg = [UIImage imageWithData:UIImagePNGRepresentation(self.imgTotGraphDigita)];
    *pSentenImg = [UIImage imageWithData:UIImagePNGRepresentation(self.imgTotGraphSenten)];
}

/*---------------------------------------
 현재시간을 기준으로 양역 40초 분량의 이미지를 반환
 ----------------------------------------*/
- (void)getSentImageIn80Sec:(float)pTotDuration
                 currSec:(float)pCurrSec
               analogImg:(UIImage**)pAnalogImg
               digitaImg:(UIImage**)pDigitaImg
               sentenImg:(UIImage**)pSentenImg {
    
    // 전체 문장의 시작시간과 전체 문장의 이미지가 매칭된다.
    // 따라서 현재시간에서 전체문장의 시작시간의 거리만큼
    // 프레임의 크기를 구하고, 그 프레임을 기준으로 양쪽으로 40초씩을 잘라낸다.
    
    float distanceSeco = pCurrSec - self.staSecOfTotSoundGraph;
    float currentFrame = distanceSeco * [self getFrmAmtPer1Sec];
    
    // 40초에 해당하는 프레임 수
    float frmAmt40Seco = 40 * [self getFrmAmtPer1Sec];
    
    
    float staFrameToCut = currentFrame - frmAmt40Seco;
    float endFrameToCut = currentFrame + frmAmt40Seco;
    
    CGRect rectToCrop = CGRectMake(staFrameToCut, 0,
                                    (endFrameToCut - staFrameToCut),
                                    self.imgTotGraphDigita.size.height);
    
    //*pAnalogImg = [self.imgTotGraphAnalog crop:rectToCrop];
    *pDigitaImg = [self.imgTotGraphDigita crop:rectToCrop];
    *pSentenImg = [self.imgTotGraphSenten crop:rectToCrop];
    *pAnalogImg = [self.imgTotGraphAnalog crop:rectToCrop];    
}

/*----------------------------------
 문장찾기 시도 중 한 문장이 찾아졌을 때 호출
 -----------------------------------*/
- (void)onFoundSent:(float)pStaSec
             endSec:(float)pEndSec
           staFrame:(NSInteger)pStaFrame
           endFrame:(NSInteger)pEndFrame
{
    NSString* staSecStr = [NSString stringWithFormat:@"%.1f", pStaSec];
    NSString* endSecStr = [NSString stringWithFormat:@"%.1f", pEndSec];
    
    SentInfo* senInfo = [[SentInfo alloc] init];
    senInfo.staSec = staSecStr.floatValue;
    senInfo.endSec = endSecStr.floatValue;
    senInfo.staFrame = pStaFrame;
    senInfo.endFrame = pEndFrame;
    
    [self add:senInfo];
}

/*----------------
 초당 프레임 수 구하기
 -----------------*/
- (float)getFrmAmtPer1Sec {
    float frmAmtPer1Sec = (self.imgTotGraphDigita.size.width) /
    (self.endSecOfTotSoundGraph - self.staSecOfTotSoundGraph);
    return frmAmtPer1Sec;
}

/*----------------
 프레임당 초 수 구하기
 -----------------*/
- (float)getSecAmtPer1Frm {
    float secAmtPer1Frm = (self.endSecOfTotSoundGraph - self.staSecOfTotSoundGraph) /
    (self.imgTotGraphDigita.size.width);
    return secAmtPer1Frm;
}

- (void)printSummary:(NSInteger)pNammigNum {
    /*NSLog(@"-");
    NSLog(@"문장그룹 요약");
    NSLog(@"지난분석 방향: %@", ((self.directionTypeToFind == DIRECTION_NEW)?@"NEW":@"RIGHT_OR_LEFT"));
    NSLog(@"문장개수 (%li)", [self countOfallSen]);
    NSLog(@"분석된 문장의 전체 시작시간(%@)(%.2f) 종료시간(%@)(%.2f)",
          [[Config shared] timeFormatted:self.staSecOfTotSoundGraph], self.staSecOfTotSoundGraph,
          [[Config shared] timeFormatted:self.endSecOfTotSoundGraph], self.endSecOfTotSoundGraph);
    NSLog(@"-");
    NSLog(@"초당 프레임 수: %.2f", [self getFrmAmtPer1Sec]);
    NSLog(@"프레임당 초 수: %.2f", [self getSecAmtPer1Frm]);*/
    
    /* 이미지 저장해보자 확인용
    NSString* extName = [NSString stringWithFormat:@".%li.png", pNammigNum];
    
    NSString* fileToSav;
    NSString* audioPath = [VCMoviePlayer shared].audioFilePath;
    fileToSav = [audioPath stringByAppendingString:@".TA"];
    fileToSav = [fileToSav stringByAppendingString:extName];
    [UIImagePNGRepresentation(self.imgTotGraphAnalog) writeToFile:fileToSav atomically:YES];
    fileToSav = [audioPath stringByAppendingString:@".TD"];
    fileToSav = [fileToSav stringByAppendingString:extName];
    [UIImagePNGRepresentation(self.imgTotGraphDigita) writeToFile:fileToSav atomically:YES];
    fileToSav = [audioPath stringByAppendingString:@".TS"];
    fileToSav = [fileToSav stringByAppendingString:extName];
    [UIImagePNGRepresentation(self.imgTotGraphSenten) writeToFile:fileToSav atomically:YES];
     */
}

@end
