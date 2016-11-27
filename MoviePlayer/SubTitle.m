//
//  SubTitle.m
//  repeater
//
//  Created by admin on 2016. 3. 4..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "SubTitle.h"
#import "KSPath.h"
#import "Config.h"

static SubTitle* instance = nil;

@implementation SubTitle

+(SubTitle*)shared
{
    if (instance == nil) {
        instance = [[SubTitle alloc] init];
        instance.dictCaption = [[NSMutableDictionary alloc] init];
    }
    return instance;
}

- (NSString*)trimmed:(NSString*)pString
{
    pString = [pString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pString = [pString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return [pString stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSNumber *)numberFromString:(NSString *)string
{
    if (string.length) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        return [f numberFromString:string];
    } else {
        return nil;
    }
}

- (NSString *)stringByFormattingString:(NSString *)string toPrecision:(NSInteger)precision
{
    NSNumber *numberValue = [self numberFromString:string];
    
    if (numberValue) {
        NSString *formatString = [NSString stringWithFormat:@"%%.%ldf", (long)precision];
        return [NSString stringWithFormat:formatString, numberValue.floatValue];
    } else {
        /* return original string */
        return string;
    }
}

- (void)loadSRT:(NSString*)pMoviePath
{
    [self.dictCaption removeAllObjects];
    
    /*--------------
     LOAD SUBTITILE
     ---------------*/
    NSString* filePathExceptExtention = [pMoviePath substringToIndex:pMoviePath.length-4];
    NSString* subtitleFile = [NSString stringWithFormat:@"%@.SRT", filePathExceptExtention];
    
    if ([[KSPath shared] isExistPath:subtitleFile] == NO)
    {
        self.isLoaded = NO;
        return;
    }
    
    
    /*---------------------------
     MAKE SUB CAPTION AS A ARRAY
     ----------------------------*/
    NSArray* arrCaption = nil;
    NSString* content = [NSString stringWithContentsOfFile:subtitleFile
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    if (content == nil) {
        subtitleFile = [[KSPath shared] changeFileNameByNewExt:subtitleFile newExt:@".srt"];
        content = [NSString stringWithContentsOfFile:subtitleFile
                                            encoding:NSUTF8StringEncoding
                                               error:NULL];
    }
    arrCaption = [content componentsSeparatedByString:@"\n"];

    
    /*-----------------------------
     SET FLAG OF EXISTING SUBTITLE
     ------------------------------*/
    self.isLoaded = YES;
    
    /*--------------------------
     MAKE COLLECTION OF CAPTION
     ---------------------------*/
    NSMutableString* strSub = [NSMutableString string];
    for (NSInteger i = 0; i < arrCaption.count; i++) {
        NSString* aLine = [arrCaption objectAtIndex:i];
        aLine = [aLine stringByReplacingOccurrencesOfString:@"," withString:@"."];
        
        /*-------------------------------
         FIND ONE PARAGRAPH OF SUBTITILE
         --------------------------------*/
        if ([aLine rangeOfString:@"-->"].location != NSNotFound)
        {
            // FIND START TIME & END TIME
            NSArray* arrStartNEnd = [aLine componentsSeparatedByString:@"-->"];
            NSString* staTimeFormatted = [arrStartNEnd objectAtIndex:0];
            staTimeFormatted = [self trimmed:staTimeFormatted];
            NSString* endTimeFormatted = [arrStartNEnd objectAtIndex:1];
            endTimeFormatted = [self trimmed:endTimeFormatted];
            
            /*--------------------------------------------------
             PARSING AND CONVERT FORMAT 00:00:00 INTO "000.00"
             ---------------------------------------------------*/
            float staTimeSec = [[Config shared] timeFormattedToSec:[staTimeFormatted substringToIndex:8]];
            float endTimeSec = [[Config shared] timeFormattedToSec:[endTimeFormatted substringToIndex:8]];
            
            float staTimeDec = [staTimeFormatted substringWithRange:NSMakeRange(8, 3)].floatValue;
            float endTimeDec = [endTimeFormatted substringWithRange:NSMakeRange(8, 3)].floatValue;
            
            staTimeSec = staTimeSec + staTimeDec;
            staTimeFormatted = [self stringByFormattingString:@(staTimeSec).description toPrecision:2];
            endTimeSec = endTimeSec + endTimeDec;
            endTimeFormatted = [self stringByFormattingString:@(endTimeSec).description toPrecision:2];
            
            //NSLog(@"자막 시작시간: %@", staTimeFormatted);
            //NSLog(@"자막 끝난시간: %@", endTimeFormatted);
            //if (staTimeDec == 0) {
            //    NSLog(@"제로?");
            //}
            
            /*------------------------------------------
             PARSING CAPTION UNTIL BEFORE NEXT CAPTION
             -------------------------------------------*/
            for (NSInteger j = i + 1; j < arrCaption.count; j++)
            {
                NSString* lineToNextSub = [arrCaption objectAtIndex:j];
                lineToNextSub = [self trimmed:lineToNextSub];
                
                if ([lineToNextSub rangeOfString:@"-->"].location != NSNotFound)
                {
                    // 다음문장 찾았으니 직전까지 하나의 캡션을 저장시키자
                    NSString* subTitleToSet = [NSString stringWithFormat:@"%@", strSub];
                    /*--------------
                     CREATE CAPTION
                     ---------------*/
                    SubTitleCaption* caption = [[SubTitleCaption alloc] init];
                    caption.index = self.dictCaption.count;
                    caption.secToSta = staTimeSec;
                    caption.secToEnd = endTimeSec;
                    caption.text = subTitleToSet;
                    
                    /*-----------------------------
                     INPUT CAPTION INTO DICTIONARY
                     ------------------------------*/
                    [self.dictCaption setValue:caption forKey:@(self.dictCaption.count).description];
                    
                    [strSub setString:@""];
                    break;
                } else {
                    
                    /*-----------------------------
                     마지막 문장이기 때문에 강제로 넣어주자
                     ------------------------------*/
                    if (j == arrCaption.count -1)
                    {
                        //NSLog(@"마지막 문장:%@", strSub);
                        /*--------------
                         CREATE CAPTION
                         ---------------*/
                        SubTitleCaption* caption = [[SubTitleCaption alloc] init];
                        caption.index = self.dictCaption.count;
                        caption.secToSta = staTimeSec;
                        caption.secToEnd = endTimeSec;
                        caption.text = strSub;
                        
                        /*-----------------------------
                         INPUT CAPTION INTO DICTIONARY
                         ------------------------------*/
                        [self.dictCaption setValue:caption forKey:@(self.dictCaption.count).description];
                    }
                    
                    if ([lineToNextSub isEqualToString:@""])
                        continue;
                    
                    NSString* count = @(self.dictCaption.count + 2).description;
                    if ([lineToNextSub isEqualToString:count])
                        continue;
                    
                    [strSub appendString:lineToNextSub];
                    [strSub appendString:@"\n"];
                }
            }
        }
    }
    
    //NSLog(@"캡션수:%li", self.dictCaption.count);
}

- (SubTitleCaption*)captionOfindexAt:(NSInteger)pIndex
{
    NSString* keyName = [NSString stringWithFormat:@"%li", pIndex];
    return [self.dictCaption valueForKey:keyName];
}

- (SubTitleCaption*)firstCaptionGreaterThanAtSec:(float)pSec
{
    
    for (NSInteger i = 1; i < self.dictCaption.count; i++) {
        SubTitleCaption* prevCaption = [self captionOfindexAt:i-1];
        SubTitleCaption* currCaption = [self captionOfindexAt:i];
        
        if (pSec < prevCaption.secToSta)
            return  prevCaption;
        
        /*if ((pSec >= prevCaption.secToSta) &&
            (pSec <= prevCaption.secToEnd))
        {
            return prevCaption;
        }*/
        
        if ((pSec > prevCaption.secToEnd) && (pSec < currCaption.secToSta)) {
            return currCaption;
        }
        
        if (pSec <= currCaption.secToSta) {
            return currCaption;
        }
    }
    
    
    return nil;
}

- (SubTitleCaption*)captionAtSec:(float)pSec
{
    
    for (NSInteger i = 1; i < self.dictCaption.count; i++)
    {
        SubTitleCaption* prevCaption = [self captionOfindexAt:i-1];
        SubTitleCaption* currCaption = [self captionOfindexAt:i];
        
        if ((pSec >= prevCaption.secToSta) &&
            (pSec <= prevCaption.secToEnd))
        {
            return prevCaption;
        }
        
        if ((pSec > prevCaption.secToEnd) &&
            (pSec < currCaption.secToSta))
        {
            return nil;
        }
        
        if ((pSec >= currCaption.secToSta) &&
            (pSec <= currCaption.secToEnd))
        {
            //NSLog(@"FOUND SUBTITLE CAPTION");
            return currCaption;
        }
    }
    
    
    return nil;
}

@end
