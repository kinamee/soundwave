//
//  KSPath.m
//  repeater
//
//  Created by admin on 2015. 12. 27..
//  Copyright © 2015년 admin. All rights reserved.
//

#import "KSPath.h"
#import <AVFoundation/AVFoundation.h>

static KSPath* instance = nil;

#define NSStringFromBOOL(aBOOL) aBOOL? @"YES" : @"NO"

@implementation KSPath

+(KSPath*)shared {
    if (instance == nil) {
        instance = [[KSPath alloc] init];
        //NSLog(@"DOCUMENT PATH:%@", [instance documentPath]);
    }
    return instance;
}

- (NSDictionary*)setValueToDict:(NSDictionary*)pDict value:(NSString*)pValue
{    
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionaryWithDictionary:pDict];
    NSArray* arrKeyToDict = [dictToRet.allKeys sortedArrayUsingSelector:
                             @selector(localizedCaseInsensitiveCompare:)];
    //NSLog(@"날짜별로 정렬: %@", arrKeyToDict);
    
    for (NSInteger i = 0; i < arrKeyToDict.count; i ++)
    {
        NSString* key = [arrKeyToDict objectAtIndex:i];
        NSString* filePath = [dictToRet objectForKey:key];
        if ([filePath.uppercaseString isEqualToString:pValue.uppercaseString])
            [dictToRet removeObjectForKey:key];
        
        if (i > 15)
            [dictToRet removeObjectForKey:key];
    }
    
    /*---------------------------
     DATE TIME FOR NEW FILE NAME
     ----------------------------*/
    NSDate *date = [NSDate date];
    NSInteger era, year, month, day, hour, min, sec;
    [[NSCalendar currentCalendar] getEra:&era year:&year month:&month day:&day fromDate:date];
    [[NSCalendar currentCalendar] getHour:&hour minute:&min second:&sec nanosecond:nil fromDate:date];
    
    /*----------------------------
     MOVIE NAME FOR NEW FILE NAME
     -----------------------------*/
    NSString* newKey = [NSString stringWithFormat:@"%li%02li%02li-%02li%02li%02li",
                        year, month, day, hour, min, sec];
    
    [dictToRet setValue:pValue forKey:newKey];
    
    return dictToRet;
}

- (NSDictionary*)changeValue:(NSDictionary*)pDict
                         oldValue:(NSString*)pOldValue
                         newValue:(NSString*)pNewValue
{
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionaryWithDictionary:pDict];
    NSArray* arrKeyToDict = [dictToRet.allKeys sortedArrayUsingSelector:
                             @selector(localizedCaseInsensitiveCompare:)];
    
    for (NSInteger i = 0; i < arrKeyToDict.count; i ++)
    {
        NSString* key = [arrKeyToDict objectAtIndex:i];
        NSString* value = [dictToRet objectForKey:key];
        if ([value.uppercaseString isEqualToString:pOldValue.uppercaseString])
        {
            [dictToRet removeObjectForKey:key];
            [dictToRet setValue:pNewValue forKey:key];
        }
    }
    
    return dictToRet;
}

- (NSDictionary*)deletedObject:(NSDictionary*)pDict value:(NSString*)pValue
{
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionaryWithDictionary:pDict];
    NSArray* arrKeyToDict = [dictToRet.allKeys sortedArrayUsingSelector:
                             @selector(localizedCaseInsensitiveCompare:)];
    
    for (NSInteger i = 0; i < arrKeyToDict.count; i ++)
    {
        NSString* key = [arrKeyToDict objectAtIndex:i];
        NSString* value = [dictToRet objectForKey:key];
        if ([pValue.uppercaseString isEqualToString:value.uppercaseString])
        {
            [dictToRet removeObjectForKey:key];
        }
    }
    
    return dictToRet;
}

/*----------------------------------------------------
 GET DURATION. IF THE FILE IS NOT PLAYABLE RETURN NIL
 -----------------------------------------------------*/
- (float)duration:(NSString*)pVideoFile
{
    //NSLog(@"길이확인중 경로: %@", ([self isExistPath:pVideoFile])?@"정상":@"오류");
    
    NSURL* urlPath = [NSURL fileURLWithPath:pVideoFile];
        
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:urlPath options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

- (NSString *)getFileSize:(NSString*)pFilePath {
    // GET FILE ATTRIBUTE
    NSError* error;
    NSDictionary *attribs = [[NSFileManager defaultManager]
                             attributesOfItemAtPath:pFilePath error: &error];
    if (error)
        NSLog(@"FILE SIZE ERROR: %@", error);
    
    NSNumber *fileSizeNumber = [attribs objectForKey:NSFileSize];
    unsigned long long fileSize = [fileSizeNumber longLongValue];
    NSString* convertedSize = [self stringFromFileSize:fileSize];
    return convertedSize;
}

- (NSDate *)getFileCreatedRaw:(NSString*)pFilePath {
    // GET FILE ATTRIBUTE
    NSDictionary *attribs = [[NSFileManager defaultManager]
                             attributesOfItemAtPath:pFilePath error: NULL];
    
    NSDate *creationDate = [attribs objectForKey:NSFileCreationDate];
    return creationDate;
}

- (NSString *)getFileCreated:(NSString*)pFilePath {
    // GET FILE ATTRIBUTE
    NSDictionary *attribs = [[NSFileManager defaultManager]
                             attributesOfItemAtPath:pFilePath error: NULL];
    
    NSDate *creationDate = [attribs objectForKey:NSFileCreationDate];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd-MM-yyyy"];
    NSString *dateCreated = [dateformate stringFromDate:creationDate];
    return dateCreated;
}

- (NSString *)stringFromFileSize:(long long)theSize
{
    
    float floatSize = theSize;
    if (theSize<1023)
        return([NSString stringWithFormat:@"%lli bytes",theSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
    floatSize = floatSize / 1024;
    
    return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

/*---------------------------------------------
 RETURN ONLY FILE LIST FROM CURRENT DIR (SORTED)
 ----------------------------------------------*/
- (NSDictionary*)filelistSorted:(NSString*)pDirPath;
{
    NSDictionary* dictFile = [self listOfFileFromDocument:pDirPath];
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionary];
    
    NSArray *arrFile = [[dictFile allKeys] sortedArrayUsingSelector:
                        @selector(localizedCaseInsensitiveCompare:)];
    for (int i = 0; i < arrFile.count; i++) {
        NSString* key = [arrFile objectAtIndex:i];
        FileInfo* fifo = [dictFile objectForKey:key];
        
        NSString* newKey = [NSString stringWithFormat:@"%li", [dictToRet count]];
        [dictToRet setValue:fifo forKey:newKey];
    }
    
    return dictToRet;
}

- (NSDictionary*)listOfFileFromDocument:(NSString *)pPath extention:(NSString*)pExtention
{
    NSDictionary* dict = [self listFromDocument:pPath];
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionary];
    
    for (NSString* key in dict) {
        FileInfo* fifo = [dict objectForKey:key];
        if (fifo.isTypeOfDir == NO) {
            if ([fifo.fileExtention.uppercaseString isEqualToString:pExtention.uppercaseString])
                [dictToRet setValue:fifo forKey:key];
        }
    }
    //NSLog(@"LIST FILE: %@", dictToRet);
    return dictToRet;
}

- (NSDictionary*)listOfFileFromDocument:(NSString *)pPath {
    NSDictionary* dict = [self listFromDocument:pPath];
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionary];
    
    for (NSString* key in dict) {
        FileInfo* fifo = [dict objectForKey:key];
        if (fifo.isTypeOfDir == NO) {
            if ([fifo.fileExtention.uppercaseString isEqualToString:@"MP4"] ||
                [fifo.fileExtention.uppercaseString isEqualToString:@"M4A"] ||
                [fifo.fileExtention.uppercaseString isEqualToString:@"MP3"] ||
                //[fifo.fileExtention.uppercaseString isEqualToString:@"TXT"] ||
                [fifo.fileExtention.uppercaseString isEqualToString:@"MOV"])
                [dictToRet setValue:fifo forKey:key];
        }
    }
    //NSLog(@"LIST FILE: %@", dictToRet);
    return dictToRet;
}

- (NSDictionary*)listOfDirectoryFromDocument:(NSString *)pPath {
    NSDictionary* dict = [self listFromDocument:pPath];
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionary];
    
    for (NSString* key in dict) {
        FileInfo* fifo = [dict objectForKey:key];
        if (fifo.isTypeOfDir)
        if (![fifo.fileNameOnly.uppercaseString isEqualToString:@"_REC"])
        if (![fifo.fileNameOnly.uppercaseString isEqualToString:@"_TMP"])
        if (![fifo.fileNameOnly.uppercaseString isEqualToString:@"_WEB"])
        if (![fifo.fileNameOnly.uppercaseString isEqualToString:@"INBOX"])
            [dictToRet setValue:fifo forKey:key];
        
    }
    //NSLog(@"LIST DIRECTORY: %@", dictToRet);
    return dictToRet;
}

- (NSDictionary*)listFromDocumentByOrder:(NSString*)pPath {
    NSDictionary* dictFile = [self listOfFileFromDocument:pPath];
    NSDictionary* dictDire = [self listOfDirectoryFromDocument:pPath];
    
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionary];
    
    /*-------------------
     SORT DIRECTORY LIST
     --------------------*/
    NSArray *arrDirectory = [[dictDire allKeys] sortedArrayUsingSelector:
                             @selector(localizedCaseInsensitiveCompare:)];
    for (int i = 0; i < arrDirectory.count; i++) {
        NSString* key = [arrDirectory objectAtIndex:i];
        FileInfo* fifo = [dictDire objectForKey:key];
        
        NSString* newKey = [NSString stringWithFormat:@"%li", [dictToRet count]];
        [dictToRet setValue:fifo forKey:newKey];
    }
    
    /*--------------
     SORT FILE LIST
     ---------------*/
    NSArray *arrFile = [[dictFile allKeys] sortedArrayUsingSelector:
                        @selector(localizedCaseInsensitiveCompare:)];
    for (int i = 0; i < arrFile.count; i++) {
        NSString* key = [arrFile objectAtIndex:i];
        FileInfo* fifo = [dictFile objectForKey:key];
        
        NSString* newKey = [NSString stringWithFormat:@"%li", [dictToRet count]];
        [dictToRet setValue:fifo forKey:newKey];
    }
    
    return dictToRet;
}

- (NSDictionary*)listOfDirectoryFromDocumentByRecusive {
    NSString *docRoot = [self documentPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:docRoot];
    NSString *filePathName;
    
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionary];
    
    while ((filePathName = [direnum nextObject] )) {
        NSString* fullFilePathName = [NSString stringWithFormat:@"%@/%@",
                                      docRoot, filePathName];
        BOOL isDirectory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:fullFilePathName
                                                  isDirectory:&isDirectory]) {
            NSLog(@"PATH ERROR:%@", fullFilePathName);
            continue;
        }
        if (!isDirectory) continue;
        if ([filePathName.uppercaseString containsString:@"_REC"])
            continue;
        if ([filePathName.uppercaseString containsString:@"_TMP"])
            continue;
        if ([filePathName.uppercaseString containsString:@"_WEB"])
            continue;
        if ([filePathName.uppercaseString containsString:@"INBOX"])
            continue;
        
        NSString* keyName = [NSString stringWithFormat:@"%li", dictToRet.count +1];
        [dictToRet setValue:fullFilePathName forKey:keyName];
    }
    
    [dictToRet setValue:docRoot forKey:@"0"];
    
    return dictToRet;
}

/*---------------------
 CHANGE FILE EXTENTION
 ----------------------*/
-(NSString*)changeFileNameByNewExt:(NSString*)pFileName newExt:(NSString*)pNewExtent
{
    NSString* newFileName = [pFileName stringByDeletingPathExtension];
    newFileName = [newFileName stringByAppendingFormat:@".%@", pNewExtent];
    newFileName = [newFileName stringByReplacingOccurrencesOfString:@".." withString:@"."];
    return newFileName;
}

/*--------------------------------
 RETURN FILE COUNT AND DIR COUNT
 ---------------------------------*/
- (void)fileCountInDirectory:(NSString*)pDirPath
                refFileCount:(NSString**)pFileCount
                 refDirCount:(NSString**)pDirCount {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:pDirPath];
    
    NSInteger countDire = 0;
    NSInteger countFile = 0;
    NSString* fullPath = @"";
    
    while (fullPath = [direnum nextObject])
    {
        if ([[fullPath lastPathComponent] hasPrefix:@"."])
            continue;

        fullPath = [NSString stringWithFormat:@"%@/%@", pDirPath, fullPath];
        
        if ([fullPath.uppercaseString containsString:@"_TMP"] ||
            [fullPath.uppercaseString containsString:@".TXT"] ||
            [fullPath.uppercaseString containsString:@".SRT"])
            continue;
        
        BOOL isDirectory = FALSE;
        [[NSFileManager defaultManager] fileExistsAtPath:fullPath
                                             isDirectory:&isDirectory];
        if (isDirectory) {
            countDire++;
        } else {
            countFile++;
        }
    }
    
    *pDirCount  = @(countDire).description;
    *pFileCount = @(countFile).description;
}

- (NSDictionary*)listFromDocument:(NSString*)pPath {

    if ([pPath hasSuffix:@"/"])
        pPath = [pPath substringToIndex:pPath.length - 1];

    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString* pathForURL = [pPath stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    NSMutableDictionary* retDict = [NSMutableDictionary dictionary];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL* pathToEnum = [NSURL URLWithString:pathForURL];
    NSDirectoryEnumerator *dirEnumerator = [manager enumeratorAtURL:pathToEnum
                                         includingPropertiesForKeys:@[ NSURLNameKey, NSURLIsDirectoryKey ]
                                                            options:
                                            NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                       errorHandler:nil];

    NSString *fileFullPath;
    NSString *fileName;
    
    for (NSURL *theURL in dirEnumerator) {
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        if ([fileName.lastPathComponent hasPrefix:@"."])
            continue;
        
        fileFullPath = [NSString stringWithFormat:@"%@/%@", pPath, fileName];
        FileInfo* fifo = [self createFileInfoObject:fileFullPath];
        
        [retDict setValue:fifo forKey:fileName];
    }
    return retDict;
}

- (FileInfo*)createFileInfoObject:(NSString*)pFilePath
{
    FileInfo* fifo = [[FileInfo alloc] init];
    fifo.fileNameFull = pFilePath;
    fifo.fileNameOnly = [pFilePath lastPathComponent];
    fifo.directoryPath = [pFilePath stringByDeletingLastPathComponent];
    fifo.fileExtention = [pFilePath pathExtension];
    fifo.fileSize = [[KSPath shared] getFileSize:pFilePath];
    fifo.isTypeOfDir = [[KSPath shared] isDirectory:pFilePath];
    fifo.dateCreated = [[KSPath shared] getFileCreated:pFilePath];
    fifo.dateCreatedRaw = [[KSPath shared] getFileCreatedRaw:pFilePath];
    //fifo.durationSec = [fifo durationSec];
    //fifo.durationTimeFormatted = [fifo durationTimeFormatted];
    return fifo;
}

- (void)makeDummy {
    if (![self isExistPath:@"Dummy1"]) {
        [self createDirectory:@"Dummy1"];
        [self createDirectory:@"Dummy1/Dummy2"];
    }
    
    if (![self isExistPath:@"Configure.plist"]) {
        [self copyFileFromBundle:@"Configure.plist" toDocument:@"Configure.plist"];
        [self copyFileFromBundle:@"Configure.plist" toDocument:@"file1.dat"];
        [self copyFileFromBundle:@"Configure.plist" toDocument:@"file2.dat"];
        [self copyFileFromBundle:@"Configure.plist" toDocument:@"file3.dat"];
        
        [self copyFileFromBundle:@"Configure.plist" toDocument:@"Dummy1/file4.dat"];
        [self copyFileFromBundle:@"Configure.plist" toDocument:@"Dummy1/Dummy2/file5.dat"];
    }
    
    [self copyFileFromBundle:@"Info.plist" toDocument:@"Info.plist"];
    [self copyFileFromBundle:@"Sample movie.mp4" toDocument:@"Sample movie.mp4"];
}

-(NSString*)bundlePath {
    NSString* retPath = [[NSBundle mainBundle] bundlePath];
    return retPath;
}

-(NSString*)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *retPath = [paths objectAtIndex:0];
    return retPath;
}

- (BOOL)moveFile:(NSString*)pSourcePath targetPath:(NSString*)pTargetPath {
    NSError *err = nil;
    if([[NSFileManager defaultManager] moveItemAtPath:pSourcePath
                            toPath:pTargetPath error:&err])
        return YES;
    
    NSString* extention = pSourcePath.pathExtension;
    NSString* changeExt = [[KSPath shared] changeFileNameByNewExt:pSourcePath
                                                           newExt:extention.lowercaseString];
    if([[NSFileManager defaultManager] moveItemAtPath:changeExt
                                               toPath:pTargetPath error:&err])
        return YES;
    
    changeExt = [[KSPath shared] changeFileNameByNewExt:pSourcePath
                                                 newExt:extention.lowercaseString];
    if([[NSFileManager defaultManager] moveItemAtPath:changeExt
                                               toPath:pTargetPath error:&err])
        return YES;
    
    NSLog(@"Error: %@ %li %@", [err domain], [err code], [[err userInfo] description]);    
    NSLog(@"ERROR IN MOVING FILE: %@, %@", pSourcePath, pTargetPath);
    return NO;
}

- (BOOL)copyFileFromBundle:(NSString*)pBundlePath toDocument:(NSString*)pToDocumentPath {
    NSString *docBun = [self bundlePath];
    NSString *docDir = [self documentPath];
    NSMutableString* sourcePath = (NSMutableString*)[docBun stringByAppendingPathComponent:pBundlePath];
    NSMutableString* targetPath;
    if ([pToDocumentPath isEqualToString:@""])
        targetPath = [NSMutableString stringWithString:pToDocumentPath];
    targetPath = (NSMutableString*)[docDir stringByAppendingPathComponent:pToDocumentPath];
    
    NSError *err = nil;
    if ([[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                                toPath:targetPath error:&err])
        return YES;
    
    NSLog(@"ERROR IN COPYING FILE FROM BUNDLE: %@, %@", sourcePath, targetPath);
    NSLog(@"Error: %@ %li %@", [err domain], [err code], [[err userInfo] description]);
    return NO;
}

- (BOOL)copyFile:(NSString*)pSourcePath targetPath:(NSString*)pTargetPath {
    
    NSError *err = nil;
    if ([[NSFileManager defaultManager] copyItemAtPath:pSourcePath
                            toPath:pTargetPath error:&err])
        return YES;
    
    NSLog(@"ERROR IN COPYING FILE: %@, %@", pSourcePath, pTargetPath);
    NSLog(@"Error: %@ %li %@", [err domain], [err code], [[err userInfo] description]);
    return NO;
}

- (BOOL)deleteFile:(NSString*)pPath {
    NSError *err = nil;
    if ([[NSFileManager defaultManager] removeItemAtPath:pPath error:&err])
        return YES;
    
    NSString* extention = pPath.pathExtension;
    NSString* changeExt = [[KSPath shared] changeFileNameByNewExt:pPath
                                                           newExt:extention.lowercaseString];
    if ([[NSFileManager defaultManager] removeItemAtPath:changeExt error:&err])
        return YES;
    
    changeExt = [[KSPath shared] changeFileNameByNewExt:pPath
                                                 newExt:extention.lowercaseString];
    if ([[NSFileManager defaultManager] removeItemAtPath:changeExt error:&err])
        return YES;
    
    NSLog(@"ERROR IN DELETING FILE: %@", pPath);
    NSLog(@"Error: %@ %li %@", [err domain], [err code], [[err userInfo] description]);
    return NO;
}

/*--------------------------
 DELETE ALL TEMP .M4A FILE
 ---------------------------*/
-(void)deleteAllTempRedcorded {
    NSString* wildExp = @"*rec_*m4a";
    NSArray* arrFileToDel = [[KSPath shared] findFileByWildCard:wildExp
                                                          inDir:[self documentPath]];
    // NSLog(@"함께 지울 파일들: %@", arrFileToDel);
    for (int j = 0; j < arrFileToDel.count; j++)
    {
        NSString* fileToDelete = [NSString stringWithFormat:@"%@/_rec/_tmp/%@",
                                  [self documentPath], [arrFileToDel objectAtIndex:j]];
        [[KSPath shared] deleteFile:fileToDelete];
    }
}

- (BOOL)isExistPath:(NSString*)pPath
{
    if (!pPath) return NO;
    if ([pPath isEqualToString:@""]) return NO;

    if ([[NSFileManager defaultManager] fileExistsAtPath:pPath] == YES)
        return YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pPath.lowercaseString] == YES)
        return YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pPath.uppercaseString] == YES)
        return YES;
    
    NSString* extention = pPath.pathExtension;
    NSString* changeExt = [[KSPath shared] changeFileNameByNewExt:pPath
                                                           newExt:extention.uppercaseString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:changeExt] == YES)
        return YES;
    
    changeExt = [[KSPath shared] changeFileNameByNewExt:pPath
                                                 newExt:extention.lowercaseString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:changeExt] == YES)
        return YES;
    
    return NO;
}

- (BOOL)createDirectory:(NSString*)pPath {
    NSError *err;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:pPath withIntermediateDirectories:NO attributes:nil error:&err])
        return YES;
    
    NSLog(@"ERROR IN CREATE DIRECTORY: %@", pPath);
    NSLog(@"Error: %@ %li %@", [err domain], [err code], [[err userInfo] description]);
    return NO;
}

- (BOOL)isDirectory:(NSString*)pPath
{
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:pPath isDirectory:&isDirectory];
    if (isDirectory)
        return YES;
    else return NO;
}

// GET TEMP DIRECTORY PATH
// If NOT EXIST, CREATE THE DIRECTORY
- (NSString*)tempDirFrom:(NSString*)pFilePath makeOption:(BOOL)pMakeOption {
    
    // PARAMETER IS DIRECTORY? THEN JUST ADD /_tmp
    if ([self isDirectory:pFilePath])
        pFilePath = [NSString stringWithFormat:@"%@/dumy.exe", pFilePath];
    
    NSString* dirPath = [pFilePath stringByDeletingLastPathComponent];
    NSString* tempDirPath = [NSString stringWithFormat:@"%@/_tmp", dirPath];
    if ([tempDirPath hasPrefix:@"//"])
        tempDirPath = [tempDirPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];

    BOOL isExistTempDir = [self isExistPath:tempDirPath];
    if (!isExistTempDir)
        if (pMakeOption)
            [self createDirectory:tempDirPath];
    
    return tempDirPath;
}

- (NSString*)newPathIfAlreadyExist:(NSString*)pPath
{
    BOOL isExist = [self isExistPath:pPath];
    if (!isExist)
        return pPath;
    
    // SEPERATE FILE EXTENTION
    NSString* fileName = [pPath substringToIndex:pPath.length - 4];
    NSString* extention = [pPath substringFromIndex:pPath.length - 3];
    
    for (int i = 1; i < 1000; i++) {
        NSString* newPath = [NSString stringWithFormat:@"%@(%i).%@", fileName, i, extention];
        if (![self isExistPath:newPath])
        {
            return newPath;
        }
    }
    return pPath;
}

/*-------------------------------
 GET FILE LIST WITH WILDCARD "*"
 --------------------------------*/
- (NSArray*)findFileByWildCard:(NSString*)pWildCard inDir:(NSString*)pDir
{    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:pDir error:nil];
    
    // NSString *match = @"imagexyz*.png";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", pWildCard];
    NSArray *arrFile = [dirContents filteredArrayUsingPredicate:predicate];
    
    return arrFile;
}

/*----------
 URL ENCODE
 -----------*/
- (NSString*)encoded:(NSString*)pStr {
    
    pStr = [pStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    pStr = [pStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];

    return pStr;
}

@end
