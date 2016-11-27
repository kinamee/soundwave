//
//  KSPlistMgr.m
//  repeater
//
//  Created by admin on 2015. 12. 27..
//  Copyright © 2015년 admin. All rights reserved.
//

#import "Config.h"
#import "KSPath.h"
#import "Reachability.h"

static Config* instance = nil;

@implementation Config

+(Config*)shared {
    if (instance == nil) {
        instance = [[Config alloc] init];
        
        /*-----------
         필수 폴더 생성
         ------------*/
        NSString* pathToTemp = [[KSPath shared] documentPath];
        pathToTemp = [pathToTemp stringByAppendingString:@"/_tmp"];
        if ([[KSPath shared] isExistPath:pathToTemp] == NO)
            [[KSPath shared] createDirectory:pathToTemp];
        
        NSString* pathToRec = [[KSPath shared] documentPath];
        pathToRec = [pathToRec stringByAppendingString:@"/_rec"];
        if ([[KSPath shared] isExistPath:pathToRec] == NO)
            [[KSPath shared] createDirectory:pathToRec];
        
        NSString* pathToRecTemp = [[KSPath shared] documentPath];
        pathToRecTemp = [pathToRecTemp stringByAppendingString:@"/_rec/_tmp"];
        if ([[KSPath shared] isExistPath:pathToRecTemp] == NO)
            [[KSPath shared] createDirectory:pathToRecTemp];
        
        /*-------------------------------------------------
         콘피그 파일 없다면 번들로부터 카피 + 샘플 동영상도 함께 카피한다
         --------------------------------------------------*/
        [instance copyConfigToDoc];
        
        NSString* pathToConfig = [[KSPath shared] documentPath];
        pathToConfig = [pathToConfig stringByAppendingString:@"/Configure.plist"];
        instance.dictToConf = [[NSMutableDictionary alloc] initWithContentsOfFile:pathToConfig];
        
        NSString* pathToTransl = [[KSPath shared] bundlePath];
        pathToTransl = [pathToTransl stringByAppendingString:@"/Translate.plist"];
        instance.dictToTran = [[NSMutableDictionary alloc] initWithContentsOfFile:pathToTransl];
        
        NSString* pathToHistor = [[KSPath shared] documentPath];
        pathToHistor = [pathToHistor stringByAppendingString:@"/PlayingHi.plist"];
        instance.dictToHist = [[NSMutableDictionary alloc] initWithContentsOfFile:pathToHistor];
        [instance clearHistoryGabage];
        
        // GET LOCAL LANGUAGE
        NSLocale *locale = [NSLocale currentLocale];
        NSString *language = [[locale displayNameForKey:NSLocaleIdentifier
                                                  value:[locale localeIdentifier]] uppercaseString];
        
        // NSLog(@"local language: %@", language); /*ENGLISH, 한국어, 中文*/
        if ([language rangeOfString:@"한국어"].location != NSNotFound)
            instance.language = [[NSString alloc] initWithFormat:@"KOR"];
        else if ([language rangeOfString:@"中文"].location != NSNotFound)
            instance.language = [[NSString alloc] initWithFormat:@"CHN"];
        else instance.language = [[NSString alloc] initWithFormat:@"ENG"];
        
        // INIT PLAY SPEED
        instance.playSpeed = 1.0;
        
        // SET REPEAT COUNT LIST
        instance.arrRepeatCount = [[NSMutableArray alloc] init];
        [instance.arrRepeatCount addObject:@"1"];
        [instance.arrRepeatCount addObject:@"2"];
        [instance.arrRepeatCount addObject:@"3"];
        [instance.arrRepeatCount addObject:@"4"];
        [instance.arrRepeatCount addObject:@"5"];
        [instance.arrRepeatCount addObject:@"6"];
        [instance.arrRepeatCount addObject:@"7"];
        [instance.arrRepeatCount addObject:@"8"];
        [instance.arrRepeatCount addObject:@"9"];
        [instance.arrRepeatCount addObject:@"10"];
        [instance.arrRepeatCount addObject:@"15"];
        [instance.arrRepeatCount addObject:@"20"];
        [instance.arrRepeatCount addObject:@"25"];
        [instance.arrRepeatCount addObject:@"30"];
        [instance.arrRepeatCount addObject:@"50"];
        [instance.arrRepeatCount addObject:@"70"];
        [instance.arrRepeatCount addObject:@"99"];
        [instance.arrRepeatCount addObject:@"Infinite"];
        
        // SET MINIMUM SENTENCE LEN LIST
        instance.arrMinSentenceLen = [[NSMutableArray alloc] init];
        [instance.arrMinSentenceLen addObject:@"0.5"];
        [instance.arrMinSentenceLen addObject:@"1.0"];
        [instance.arrMinSentenceLen addObject:@"1.5"];
        [instance.arrMinSentenceLen addObject:@"2.0"];
        [instance.arrMinSentenceLen addObject:@"2.5"];
        [instance.arrMinSentenceLen addObject:@"3.0"];
        [instance.arrMinSentenceLen addObject:@"3.5"];
        [instance.arrMinSentenceLen addObject:@"4.0"];
        [instance.arrMinSentenceLen addObject:@"4.5"];
        [instance.arrMinSentenceLen addObject:@"5.0"];
        [instance.arrMinSentenceLen addObject:@"5.5"];
        [instance.arrMinSentenceLen addObject:@"6.0"];
        [instance.arrMinSentenceLen addObject:@"6.5"];
        [instance.arrMinSentenceLen addObject:@"7.0"];
        [instance.arrMinSentenceLen addObject:@"7.5"];
        [instance.arrMinSentenceLen addObject:@"8.0"];
        [instance.arrMinSentenceLen addObject:@"8.5"];
        [instance.arrMinSentenceLen addObject:@"9.0"];
        [instance.arrMinSentenceLen addObject:@"9.5"];
        [instance.arrMinSentenceLen addObject:@"10.0"];
    }
    return instance;
}

- (BOOL)isWiFiConnect
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWiFi)
    {
        return YES;
    }
    
    return NO;
}

- (void)writeToFile {
    
    NSString* pathToConfig;
    
    /*--------------
     환경설정 파일 저장
     ---------------*/
    pathToConfig = [[KSPath shared] documentPath];
    pathToConfig = [pathToConfig stringByAppendingString:@"/Configure.plist"];
    [self.dictToConf writeToFile:pathToConfig atomically:YES];
    
    /*--------------
     히스토리 파일 저장
     ---------------*/
    pathToConfig = [[KSPath shared] documentPath];
    pathToConfig = [pathToConfig stringByAppendingString:@"/PlayingHi.plist"];
    [self.dictToHist writeToFile:pathToConfig atomically:YES];
}

- (BOOL)isSupportedFile:(NSString*)pFileExe {
    pFileExe = [pFileExe uppercaseString];
    return ([pFileExe isEqualToString:@"MP4"] || [pFileExe isEqualToString:@"MOV"] || [pFileExe isEqualToString:@"MP3"] || [pFileExe isEqualToString:@"M4A"]);
}

- (void)copyConfigToDoc {
    
    /*------------
     콘피그 파일 저장
     -------------*/
    NSString* document = [[KSPath shared] documentPath];
    NSString* pathToConfig = [document stringByAppendingString:@"/Configure.plist"];
    BOOL isBePathToCopy = [[KSPath shared] isExistPath:pathToConfig];
    
    if (isBePathToCopy == NO) {
        // COPY CONGIFURATION.PLIST INTO DOC
        [[KSPath shared] copyFileFromBundle:@"Configure.plist"
                                 toDocument:@"Configure.plist"];
        
        /*---------------
         샘플 무비 파일 저장
         ----------------*/
        [[KSPath shared] copyFileFromBundle:@"Sample1 BBC.mp3" toDocument:@"Sample1 BBC.mp3"];
        [[KSPath shared] copyFileFromBundle:@"Sample1 BBC.txt" toDocument:@"Sample1 BBC.txt"];
        [[KSPath shared] copyFileFromBundle:@"Sample2 Grammer.mp3" toDocument:@"Sample2 Grammer.mp3"];
        [[KSPath shared] copyFileFromBundle:@"Sample3 VOA.mp4" toDocument:@"Sample3 VOA.mp4"];
        [[KSPath shared] copyFileFromBundle:@"Sample4 TED.mp4" toDocument:@"Sample4 TED.mp4"];
        [[KSPath shared] copyFileFromBundle:@"Sample5 Conversation.mp4" toDocument:@"Sample5 Conversation.mp4"];
        [[KSPath shared] copyFileFromBundle:@"Sample6 BigBang Theory.mp4" toDocument:@"Sample6 BigBang Theory.mp4"];
        [[KSPath shared] copyFileFromBundle:@"Sample6 BigBang Theory.srt" toDocument:@"Sample6 BigBang Theory.srt"];
        
        /*--------------
         임포트 목록에 포함
         ---------------
        NSString* fileName;
        NSDictionary* dictImport = [[NSUserDefaults standardUserDefaults] objectForKey:@"HISTORY"];
        fileName = [document stringByAppendingPathComponent:@"/Sample1 VOA.mp4"];
        dictImport = [[KSPath shared] setValueToDict:dictImport value:fileName];
        fileName = [document stringByAppendingPathComponent:@"/Sample1 TED.mp4"];
        dictImport = [[KSPath shared] setValueToDict:dictImport value:fileName];
        fileName = [document stringByAppendingPathComponent:@"/Sample3 Conversation.mp4"];
        dictImport = [[KSPath shared] setValueToDict:dictImport value:fileName];
        [[NSUserDefaults standardUserDefaults] setObject:dictImport forKey:@"HISTORY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        임포트가왜마지막것만될까?*/
        
        /*-----------
         샘플 폴더 생성
         ------------*/
        NSString* pathToCreate = [NSString stringWithFormat:@"%@/Folder", [[KSPath shared] documentPath]];
        [[KSPath shared] createDirectory:pathToCreate];
        
        self.isFirstExec = YES;
    }
    
    /*-------------------
     플레이 히스토리 파일 저장
     --------------------*/
    NSString* pathToPlayingHi = [document stringByAppendingString:@"/PlayingHi.plist"];
    isBePathToCopy = [[KSPath shared] isExistPath:pathToPlayingHi];
    if (isBePathToCopy == NO) {
        // COPY CONGIFURATION.PLIST INTO DOC
        [[KSPath shared] copyFileFromBundle:@"PlayingHi.plist"
                                 toDocument:@"PlayingHi.plist"];
    }
}

- (NSString*)trans:(NSString*)pMessage {
    
    // GET LOCAL LANGUAGE
    NSLocale *locale = [NSLocale currentLocale];
    NSString *language = [[locale displayNameForKey:NSLocaleIdentifier
                                              value:[locale localeIdentifier]] uppercaseString];
    
    // NSLog(@"local language: %@", language); /*ENGLISH, 한국어, 中文*/
    if ([language rangeOfString:@"한국어"].location != NSNotFound)
        self.language = [[NSString alloc] initWithFormat:@"KOR"];
    else if ([language rangeOfString:@"中文"].location != NSNotFound)
        self.language = [[NSString alloc] initWithFormat:@"CHN"];
    else self.language = [[NSString alloc] initWithFormat:@"ENG"];
    
    // CALL MENU CORESPONED TO LANGUAGE ENV.
    NSString* keyPath = [NSString stringWithFormat:@"%@.%@", pMessage, self.language];
    NSString* translated = [self.dictToTran valueForKeyPath:keyPath];
    
    if (translated == nil) {
        //NSLog(@"번역오류:%@", pMessage);
        return pMessage;
    }

    translated = [translated stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    return translated;
}

/*-----------------------------------------
 GETTER & SETTER WAITING SEC BEFORE PLAYER
 ------------------------------------------*/
- (float)getWaitingSec
{
    NSString* keyPath = @"WAITING_BEFORE_PLAYING.VALUE";
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    return value.floatValue;
}
- (void)setWaitingSec:(float)pSec
{
    NSString* keyPath = @"WAITING_BEFORE_PLAYING.VALUE";
    NSString* value = [NSString stringWithFormat:@"%.1f", pSec];
    [self.dictToConf setValue:value
                   forKeyPath:keyPath];
}

/*------------------------------
 GETTER & SETTER CAPTION ON-OFF
 -------------------------------*/
- (BOOL)getCaptionOnOFF
{
    NSString* keyPath = @"CAPTION_ONOFF.VALUE";
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    //NSLog(@"자막지원 읽은 값: %@", ([value isEqualToString:@"ON"]) ? @"ON" : @"NO");
    return ([value isEqualToString:@"ON"]) ? YES : NO;
}
- (void)setCaptionOnOFF:(BOOL)pOnOFF
{
    NSString* keyPath = @"CAPTION_ONOFF.VALUE";
    NSString* value = @"OFF";
    if (pOnOFF)
        value = @"ON";
    [self.dictToConf setValue:value
                   forKeyPath:keyPath];
    //NSLog(@"자막지원 지정한 값: %@", value);
}

/*-------------------------------------------
 GETTER & SETTER OF REPEAT INFINITELY ON-OFF
 --------------------------------------------*/
- (BOOL)getRepeatInfiniteOnOff
{
    NSString* keyPath = @"SENTENCE_REPEAT_COUNT.IS_INFINITE";
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    return ([value isEqualToString:@"YES"]) ? YES : NO;
}
- (void)setRepeatInfiniteOnOff:(BOOL)pOnOff
{
    NSString* keyPath = @"SENTENCE_REPEAT_COUNT.IS_INFINITE";
    NSString* value = @"NO";
    if (pOnOff)
        value = @"YES";
    
    [self.dictToConf setValue:value
                   forKeyPath:keyPath];
}

/*--------------------------------
 GETTER & SETTER OF REPEAT ON-OFF
 ---------------------------------*/
- (BOOL)getRepeatOnOff
{
    NSString* keyPath = @"SENTENCE_REPEAT_COUNT.IS_REPEAT";
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    return ([value isEqualToString:@"YES"]) ? YES : NO;
}
- (void)setRepeatOnOff:(BOOL)pOnOff
{
    NSString* keyPath = @"SENTENCE_REPEAT_COUNT.IS_REPEAT";
    NSString* value = @"NO";
    if (pOnOff)
        value = @"YES";

    [self.dictToConf setValue:value
                   forKeyPath:keyPath];
}

/*-------------------------------
 GETTER & SETTER OF REPEAT COUNT
 --------------------------------*/
- (int)getRepeatCount
{
    NSString* keyPath = @"SENTENCE_REPEAT_COUNT.VALUE";
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    if ([value isEqualToString:@"Infinite"])
    {    
        return 0;
    }
    return value.intValue;
}
- (void)setRepeatCount:(int)pCount
{
    NSString* keyPath = @"SENTENCE_REPEAT_COUNT.VALUE";
    if (pCount == 0) {
        [self.dictToConf setValue:@"Infinite" forKeyPath:keyPath];
    } else {
        [self.dictToConf setValue:@(pCount).stringValue forKeyPath:keyPath];
    }
    
    // SET INFINIT ON OR OFF
    [self setRepeatInfiniteOnOff:(pCount == 0)];
    
    // SET REPEAT ON OR OFF
    [self setRepeatOnOff:(pCount == 1)];
}

/*------------------------------------------
 GETTER & SETTER OF MINUMUM SENTENCE SECOND
 -------------------------------------------*/
- (float)getMinimumSenSec
{
    NSString* keyPath = @"MINIMUM_SENTENCE_SECOND.VALUE";
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    return value.floatValue;
}
- (void)setMinimumSenSec:(float)pSec
{
    NSString* keyPath = @"MINIMUM_SENTENCE_SECOND.VALUE";
    [self.dictToConf setValue:@(pSec).stringValue
                   forKeyPath:keyPath];
}

/*---------------------------------------
 GETTER & SETTER OF AFTER END OF PLAYING
 ----------------------------------------*/
- (OPTION_TypeOnPlayEnd)getAfterEndOfPlay
{
    NSString* keyPath = @"AFTER_PLAYING_END.VALUE";
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    if ([value isEqualToString:@"REPEAT"])
        return OPTION_PLY_REPEAT;
    if ([value isEqualToString:@"NEXT"])
        return OPTION_PLY_NEXT;
    return OPTION_PLY_RANDOM;
}
- (void)setAfterEndOfPlay:(OPTION_TypeOnPlayEnd)pNextPlayType;
{
    NSString* keyPath = @"AFTER_PLAYING_END.VALUE";
    NSString* value = @"END";
    if (pNextPlayType == OPTION_PLY_NEXT)
        value = @"NEXT";
    if (pNextPlayType == OPTION_PLY_REPEAT)
        value = @"REPEAT";
    if (pNextPlayType == OPTION_PLY_RANDOM)
        value = @"RANDOM";
    [self.dictToConf setValue:value
                   forKeyPath:keyPath];
}

/*---------------------
 GETTER GESTURE ACTION
 ----------------------*/
- (OPTION_TypeOnGestureAction)getGesture:(OPTION_TypeOnGesture)pGesture
{
    NSString* keyPath;
    if (pGesture == OPTION_GES_SINGLE) {
        keyPath = @"SECTION_GESTURE.ROWS.ROW_0.SUB_SELECTED_ROW";
    }
    if (pGesture == OPTION_GES_DOUBLE) {
        keyPath = @"SECTION_GESTURE.ROWS.ROW_1.SUB_SELECTED_ROW";
    }
    if (pGesture == OPTION_GES_LEFT) {
        keyPath = @"SECTION_GESTURE.ROWS.ROW_2.SUB_SELECTED_ROW";
    }
    if (pGesture == OPTION_GES_RIGHT) {
        keyPath = @"SECTION_GESTURE.ROWS.ROW_3.SUB_SELECTED_ROW";
    }
    if (pGesture == OPTION_GES_UP) {
        keyPath = @"SECTION_GESTURE.ROWS.ROW_4.SUB_SELECTED_ROW";
    }
    if (pGesture == OPTION_GES_DOWN) {
        keyPath = @"SECTION_GESTURE.ROWS.ROW_5.SUB_SELECTED_ROW";
    }
    //NSLog(@"KEYPATH: %@", keyPath);
    
    NSString* value = [self.dictToConf valueForKeyPath:keyPath];
    //NSLog(@"VALUE: %@", value);
    if ([value isEqualToString:@"ROW_0"])
        return OPTION_GAT_NONE;
    if ([value isEqualToString:@"ROW_1"])
        return OPTION_GAT_PLAY;
    if ([value isEqualToString:@"ROW_2"])
        return OPTION_GAT_PREV;
    if ([value isEqualToString:@"ROW_3"])
        return OPTION_GAT_NEXT;
    if ([value isEqualToString:@"ROW_4"])
        return OPTION_GAT_PASS;
    if ([value isEqualToString:@"ROW_5"])
        return OPTION_GAT_MENU;
    if ([value isEqualToString:@"ROW_6"])
        return OPTION_GAT_BACK;
    if ([value isEqualToString:@"ROW_7"])
        return OPTION_GAT_SAME;
    
    return OPTION_GAT_NONE;
}

/*------------------------------
 SAVE CURRENT FILE INTO HISTORY
 -------------------------------*/
- (void)insertIntoHistory:(NSString*)pFilePath currSec:(float)pCurrSec; {
    
    /*--------------------------------------------
     도큐먼트 앞 부분은 변경되기 때문에 그 이후부분부터 저장한다
     ---------------------------------------------*/
    NSArray* arrTemp = [pFilePath componentsSeparatedByString:@"/Documents/"];
    if (arrTemp.count > 1)
        pFilePath = [arrTemp objectAtIndex:1];
    
    NSString* sec = [NSString stringWithFormat:@"%.1f", pCurrSec];
    
    [self.dictToHist setValue:sec forKey:pFilePath];
}
- (float)secFromHistory:(NSString*)pFilePath {
    
    NSArray* arrTemp = [pFilePath componentsSeparatedByString:@"/Documents/"];
    if (arrTemp.count > 1)
        pFilePath = [arrTemp objectAtIndex:1];
    
    NSString* sec = [self.dictToHist valueForKeyPath:pFilePath];
    if (sec) {
        //NSLog(@"히스토리에서 발견함: %@", self.dictToHist);
        return sec.floatValue;
    }
    
    //NSLog(@"히스토리에서 발견 못함: %@", self.dictToHist);
    
    return 0.0;
}
- (void)clearHistoryGabage {
    NSArray* arrKey = [self.dictToHist allKeys];
    
    /*-------------------------------
     키네임은 도큐먼트 이하 경로를 가지고 있다
     --------------------------------*/
    NSString* fullPath;
    
    for (NSInteger i = 0; i < arrKey.count; i++) {
        
        fullPath = [NSString stringWithFormat:@"%@/%@",
                    [[KSPath shared] documentPath],
                    [arrKey objectAtIndex:i]];
        
        if ([[KSPath shared] isExistPath:fullPath])
            continue;
        
        [self.dictToHist removeObjectForKey:[arrKey objectAtIndex:i]];
    }
}
- (void)removeFromHistory:(NSString*)pFilePath {
    // 실행시마다 설치홈 폴더가 변경된다
    NSArray* arrTemp = [pFilePath componentsSeparatedByString:@"/Documents/"];
    if (arrTemp.count > 1)
        pFilePath = [arrTemp objectAtIndex:1];
    
    //NSLog(@"삭제 전: %@", pFilePath);
    [self.dictToHist removeObjectForKey:pFilePath];
    //NSLog(@"삭제 후: %@", self.dictToHist);
    [self writeToFile];
}

/*---------------------------------
 SAVE CURRENT FILE AS A LATEST ONE
 ----------------------------------*/
- (void)setRecentPlaying:(NSString*)pFilePath
                fileSize:(NSString*)pFileSize
                curreSec:(float)pCurreSec
                totalSec:(float)pTotalSec
{
    [self setRecentFile:pFilePath];
    
    NSString* currSec = [NSString stringWithFormat:@"%.1f", pCurreSec];
    NSString* totaSec = [NSString stringWithFormat:@"%.1f", pTotalSec];
    
    [self.dictToConf setValue:pFileSize forKeyPath:@"LATEST_MOVIE.FILE_SIZE"];
    [self.dictToConf setValue:currSec forKeyPath:@"LATEST_MOVIE.CURRENT_TIME"];
    [self.dictToConf setValue:totaSec forKeyPath:@"LATEST_MOVIE.TOTAL_TIME"];
}

- (void)setRecentFile:(NSString*)pFilePath
{
    // 저장할 때마다 경로가 바뀌기 때문에 변화되는 앞 부분은 제외한다
    // NSLog(@"현재재생 시간 지정: %@", pCurreSec);
    NSArray* arrTemp = [pFilePath componentsSeparatedByString:@"/Documents/"];
    if (arrTemp.count > 1)
        pFilePath = [arrTemp objectAtIndex:1];
    [self.dictToConf setValue:pFilePath forKeyPath:@"LATEST_MOVIE.FILE_PATH"];
}

- (void)getRecentPlaying:(NSString**)pFilePath
                fileSize:(NSString**)pFileSize
              currentSec:(NSString**)pCurreSec
                totalSec:(NSString**)pTotalSec
{
    NSString* pathFromConfig = [self getRecentFile];
    *pFilePath = [NSString stringWithFormat:@"%@", pathFromConfig];
    *pFileSize = [self.dictToConf valueForKeyPath:@"LATEST_MOVIE.FILE_SIZE"];
    *pCurreSec = [self.dictToConf valueForKeyPath:@"LATEST_MOVIE.CURRENT_TIME"];
    *pTotalSec = [self.dictToConf valueForKeyPath:@"LATEST_MOVIE.TOTAL_TIME"];
}

- (NSString*)getRecentFile
{
    NSString* pathFromConfig = [NSString stringWithFormat:@"%@/%@",
                                [[KSPath shared] documentPath],
                                [self.dictToConf valueForKeyPath:@"LATEST_MOVIE.FILE_PATH"]];
    
    if ([[self.dictToConf valueForKeyPath:@"LATEST_MOVIE.FILE_PATH"] isEqualToString:@""])
        pathFromConfig = @"";
    
    return pathFromConfig;
}

- (float)getRecentSec
{
    NSString* playingSec = [self.dictToConf valueForKeyPath:@"LATEST_MOVIE.CURRENT_TIME"];
    return playingSec.floatValue;
}
- (BOOL)isBeingRecentFile
{
    NSString* recentFile = [self getRecentFile];
    if ([recentFile isEqualToString:@""])
        return NO;
    
    return [[KSPath shared] isExistPath:recentFile];
}

/*----------------------------------
 CHANGE TOTAL SECONS TO TIME-FORMAT
 -----------------------------------*/
- (NSString*)timeFormatted:(int)totalSeconds
{
    // CONVERT SECONDS
    // TO 00:00:00 TIME FORMAT
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours > 0)
        return [NSString stringWithFormat:@"%d:%02d:%02d",
                hours, minutes, seconds];
    return [NSString stringWithFormat:@"%02d:%02d",
            minutes, seconds];
}

- (float)timeFormattedToSec:(NSString*)pTimeFormat
{
    int h = 0, m = 0, s = 0;
    
    // 00:00:00 (TIME FORMAT)
    NSArray* arrTime = [pTimeFormat componentsSeparatedByString:@":"];
    if (arrTime.count > 0)
        h = [[arrTime objectAtIndex:0] intValue];
    if (arrTime.count > 1)
        m = [[arrTime objectAtIndex:1] intValue];
    if (arrTime.count > 2)
        s = [[arrTime objectAtIndex:2] intValue];
    
    float totalSeconds = (60*60*h) + (60*m) + s;
    return totalSeconds;
}

@end
