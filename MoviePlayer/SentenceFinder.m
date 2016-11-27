//
//  SentenceFinder.m
//  repeater
//
//  Created by admin on 2016. 1. 25..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "SentenceFinder.h"
#import "UIImage+Category.h"
#import "AudioFromVideo.h"
#import "KSPath.h"
#import "Config.h"
#import "SentGroup.h"
#import "SentInfo.h"

#if TARGET_IPHONE_SIMULATOR
    #define BCOLOR_LEV (0.0001)
#elif TARGET_OS_IPHONE
    #define BCOLOR_LEV (0.0001)
#else
    #define BCOLOR_LEV (0.0001)
#endif

static SentenceFinder* instance = nil;

@implementation SentenceFinder

+(SentenceFinder*)shared
{
    if (instance == nil) {
        instance = [[SentenceFinder alloc] init];
        /*instance.dictStartSec2EndSec = [[NSMutableDictionary alloc] init];
        instance.dictEndSec2StartSec = [[NSMutableDictionary alloc] init];
        instance.dictEndFrame2StartSec = [[NSMutableDictionary alloc] init];*/
    }
    return instance;
}

/*-------------------------
 CLEAR SENTENCE DICTIONARY
 --------------------------*/
-(void)clearSentenceDict {
    /*[self.dictStartSec2EndSec removeAllObjects];
    [self.dictEndSec2StartSec removeAllObjects];
    [self.dictEndFrame2StartSec removeAllObjects];*/
    [[SentGroup shared] clear];
    
    self.isOnProcessing = NO;
    self.isQueFull = NO;
}

-(float)levelOfSound:(UIImage*)pImage rect:(CGRect)pRect
{
    CGPoint pPT = CGPointMake(pRect.origin.x, (pImage.size.height / 2));
    UIColor* colorAt = [pImage colorAtPoint:pPT];
    CGFloat r, g, b, alpha;
    [colorAt getRed: &r green: &g blue: &b alpha: &alpha];
    // NSLog(@"COLOR-AT:(%f,%f) R(%f) G(%f) B(%f)", pPT.x, pPT.y, r, g, b);
    
    // RETURN BLUE COLOER LEVEL;
    return b;
}

/*-----------------------------
 CONVERT FRAME AMT TO SEC AMT
 EX) 80 FRM -> 21.324 SEC
 ------------------------------*/
-(float)frameAmtToSecAmt:(UIImage*)pTotalImage audioDuration:(float)pAudioDuration
             frameAmt:(int)pFrameAmt
{
    float numberOfFramesPerOneSecond = pTotalImage.size.width / pAudioDuration;
    return pFrameAmt * numberOfFramesPerOneSecond;
}

/*--------------------------------------
 MAKE SURE CURRENT FRAME IS SOUND PERIO
 ---------------------------------------*/
-(BOOL)isInSentence:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // GET SOUND LEVEL BY ONE PIXEL
    CGFloat bColor;
    CGRect rectToCheck = CGRectMake(1, 0, 1, pTotalImage.size.height);
    bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
    if (bColor > BCOLOR_LEV)
        return YES;
    return NO;
}

/*-------------------------------
 AMOUNT OF COMMING SOUND PERIOD
 --------------------------------*/
-(NSInteger)frameAmtOfBackCommingSentence:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FIND BLANK
    NSInteger blankNum = [self frameNumOfBackCommingBlank:pTotalImage currentFrame:pCurrentFrame];
    
    // FIND SOUND AFTER THE BLANK
    NSInteger prevSoundNum = [self frameNumOfBackCommingSentence:pTotalImage currentFrame:blankNum];
    
    // FIND BLANK AFTER THE SOUND
    blankNum = [self frameNumOfBackCommingBlank:pTotalImage currentFrame:prevSoundNum];
    
    return (prevSoundNum - blankNum);
}

/*-------------------------------
 AMOUNT OF COMMING SOUND PERIOD
 --------------------------------*/
-(NSInteger)frameAmtOfBackCommingBlank:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FIND SOUND
    NSInteger soundNum = [self frameNumOfBackCommingSentence:pTotalImage currentFrame:pCurrentFrame];
    
    // FIND BLANK AFTER THE SOUND
    NSInteger prevBlankNum = [self frameNumOfBackCommingBlank:pTotalImage currentFrame:soundNum];
    
    // FIND SOUND AFTER THE BLANK
    soundNum = [self frameNumOfCommingSentence:pTotalImage currentFrame:prevBlankNum];
    
    return (prevBlankNum - soundNum);
}

/*-------------------------------
 AMOUNT OF COMMING SOUND PERIOD
 --------------------------------*/
-(NSInteger)frameAmtOfCommingSentence:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FIND BLANK
    NSInteger blankNum = [self frameNumOfCommingBlank:pTotalImage currentFrame:pCurrentFrame];
    
    // FIND SOUND AFTER THE BLANK
    NSInteger nextSoundNum = [self frameNumOfCommingSentence:pTotalImage currentFrame:blankNum];
    
    // FIND BLANK AFTER THE SOUND
    blankNum = [self frameNumOfCommingBlank:pTotalImage currentFrame:nextSoundNum];
    
    return (blankNum - nextSoundNum);
}

/*-------------------------------
 AMOUNT OF COMMING SOUND PERIOD
 --------------------------------*/
-(NSInteger)frameAmtOfCommingBlank:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FIND SOUND
    NSInteger soundNum = [self frameNumOfCommingSentence:pTotalImage currentFrame:pCurrentFrame];
    
    // FIND BLANK AFTER THE SOUND
    NSInteger nextBlankNum = [self frameNumOfCommingBlank:pTotalImage currentFrame:soundNum];
    
    // FIND SOUND AFTER THE BLANK
    soundNum = [self frameNumOfCommingSentence:pTotalImage currentFrame:nextBlankNum];
    
    return (soundNum - nextBlankNum);
}

/*--------------------------------------
 GET FRAME NUMVER OF BACK-COMMING SOUND
 ---------------------------------------*/
-(NSInteger)frameNumOfBackCommingSentence:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FORE-WARD CHECK
    CGFloat bColor;
    float i = pCurrentFrame;
    while (i > 0)
    {
        i--;
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        
        if (bColor > BCOLOR_LEV)
            break;
    }
    return i;
}

/*--------------------------------------
 GET FRAME NUMVER OF BACK-COMMING BLANK
 ---------------------------------------*/
-(NSInteger)frameNumOfBackCommingBlank:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FORE-WARD CHECK
    CGFloat bColor;
    NSInteger i = pCurrentFrame;
    while (i > 0)
    {
        i--;
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        
        if (bColor < BCOLOR_LEV)
            break;
    }
    return i;
}

/*---------------------------------
 GET FRAME NUMVER OF COMMING BLANK
 ----------------------------------*/
-(NSInteger)frameNumOfCommingBlank:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FORE-WARD CHECK
    CGFloat bColor;
    NSInteger i = pCurrentFrame;
    while (i < pTotalImage.size.width)
    {
        i++;
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        
        if (bColor < BCOLOR_LEV)
            break;
    }
    return i;
}

/*---------------------------------
 GET FRAME NUMVER OF COMMING SOUND
 ----------------------------------*/
-(NSInteger)frameNumOfCommingSentence:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    // FORE-WARD CHECK
    CGFloat bColor;
    NSInteger i = pCurrentFrame;
    while (i < pTotalImage.size.width)
    {
        i++;
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        
        if (bColor > BCOLOR_LEV)
            break;
    }
    return i;
}

/*----------------------------------------
 GET AMOUNT OF SOUND FRAMES WITH POSITION
 -----------------------------------------*/
-(NSInteger)frameAmtOfCurrSentence:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    CGFloat bColor;
    NSInteger s = 0;
    
    // BACK-WARD CHECK
    NSInteger i = pCurrentFrame;
    while (i > 0) {
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        if (bColor < BCOLOR_LEV) {
            break;
        }
        i--;
        s++;
    }
    
    // FORE-WARD CHECK
    i = pCurrentFrame;
    while (i < pTotalImage.size.width) {
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        if (bColor < BCOLOR_LEV) {
            break;
        }
        i++;
        s++;
    }
    
    // SUBSTRACT DOUBLE COUTING
    return (s -1);
}

/*----------------------------------------
 GET AMOUNT OF BLANK FRAMES WITH POSITION
 -----------------------------------------*/
-(NSInteger)frameAmtOfCurrBlank:(UIImage*)pTotalImage currentFrame:(NSInteger)pCurrentFrame
{
    CGFloat bColor;
    NSInteger s = 0;
    
    // BACK-WARD CHECK
    NSInteger i = pCurrentFrame;
    while (i > 0) {
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        if (bColor > BCOLOR_LEV) {
            break;
        }
        i--;
        s++;
    }
    
    // FORE-WARD CHECK
    i = pCurrentFrame;
    while (i < pTotalImage.size.width) {
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        if (bColor > BCOLOR_LEV) {
            break;
        }
        i++;
        s++;
    }
    
    // SUBSTRACT DOUBLE COUTING
    return (s -1);
}

/*--------------------------------
 FIND FRAME THAT HAS LOWEST SOUND
 ---------------------------------*/
-(NSInteger)frameNumOfLowestSound:(UIImage*)pTotalImage
                 startFrame:(NSInteger)pStart
                   endFrame:(NSInteger)pEnd
{
    CGFloat bColor;
    CGFloat bColorOfLowest = 100;
    NSInteger frameNumOflowestSound = -1;
    
    // 가장 낮은 사운드 위치를 찾는다 (너무 긴 문장일 때 사용)
    for (NSInteger i = pStart; i < pEnd; i++) {
        CGRect rectToCheck = CGRectMake(i, 0, 1, pTotalImage.size.height);
        bColor = [self levelOfSound:pTotalImage rect:rectToCheck];
        if (bColor < bColorOfLowest) {
            bColorOfLowest = bColor;
            frameNumOflowestSound = i;
        }
    }
    return frameNumOflowestSound;
}

/*----------------------------------------------
 GET END FRAME AND START SEC FROM LAST SENTENCE
 -----------------------------------------------
-(void)getEndFrameStaSecOfLastSen:(float*)pEndFrame secStart:(float*)pSecStart
{
    if (self.dictEndFrame2StartSec.count == 0) {
        *pEndFrame = -1.0;
        *pSecStart = -1.0;
        return;
    }
    
    NSArray* arrSecs = [self.dictEndFrame2StartSec allKeys];
    NSArray* sortedArrEnds = [arrSecs sortedArrayUsingSelector:
                              @selector(localizedStandardCompare:)];
    
    NSString* endFrame = [sortedArrEnds objectAtIndex:sortedArrEnds.count -1];
    NSString* secStart = [self.dictEndFrame2StartSec objectForKey:endFrame];
    
    *pEndFrame = endFrame.floatValue;
    *pSecStart = secStart.floatValue;
}*/

/*-(NSInteger)getEndFrameNumOfLastSen
{
    if (self.dictEndFrame2StartSec.count == 0) {
        return -1;
    }
    
    NSArray* arrEndFrame = [self.dictEndFrame2StartSec allKeys];
    NSArray* sortedarrEndFrame = [arrEndFrame sortedArrayUsingSelector:
                              @selector(localizedStandardCompare:)];
    NSString* endFrame = [sortedarrEndFrame objectAtIndex:sortedarrEndFrame.count -1];
    return endFrame.integerValue;
}*/

/*--------------------------------------------
 GET START SEC AND END SEC FROM LAST SENTENCE
 ---------------------------------------------
-(void)getStaSecEndSecOfLastSen:(float*)pSecStart secEnd:(float*)pSecEnd
{
    if (self.dictStartSec2EndSec.count == 0) {
        *pSecStart = -1.0;
        *pSecEnd = -1.0;
        return;
    }
    
    NSArray* arrSecs = [self.dictStartSec2EndSec allKeys];
    NSArray* sortedArrSecs = [arrSecs sortedArrayUsingSelector:
                              @selector(localizedStandardCompare:)];
    
    NSString* startSec = [sortedArrSecs objectAtIndex:sortedArrSecs.count -1];
    NSString* endSec = [self.dictStartSec2EndSec objectForKey:startSec];
    
    *pSecStart = startSec.floatValue;
    *pSecEnd = endSec.floatValue;
}*/

/*---------------------------
 GET START TIME AND END TIME
 ----------------------------
-(void)getStartSecEndSecInTotalDict:(float*)pSecStart secEnd:(float*)pSecEnd
{
    if (self.dictStartSec2EndSec.count == 0) {
        *pSecStart = -1.0;
        *pSecEnd = -1.0;
        return;
    }
    
    NSArray* arrSecs = [self.dictStartSec2EndSec allKeys];
    NSArray* sortedArrSecs = [arrSecs sortedArrayUsingSelector:
                              @selector(localizedStandardCompare:)];
    
    NSString* startSec = [sortedArrSecs objectAtIndex:0];
    NSString* startSecOfLast = [sortedArrSecs objectAtIndex:sortedArrSecs.count -1];
    NSString* endSec = [self.dictStartSec2EndSec objectForKey:startSecOfLast];
    
    *pSecStart = startSec.floatValue;
    *pSecEnd = endSec.floatValue;
}

----------------------------------------------------
 GET LARSET INNEST BALNK FRAME NUMBER FROM DICTIONARY
 -----------------------------------------------------*/
-(NSInteger)startFrameNumOfLargestBlank:(NSMutableDictionary*)pDict
{
    // GET SORTED ARRAY
    NSArray *arrKeys = [self sortedKeysFrom:pDict];
    
    NSInteger currFrm = ((NSString*)[arrKeys objectAtIndex:0]).integerValue;
    float currLen = ((NSString*)[pDict valueForKey:@(currFrm).description]).floatValue;
    float largestLen = currLen;
    NSInteger largestFrm = currFrm;
    
    for (NSInteger i = 1; i < arrKeys.count; i++) {
        currFrm = ((NSString*)[arrKeys objectAtIndex:i]).integerValue;
        float length = ((NSString*)[pDict valueForKey:@(currFrm).description]).floatValue;
        if (largestLen < length) {
            largestLen = length;
            largestFrm = currFrm;
        }
    }
    
    //NSLog(@"가장 긴 공백기간 찾음 공백길이(%.2f)", largestLen);
    return largestFrm;
}

- (NSArray*)sortedKeysFrom:(NSMutableDictionary*)pDict
{
    if (!pDict)
        return nil;
    
    NSArray *arrKeys = [[pDict allKeys] sortedArrayUsingComparator: ^(id obj1, id obj2) {
        NSInteger n1 = [obj1 integerValue];
        NSInteger n2 = [obj2 integerValue];
        if (n1 > n2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (n1 < n2) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    return arrKeys;
}

/*-------------------------------------
 GET START FRAME OF LOWEST SOUND LEVEL
 --------------------------------------*/
-(NSInteger)startFrameNumOfLowestSound:(NSMutableDictionary*)pDict
{
    // GET SORTED ARRAY
    NSArray *arrKeys = [self sortedKeysFrom:pDict];
    
    NSInteger staIndex = (arrKeys.count / 3);
    NSInteger endIndex = staIndex * 2;
    
    //NSLog(@"정렬된 배열: %@", arrKeys);
    
    NSInteger lowestFrame = ((NSString*)[arrKeys objectAtIndex:staIndex]).integerValue;
    float lowestBColor = ((NSString*)[pDict valueForKey:@(lowestFrame).description]).floatValue;
    
    for (NSInteger i = staIndex; i < endIndex; i++) {
        NSInteger currFrm = ((NSString*)[arrKeys objectAtIndex:i]).integerValue;
        float currBColor = ((NSString*)[pDict valueForKey:@(currFrm).description]).floatValue;
        
        if (lowestBColor > currBColor) {
            lowestBColor = currBColor;
            lowestFrame = currFrm;
        }
        // NSLog(@"프레임:칼라 = %li:%f", currFrm, currBColor);
    }
    return lowestFrame;
}

/*------------------------------------
 DRAW SENTANCE LAYER ON SPECTRUM IMAGE
 -------------------------------------*/
-(UIImage*)drawSentence:(UIImage*)pImgDigitaOnly
          audioDuration:(float)pAudioDuration
         startSecToFind:(float)pStaSecToFind
           endSecToFind:(float)pEndSecToFind
             dictOfSens:(NSDictionary*)pDictOfSens
{
    
    //NSLog(@"-");
    //NSLog(@"문장그리기 시작시간(%.2f) 끝시간(%.2f)", pStaSecToFind, pEndSecToFind);
    
    // MAKE SAME IMAGE TO WORK
    UIImage *imgCopied = [UIImage imageWithData:UIImagePNGRepresentation(pImgDigitaOnly)];
    
    // 이미지의 시작프레임이 첫번째 문장의 시작프레임과 동일하지 않고 (대부분이 그러하겠지)
    // 지금까지 찾아진 전체문장의 마지막 문장이 pStaSecToFind 를 포함하는게 있다면...?
    // ZERO 프레임부터 그녀석의 마지막프레임까지 계산해서 그려줄 필요가 있다
    
    for (NSInteger i = 0; i < pDictOfSens.count; i++)
    {
        SentInfo* senToDraw = [pDictOfSens objectForKey:@(i).description];
        
        CGRect frame = CGRectMake(senToDraw.staFrame, 0,
                                  senToDraw.endFrame - senToDraw.staFrame - 0.15, 17.0);
        imgCopied = [self drawRectangleOn:imgCopied withFrame:frame];
    }
    
    return imgCopied;
}

/*----------------------------------------------
 DRAW SENTENCE LAYER ON SPECTRUM IMAGE
 IT IS VERY IMPORTANT MAIN METHOD OF THIS CLASS
 -----------------------------------------------*/
-(NSMutableDictionary*)findSentenceNDraw:(UIImage*)pImgDigitaOnly
                subTitle:(SubTitle*)pSubTitle
           audioDuration:(float)pAudioDuration
                interval:(float)pInterval
          startSecToFind:(float)pStaSecToFind
            endSecToFind:(float)pEndSecToFind
{
    //NSLog(@"-");
    //NSLog(@"자막으로 문장만들기");
    
    float secPer1Frame = (pEndSecToFind - pStaSecToFind) / pImgDigitaOnly.size.width;
    NSMutableDictionary* dictOfNewSens = [NSMutableDictionary dictionary];
    
    // MAKE SENTENCE DICTIONARY
    SubTitleCaption* caption = [pSubTitle firstCaptionGreaterThanAtSec:pStaSecToFind];
    if (caption == nil) {
        //NSLog(@"자막 존재하지 않음");
        return dictOfNewSens;
        //caption = [pSubTitle captionOfindexAt:0];
    }
    
    NSInteger indexOfStartCaption = caption.index;
    for (NSInteger i = indexOfStartCaption; i < [SubTitle shared].dictCaption.count; i++) {

        // STOP MAKING SENTENCES
        if (caption.secToSta >= pEndSecToFind)
            break;
        
        // SAVE TIME-INFO & FRAME-INFO TO DICTIONARY AS 2 DIGITS
        NSInteger staFrame = (caption.secToSta - pStaSecToFind) / secPer1Frame;
        NSInteger endFrame = (caption.secToEnd - pStaSecToFind) / secPer1Frame;
        
        if (staFrame < 0) {
            NSLog(@"-");
            NSLog(@"프레임 오류 발생 스타트 프레임번호가 0 보다 작음");
            NSLog(@"자막 시작시간(%.2f) 종료시간(%2.f)", caption.secToSta, caption.secToEnd);
            NSLog(@"현재 자막 인덱스(%li) 현재까지 만들어진 문장 개수(%li)", i, dictOfNewSens.count);
            NSLog(@"프레임 당 초(%.2f)", secPer1Frame);
        }
        
        /*--------------------
         ON FIND ONE SENTENCE
         ---------------------*/
        SentInfo* senInfo = [[SentInfo alloc] init];
        senInfo.staSec = caption.secToSta;
        senInfo.endSec = caption.secToEnd;
        senInfo.staFrame = staFrame;
        senInfo.endFrame = endFrame;
        senInfo.index = dictOfNewSens.count;
        [dictOfNewSens setValue:senInfo forKey:@(dictOfNewSens.count).description];
        
        caption = [[SubTitle shared] captionOfindexAt:(i +1)];
    }
    
    return dictOfNewSens;
}

/*----------------------------------------------
 DRAW SENTENCE LAYER ON SPECTRUM IMAGE
 IT IS VERY IMPORTANT MAIN METHOD OF THIS CLASS
 -----------------------------------------------*/
-(NSMutableDictionary*)findSentenceNDraw:(UIImage*)pImgDigitaOnly
           audioDuration:(float)pAudioDuration
                interval:(float)pInterval
          startSecToFind:(float)pStaSecToFind
            endSecToFind:(float)pEndSecToFind
{
    //NSLog(@"-");
    //NSLog(@"스펙트럼으로 문장찾기 요청시간 시작(%.2f) 끝(%.2f)", pStaSecToFind, pEndSecToFind);
    
    // 이미 대기중인 문장찾기 요청이 있음
    if (self.isQueFull) {
        //NSLog(@"이미 대기중인 문장찾기 요청이 있음");
        return nil;
    }
    
    // 문장찾기 작업중임 다음작업은 대기할것
    if (self.isOnProcessing) {
        //NSLog(@"문장만들기 작업중에 호출받음");
        // return;
        self.isQueFull = YES;
        while (self.isOnProcessing) {
            //float period = (pEndSecToFind - pStaSecToFind);
            //NSLog(@"문장만들기 작업 대기중.. %.2f", period);
            [NSThread sleepForTimeInterval:0.5];
        }
        self.isQueFull = NO;
    }
    
    // 문장찾기 작업 시작
    self.isOnProcessing = YES;
    
    // 프레임번호를 시간(초)로 변경하기 위한 상수값
    float secPer1Frm = (pEndSecToFind - pStaSecToFind) / pImgDigitaOnly.size.width;
    
    // NSLog(@"문장찾기 시간 시작(%.2f) 끝(%.2f)", pStaSecToFind, pEndSecToFind);
    
    // MAKE SAME IMAGE TO WORK
    UIImage *partImage = [UIImage imageWithData:UIImagePNGRepresentation(pImgDigitaOnly)];
    
    // 문장찾기에 사용될 변수들 선언
    CGFloat colorAmount;
    BOOL findEndPoint = NO;
    
    NSInteger startFrame     = 0;
    NSInteger endFrame       = 0;
    float startSecond        = 0;
    float endSecond          = 0;
    float duraOfCurrSentence = 0;
    
    // 내부공백들 분석
    NSMutableDictionary* dictInBlank = [NSMutableDictionary dictionary];
    NSMutableDictionary* dictFrm2Col = [NSMutableDictionary dictionary];
    
    // 생성된 문장들 저장소
    NSMutableDictionary* dictOfNewSens = [NSMutableDictionary dictionary];
    
    // LOOP FOR FINDING LOW SOUND
    for (NSInteger i = 1; i < partImage.size.width; i++)
    {
        /*------------------------------
         GET SOUND LEVEL BY ONE PIXEL
         -------------------------------*/
        CGRect rectToCheck = CGRectMake(i, (partImage.size.height / 2), 1, 1);
        colorAmount = [self levelOfSound:partImage rect:rectToCheck];
        
        /*----------------------------
         문장의 시작점을 찾았다 (칼라지점 만남)
         -----------------------------*/
        if ((colorAmount > BCOLOR_LEV) && (!findEndPoint))
        {
            //NSLog(@"시작점 찾기 완료:%li", i);
            startSecond = (i * secPer1Frm + pStaSecToFind);
            startFrame = i;
            
            // OK, NEXT LOOP,
            // FIND END-POINT OF SOUND
            findEndPoint = YES;
            continue;
        }
        
        // SAVE EACH B-Color AND Frame Number
        [dictFrm2Col setValue:@(colorAmount).description
                       forKey:@(i).description];
        
        /*----------------------------
         FOUND END-POINT OF SOUND
         문장의 끝점을 찾았다 (공백지점 만남)
         -----------------------------*/
        if ((colorAmount < BCOLOR_LEV) && (findEndPoint))
        {
            //NSLog(@"문장 끝점 찾기 완료:%li", i);
            endFrame = i;
            endSecond = (i * secPer1Frm + pStaSecToFind);
            
            // 현재문장 크기
            duraOfCurrSentence = (endSecond - startSecond);
            
            NSInteger frameNumOfCommingSen = [self frameNumOfCommingSentence:partImage
                                                          currentFrame:i];
            // 다음문장과 차이가 "1.0" 프레임이면 문장이 이어진다고 봐야 한다.
            // 하지만 지금까지의 문장길이가 충분히 길다면 이어진다고 볼 필요 없다.
            if ((frameNumOfCommingSen - i) == 1)
            {
                if (duraOfCurrSentence < pInterval)
                {
                    // 현재 공백이 1칸이라는 뜻 - 문장 찾기로 취급하지 않는다
                    // SAVE INNEST BLANK
                    [dictInBlank setValue:@"1"
                                   forKey:@(i).description];
                    
                    i = frameNumOfCommingSen;
                    continue;
                }
            }
            
            // 이전 문장 크기 = 마지막 문장의 크기
            float duraOfPrevSen = 0.0;
            SentInfo* senLast = [self getLastSen:dictOfNewSens];
            if (senLast)
                duraOfPrevSen = senLast.duration;
            
            // 이전 빈공백 크기
            float duraOfPrevBlank = 0.0;
            NSInteger frameNumOfEndBlank = startFrame;
            float endSecOfBlank = (frameNumOfEndBlank * secPer1Frm + pStaSecToFind);
            if (senLast)
                duraOfPrevBlank = (endSecOfBlank - senLast.endSec);
            
            // 현재 문장 크기 (문장예정)
            
            
            // 다음 빈공백 크기
            //NSLog(@"다음 공백크기 구하기");
            float duraOfNextBlank = 0.0;
            NSInteger frameNumOfStaBlank = i;
            frameNumOfEndBlank = (frameNumOfCommingSen - 1);
            float staSecOfBlank = (frameNumOfStaBlank * secPer1Frm + pStaSecToFind);
            endSecOfBlank = (frameNumOfEndBlank * secPer1Frm + pStaSecToFind);
            duraOfNextBlank = (endSecOfBlank - staSecOfBlank);
            
            // 다음 문장 크기 (다음공백 이후의 문장크기)
            //float frameNumOfEndOfNextSen = [self frameNumOfCommingBlank:partImage
            //                                               currentFrame:frameNumOfCommingSen];
            //float endSecOfNextSen = (frameNumOfEndOfNextSen / numberOfFramesPerOneSecond);
            //float secOfNextSen = (endSecOfNextSen - endSecOfBlank);
            
            /*NSLog(@"-");
            NSLog(@"현재문장 카운트: %li", [[SentGroup shared] count]);
            NSLog(@"이전문장 크기: %.2f", duraOfPrevSen);
            NSLog(@"이전공백 크기: %.2f", duraOfPrevBlank);
            NSLog(@"현재문장 크기: %.2f", duraOfCurrSentence);
            NSLog(@"다음공백 크기: %.2f", duraOfNextBlank);
            NSLog(@"다음문장 크기: %.2f", secOfNextSen);*/
            
            // 너무 짧은 문장을 찾았다
            // 앞문장에 붙일까 다음문장에 붙일까? (지정길이의 3분의 2에도 미치지 못하면)
            if (duraOfCurrSentence < (pInterval / 3.0) * 2.0)
            {
                // 지금 찾아낸 문장을 기준으로
                // 이전공백이 다음공백보다 크면 다음문장에 붙이자
                // 단, 다음문장과 붙였을 때 그 문장이 너무 길지 않아야 한다
                if (frameNumOfCommingSen != partImage.size.width)
                if ((duraOfPrevBlank > duraOfNextBlank) ||
                    (dictOfNewSens.count == 0))
                {
                    // NSLog(@"짧은문장 발견 다음 문장에 붙임: %li", i);
                    // NSLog(@"다음 블랭크 길이: %.2f", duraOfNextBlank);
                    // NSLog(@"다음 문장의 번호: %li", frameNumOfCommingSen);
                    // SAVE INNEST BLANK
                    [dictInBlank setValue:@(duraOfNextBlank).description forKey:@(i).description];
                    
                    frameNumOfCommingSen = [self frameNumOfCommingSentence:partImage
                                                              currentFrame:i];
                    i = frameNumOfCommingSen;
                    continue;
                }
                
                //NSLog(@"-");
                //NSLog(@"짧은문장 발견 - 앞 문장에 붙임 - 이전공백길이:(%.2f)", duraOfPrevBlank);
                // 이전공백이 다음공백보다 작으면 이전문장에 이어붙인다
                // 이전문장을 삭제한다
                NSInteger lastIdx = dictOfNewSens.count -1;
                SentInfo* lastSen = [dictOfNewSens objectForKey:@(lastIdx).description];
                startFrame = lastSen.staFrame;
                startSecond = lastSen.staSec;
                [dictOfNewSens removeObjectForKey:@(lastIdx).description];
                duraOfCurrSentence = (endSecond - startSecond);
                //NSLog(@"붙인 이후 문장의 길이 %.2f", duraOfCurrSentence);
            }            
            
            // 찾아낸 문장의 길이가 너무 큰가? (지정길이의 2.5배)
            // 파일의 맨 처음 문장은 길어도 좋다.
            if ([[SentGroup shared] isNotEmpty]) {
                if (duraOfCurrSentence > (pInterval * 2.5)) {
                    //NSLog(@"-");
                    //NSLog(@"찾아낸 문장길이 너무 길다 - 길이(%f)", duraOfCurrSentence);
                    // 연속된 공백이 가장 긴 구간을 찾아라
                    if (dictInBlank.count > 0) {
                        NSInteger frameNumOfLargestBalnk = [self startFrameNumOfLargestBlank:dictInBlank];
                        [dictInBlank removeAllObjects];
                        
                        endFrame = frameNumOfLargestBalnk;
                        endSecond = (endFrame * secPer1Frm + pStaSecToFind);
                        duraOfCurrSentence = (endSecond - startSecond);
                        //NSLog(@"짜르기 시도");
                        
                        if (duraOfCurrSentence < 1.0f) {
                            //NSLog(@"하지만 너무 짧은 문장이 되버려 짜르기 취소함: %f", duraOfCurrSentence);
                            endFrame = i;
                            endSecond = (endFrame * secPer1Frm + pStaSecToFind);
                            duraOfCurrSentence = (endSecond - startSecond);
                            //NSLog(@"내부 공백: %@", dictInBlank);
                            //NSLog(@"가장 큰 공백 프레임: %li", frameNumOfLargestBalnk);
                        }
                    } else {
                        //NSLog(@"-");
                        //NSLog(@"짜르지 못함 내부공백이 없거나 너무 짧은 공백 현재 프레임: %li", i); // 내부공백이 없음
                        //NSLog(@"%@", dictInBlank);
                        NSInteger frameNumOfLowestSound = [self startFrameNumOfLowestSound:dictFrm2Col];
                        //NSLog(@"-");
                        //NSLog(@"그나마 가장 낮은음역 프레임: %li", frameNumOfLowestSound);
                        //NSLog(@"%@", dictFrm2Col);
                        
                        endFrame = frameNumOfLowestSound;
                        endSecond = (endFrame * secPer1Frm + pStaSecToFind);
                        duraOfCurrSentence = (endSecond - startSecond);
                        //NSLog(@"결국 짤라낸 문장길이 (%.2f)", duraOfCurrSentence);
                    }
                }
            }
            duraOfCurrSentence = (endSecond - startSecond);
            
            // 문장성립완료
            // NSLog(@"다음 검사할 프레임 구하기");
            i = [self frameNumOfCommingSentence:partImage currentFrame:endFrame];
        
            /*------------
             중복 문장 발견됨
             -------------*/
            SentInfo* sen = [[SentGroup shared] getBySecond:startSecond];
            if (sen != nil) {
                NSLog(@"-");
                NSLog(@"중복된 문장 발견!");
                [sen printLog];
                NSLog(@"추가하려는 문장 시간 (%.2f)-(%.2f)", startSecond, endSecond);
                NSLog(@"추가하려는 문장 프렘 (%li)-(%li)", startFrame, endFrame);
                //NSLog(@"-");
            }
            
            /*--------------------
             ON FIND ONE SENTENCE
             ---------------------*/
            SentInfo* senInfo = [[SentInfo alloc] init];
            senInfo.staSec = startSecond;
            senInfo.staFrame = startFrame;
            senInfo.endSec = endSecond;
            senInfo.endFrame = endFrame;
            senInfo.index = dictOfNewSens.count;
            [dictOfNewSens setValue:senInfo forKey:@(dictOfNewSens.count).description];
            
            /*----------------------
             잘못된 프레임 계산문장 발견됨
             -----------------------*/
            if (endFrame < startFrame) {
                NSLog(@"-");
                NSLog(@"종료프레임이 시작프레임보다 작은 문장 발견!");
                SentInfo* sen = [[SentGroup shared] getLastSen];
                [[[SentGroup shared] getByIndex:sen.index -1] printLog];
                [sen printLog];
                //NSLog(@"-");
            }
            
            // CLEAR INNEST BLANK
            [dictInBlank removeAllObjects];
            [dictFrm2Col removeAllObjects];
            
            // FIND START-POINT OF SOUND
            findEndPoint = NO;
            continue;
        }
    }
    
    // 왼쪽방향으로 이동시 분석요청이였나..?
    SentInfo* senLast = [dictOfNewSens objectForKey:@(dictOfNewSens.count -1).description];
    if ([[SentGroup shared] countOfallSen] != 0) {
        if ([[SentGroup shared] getFirstSen].staSec > senLast.endSec) {
            //NSLog(@"-");
            //NSLog(@"왼쪽방향 분석에서 마지막 문장 다시 확인 시도");
            float staFrame = [self frameNumOfCommingSentence:partImage
                                                currentFrame:senLast.endFrame +1];
            float endFrame = [self frameNumOfBackCommingSentence:partImage
                                                    currentFrame:partImage.size.width];
            
            // 추가문장이 발견됨
            if (endFrame != senLast.endFrame)
                if (staFrame < endFrame) {
                    //NSLog(@"-");
                    //NSLog(@"마지막 문장 정보:");
                    [senLast printLog];
                    //NSLog(@"확인결과 추가 문장발견 시작프레임(%.2f) 종료프레임(%.2f)", staFrame, endFrame);
                    //NSLog(@"전체 프레임 길이(%.2f)", partImage.size.width);
                    
                    // 기존 마지막 문장에 이어 붙인다
                    float endSec = (endFrame * secPer1Frm + pStaSecToFind);
                    senLast.endFrame = endFrame;
                    senLast.endSec = endSec;
                    
                    //NSLog(@"-");
                    //NSLog(@"마지막 문장 교정완료");
                    [senLast printLog];
                }
        }
    }
    
    // 문장자르기 작업완료
    self.isOnProcessing = NO;
    
    // 지금까지 생성된 문장들 반환
    return dictOfNewSens;
}

- (SentInfo*)getLastSen:(NSMutableDictionary*)pDictSen {
    SentInfo* sen = [pDictSen valueForKey:@(pDictSen.count -1).description];
    return sen;
}

- (UIImage*)drawRectangleOn:(UIImage*)pTotalImage withFrame:(CGRect)pFrame
{
    
    // make two frames
    CGRect frmUpper = CGRectMake(pFrame.origin.x, 0, pFrame.size.width, pFrame.size.height);
    CGRect frmLower = CGRectMake(pFrame.origin.x, 33, pFrame.size.width, pFrame.size.height);
    
    // create a new bitmap image context
    UIGraphicsBeginImageContext(pTotalImage.size);
    
    // draw original image into the context
    [pTotalImage drawAtPoint:CGPointZero];
    
    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.2);
    // drawing with a white fill color
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.2);
    // Add Filled Rectangle,
    // CGContextFillRect(context, pFrame);
    CGContextFillRect(context, frmUpper);
    CGContextFillRect(context, frmLower);
    
    UIImage* imgToRet = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imgToRet;
}

/*-(void)indexOfSenByAnySec:(float)pAnySec
                    index:(NSInteger*)refIndex
                isInBlank:(BOOL*)refIsInBlank;
{
    if (self.isOnFindingIndex) {
        *refIndex = -1;
        *refIsInBlank = NO;
        return;
    }
    self.isOnFindingIndex = YES;
    
    NSString* twoDigit = [NSString stringWithFormat:@"%.2f", pAnySec];
    pAnySec = twoDigit.floatValue;
    
    // SORT SECONDS THAT
    // INDICATE START POINT OF ALL SENTENCES
    NSArray *sortedArrSecs = [self sortedKeysFrom:self.dictStartSec2EndSec];

    NSString* prevStaSec = @"";
    NSString* prevEndSec = @"";
    NSString* staSec = @"0";
    NSString* endSec = @"0";
    
    for (int i = 1; i < sortedArrSecs.count -1; i++) {
        
        // GET TWO START POINTS
        prevStaSec = [sortedArrSecs objectAtIndex:i-1];;
        prevEndSec = [self.dictStartSec2EndSec valueForKey:prevStaSec];
        staSec = [sortedArrSecs objectAtIndex:i];
        endSec = [self.dictStartSec2EndSec valueForKey:staSec];
        
        // FOUND POSITION IN A SENTENCE
        if ((pAnySec >= staSec.floatValue) && (pAnySec <= endSec.floatValue)) {
            self.isOnFindingIndex = NO;
            *refIsInBlank = NO;
            *refIndex = i;
            return;
        }
        // FOUND POSITION IN A BLANK
        if ((pAnySec >= prevEndSec.floatValue) && (pAnySec <= staSec.floatValue)) {
            self.isOnFindingIndex = NO;
            *refIsInBlank = YES;
            *refIndex = i - 1;
            return;
        }
    }
    //NSLog(@"인덱스가 0? %f", pAnySec);
    self.isOnFindingIndex = NO;
    *refIsInBlank = YES;
    *refIndex = 0;
}

//-(void)startSecNEndSecOfSentenceByIndex:(NSInteger)pIndex
                                 staSec:(float*)refStaSec
                                 endSec:(float*)refEndSec;
{
    // SORT SECONDS THAT
    // INDICATE START POINT OF ALL SENTENCES
    NSArray *sortedArrSecs = [self sortedKeysFrom:self.dictStartSec2EndSec];

    // CHECK
    if (pIndex > sortedArrSecs.count -1)
        pIndex = sortedArrSecs.count -1;
    if (pIndex < 0)
        pIndex = 0;
    
    NSString* staSec = @"0";
    NSString* endSec = @"0";
    staSec = [sortedArrSecs objectAtIndex:pIndex];
    endSec = [self.dictStartSec2EndSec valueForKey:staSec];
    *refStaSec = staSec.floatValue;
    *refEndSec = endSec.floatValue;
}

-(float)endSecOfCurrSentWithAnySec:(float)pAnySec {

    BOOL isBeingInBlank = NO;
    NSInteger indexOfSen = -1;
    float 
    float staSec = [self startSecOfCurrSentWithAnySec:pAnySec
                                                index:&indexOfSen
                                              isBlank:&isBeingInBlank];
    NSString* endSec = [self.dictStartSec2EndSec valueForKey:@(staSec).description];
    
    if (endSec) {
        return endSec.floatValue;
    }
    return -1;
}

-(float)startSecOfCurrSentWithAnySec:(float)pAnySec
                              endSec:(float*)refEndSec
                               index:(NSInteger*)refIndex
                             isBlank:(BOOL*)refIsBlank
{
    /----------------------
     찾아놓은 문장이 있기는 한가?
     -----------------------/
    if (self.dictStartSec2EndSec.count == 0)
    {
        NSLog(@"찾아놓은 문장이 한 개도 없다");
        *refIndex = -1;
        *refEndSec = -1;
        *refIsBlank = YES;
        return -1;
    }
    
    // SORT SECONDS THAT
    // INDICATE START POINT OF ALL SENTENCES
    NSArray *sortedArrSecs = [self sortedKeysFrom:self.dictStartSec2EndSec];

    NSString* prevStaSec = @"";
    NSString* prevEndSec = @"";
    NSString* staSec = @"0";
    NSString* endSec = @"0";
    
    /---------------------------
     제일 첫번째 문장인지를 먼저 확인한다
     ----------------------------/
    staSec = [sortedArrSecs objectAtIndex:0];;
    endSec = [self.dictStartSec2EndSec valueForKey:staSec];
    if (pAnySec >= staSec.floatValue && pAnySec <= endSec.floatValue) {
        NSLog(@"-");
        NSLog(@"현재시간의 문장찾기 제일 첫번째 문장에서 발견됨");
        NSLog(@"현재시간(%.2f) 찾은문장의 시작(%.2f) 끝(%.2f)", pAnySec, staSec.floatValue, endSec.floatValue);
        *refIsBlank = NO;
        *refIndex = 0;
        *refEndSec = endSec.floatValue;
        return staSec.floatValue;
    }
    
    /---------------------------------------
     제일 첫번째 문장의 시작시간보다 작은 시간에서 찾을때,
     ----------------------------------------/
    if (pAnySec <= staSec.floatValue) {
        *refIsBlank = YES;
        *refIndex = 0;
        *refEndSec = endSec.floatValue;
        return staSec.floatValue;
    }
    
    /--------------------------
     첫번째 이후 문장에 대해서 확인한다
     ---------------------------/
    for (int i = 1; i < sortedArrSecs.count; i++)
    {
        // GET TWO START POINTS
        prevStaSec = [sortedArrSecs objectAtIndex:i-1];;
        prevEndSec = [self.dictStartSec2EndSec valueForKey:prevStaSec];
        staSec = [sortedArrSecs objectAtIndex:i];
        endSec = [self.dictStartSec2EndSec valueForKey:staSec];
        
        // FOUND POSITION IN A BLANK
        if (pAnySec > prevEndSec.floatValue && pAnySec < staSec.floatValue) {
            NSLog(@"-");
            NSLog(@"현재시간(%.2f)의 문장찾기 (%i)번째 문장과 (%i)번째 문장 사이 공백에서 발견됨", pAnySec, i-1, i);
            NSLog(@"좌측문장 끝시간(%.2f) 우측문장 시작시간(%.2f)", prevEndSec.floatValue, staSec.floatValue);
            *refIsBlank = YES;
            *refIndex = i - 1;
            *refEndSec = prevEndSec.floatValue;
            return prevStaSec.floatValue;
        }
        
        // FOUND POSITION IN A SENTENCE
        if (pAnySec >= (staSec.floatValue - 0.1) && pAnySec <= (endSec.floatValue + 0.1)) {
            NSLog(@"-");
            NSLog(@"현재시간의 문장찾기 (%i)번째 문장에서 발견됨", i);
            NSLog(@"현재시간(%.2f) 찾은문장의 시작(%.2f) 끝(%.2f)", pAnySec, staSec.floatValue, endSec.floatValue);
            *refIsBlank = NO;
            *refIndex = i;
            *refEndSec = endSec.floatValue;
            return staSec.floatValue;
        }
    }
    
    NSLog(@"-");
    NSLog(@"현재시간에 속한 문장을 찾지 못함 %@ (%.2f)", [[ConfigFile shared] timeFormatted:pAnySec], pAnySec);
    NSLog(@"지금까지 찾아진 문장개수: %li", sortedArrSecs.count);
    prevStaSec = [sortedArrSecs objectAtIndex:0];
    prevEndSec = [self.dictStartSec2EndSec valueForKey:prevStaSec];
    staSec = [sortedArrSecs objectAtIndex:sortedArrSecs.count-1];
    endSec = [self.dictStartSec2EndSec valueForKey:staSec];
    NSLog(@"첫번째 문장의 시작시간:%@(%.2f) 마지막 문장의 끝시간:%@(%.2f)",
          [[ConfigFile shared] timeFormatted:prevStaSec.intValue], prevStaSec.floatValue,
          [[ConfigFile shared] timeFormatted:endSec.intValue], endSec.floatValue);
    
    /--------------
     문장을 찾지 못했다
     ---------------/
    *refIndex = -1;
    *refIsBlank = YES;
    return -1;
}

-(float)startSecOfNextSentWithAnySec:(float)pAnySec
{
    // SORT SECONDS THAT
    // INDICATE START POINT OF ALL SENTENCES
    BOOL isBlank;
    NSInteger indexOfCurrSen;
    float currStartSec = [self startSecOfCurrSentWithAnySec:pAnySec
                                                      index:&indexOfCurrSen
                                                    isBlank:&isBlank];
    if (currStartSec < 0) {
        NSLog(@"-");
        NSLog(@"다음문장 찾기 로직 부분에서 현재시간(%.2f) 에 해당하는 문장 찾기", pAnySec);
        NSLog(@"문장찾지 못한 경우 로직 처리해야함");
        return -99.0;
    }
    
    // SORT SECONDS THAT
    // INDICATE START POINT OF ALL SENTENCES
    NSArray *sortedArrSecs = [self sortedKeysFrom:self.dictStartSec2EndSec];
    
    // CHECK THERE IS NO NEXT SENTENCE
    BOOL isBeingNoNext = (indexOfCurrSen + 1) > (sortedArrSecs.count - 1);
    if (isBeingNoNext) {
        NSLog(@"다음 문장이 존재하지 않음");
        return -1.0;
    }
    
    return ((NSString*)[sortedArrSecs objectAtIndex:
                        indexOfCurrSen +1]).floatValue;
}

-(float)startSecOfPrevSentWithAnySec:(float)pAnySec
{
    BOOL isBlank;
    NSInteger indexOfCurrSen;
    float currStartSec = [self startSecOfCurrSentWithAnySec:pAnySec
                                                      index:&indexOfCurrSen
                                                    isBlank:&isBlank];
    if (currStartSec < 0) {
        NSLog(@"-");
        NSLog(@"이전문장 찾기 로직 부분에서 현재시간에 해당하는 문장 찾기");
        NSLog(@"문장찾지 못한 경우 로직 처리해야함");
    }
    
    // SORT SECONDS THAT
    // INDICATE START POINT OF ALL SENTENCES
    NSArray *sortedArrSecs = [self sortedKeysFrom:self.dictStartSec2EndSec];
    
    if (indexOfCurrSen == 0) {
        return ((NSString*)[sortedArrSecs objectAtIndex:
                            indexOfCurrSen]).floatValue;
    }
    return ((NSString*)[sortedArrSecs objectAtIndex:
                        indexOfCurrSen -1]).floatValue;
}

-(float)startSecOfCurrSentWithEndSec:(float)pEndSec {
    
    NSString* secToFind = [NSString stringWithFormat:@"%.1f",pEndSec];
    
    NSString* startSec = [self.dictEndSec2StartSec
                          valueForKey:secToFind];
    
    if (startSec) {
        return startSec.floatValue;
    }
    
    return -1;
}

-(float)startSecOfCurrSentWithEndFrame:(int)pEndFrame
{
    NSString* startSec = [self.dictEndFrame2StartSec
                          valueForKey:@(pEndFrame).description];
    
    if (startSec) {
        return startSec.floatValue;
    }
    
    return -1;
}

-(float)startSecOfNextSentWithEndFrame:(int)pEndFrame
{
    NSArray* arrSecs = [self.dictEndFrame2StartSec allKeys];
    NSArray* sortedArrSecs = [arrSecs sortedArrayUsingSelector:
                              @selector(localizedStandardCompare:)];
    
    NSUInteger indexOfCurrEndFrame = [sortedArrSecs indexOfObject:@(pEndFrame).description];
    NSUInteger indexOfNextEndFrame = indexOfCurrEndFrame + 1;
    
    // IF LAST SENTENCE, RETURN -1
    if (indexOfNextEndFrame >= sortedArrSecs.count)
        return -1;
    
    int frameNumberOfNext = ((NSString*)[sortedArrSecs objectAtIndex:
                                         indexOfNextEndFrame]).intValue;
    
    NSString* startSecOfNext = [self.dictEndFrame2StartSec
                                valueForKey:@(frameNumberOfNext).description];
    
    return startSecOfNext.floatValue;
}*/

/*------------------
 CREATE SOUND IMAGE
 -------------------
-(void)createSoundImage:(NSString*)pAudioPath
                 staSec:(float)pStaSec
                 endSec:(float)pEndSec
              imgHeight:(float)pImgHeight
              imgAnalog:(UIImage**)pImgAnalog
              imgDigita:(UIImage**)pImgDigita
{
    // MAKE SPECTRUM IMAGE
    UIImage* imgToDigi = nil;
    UIImage* imgToWave = [[AudioFromVideo shared]
                          createSpectrumImgFromAudio:pAudioPath
                          height:pImgHeight
                          //staSec:0.0
                          //endSec:pEndSec
                          imageSimple:&imgToDigi];
    
    *pImgAnalog = [UIImage imageWithData:UIImagePNGRepresentation(imgToWave)];
    *pImgDigita = [UIImage imageWithData:UIImagePNGRepresentation(imgToDigi)];
}*/

@end
