//
//  KSPath.h
//  repeater
//
//  Created by admin on 2015. 12. 27..
//  Copyright © 2015년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileInfo.h"

@interface KSPath : NSObject {
    
}

+(KSPath*)shared;

-(NSString*)bundlePath;
-(NSString*)documentPath;

- (void)makeDummy;

- (FileInfo*)createFileInfoObject:(NSString*)pFilePath;

- (float)duration:(NSString*)pVideoFile;
- (NSString *)getFileSize:(NSString*)pFilePath;
- (NSString *)getFileCreated:(NSString*)pFilePath;
- (NSDate *)getFileCreatedRaw:(NSString*)pFilePath;

/*--------------------------------
 RETURN FILE COUNT AND DIR COUNT
 ---------------------------------*/
- (void)fileCountInDirectory:(NSString*)pDirPath
                refFileCount:(NSString**)pFileCount
                 refDirCount:(NSString**)pDirCount;

/*---------------------------------------------
 RETURN ONLY FILE LIST FROM CURRENT DIR (SORTED)
 ----------------------------------------------*/
- (NSDictionary*)filelistSorted:(NSString*)pDirPath;
- (NSDictionary*)listFromDocumentByOrder:(NSString*)pPath;

- (NSDictionary*)listOfFileFromDocument:(NSString*)pPath;
- (NSDictionary*)listOfDirectoryFromDocument:(NSString*)pPath;
- (NSDictionary*)listOfDirectoryFromDocumentByRecusive;
- (NSDictionary*)listOfFileFromDocument:(NSString *)pPath extention:(NSString*)pExtention;

- (NSString*)tempDirFrom:(NSString*)pFilePath makeOption:(BOOL)pMakeOption;

- (NSString*)newPathIfAlreadyExist:(NSString*)pPath;

- (BOOL)isDirectory:(NSString*)pPath;

/*-------------------------------
 GET FILE LIST WITH WILDCARD "*"
 --------------------------------*/
- (NSArray*)findFileByWildCard:(NSString*)pWildCard inDir:(NSString*)pDir;

- (BOOL)deleteFile:(NSString*)pPath;
- (BOOL)isExistPath:(NSString*)pPath;
- (BOOL)createDirectory:(NSString*)pPath;
- (BOOL)copyFile:(NSString*)pSourcePath targetPath:(NSString*)pTargetPath;
- (BOOL)moveFile:(NSString*)pSourcePath targetPath:(NSString*)pTargetPath;
- (BOOL)copyFileFromBundle:(NSString*)pBundlePath toDocument:(NSString*)pToDocumentPath;

/*----------
 URL ENCODE
 -----------*/
- (NSString*)encoded:(NSString*)pStr;

/*---------------------
 CHANGE FILE EXTENTION
 ----------------------*/
-(NSString*)changeFileNameByNewExt:(NSString*)pFileName newExt:(NSString*)pNewExtent;

/*--------------------------
 DELETE ALL TEMP .M4A FILE
 ---------------------------*/
-(void)deleteAllTempRedcorded;

- (NSDictionary*)deletedObject:(NSDictionary*)pDict value:(NSString*)pValue;
- (NSDictionary*)changeValue:(NSDictionary*)pDict
                    oldValue:(NSString*)pOldValue
                    newValue:(NSString*)pNewValue;
- (NSDictionary*)setValueToDict:(NSDictionary*)pDict value:(NSString*)pValue;
@end
