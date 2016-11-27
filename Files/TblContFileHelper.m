//
//  TblContForFileHelper.m
//  repeater
//
//  Created by admin on 2016. 1. 29..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContFileHelper.h"
#import "UIAlertController+Blocks.h"
#import "Config.h"
#import "KSPath.h"
#import "FileInfo.h"

static TblContFileHelper* instance = nil;

@implementation TblContFileHelper

+(TblContFileHelper*)shared;
{
    if (instance == nil) {
        instance = [[TblContFileHelper alloc] init];
    }
    return instance;
}

/*-------------
 REFRESH TABLE
 --------------*/
- (void)refreshTable
{
    TblContFile* controller = self.needHelp;
    [controller refreshDataInTable];
}

/*---------------------------------
 INITIALIZE ALL BUTTONS AS DISABLE
 ----------------------------------*/
- (void)changeButtonStateOfAll:(BOOL)pYesOrNo;
{
    TblContFile* controller = self.needHelp;
    
    controller.btnOpenAs.enabled = pYesOrNo;
    controller.btnMoveFile.enabled = pYesOrNo;
    controller.btnRenameFile.enabled = pYesOrNo;
    controller.btnDeleteFile.enabled = pYesOrNo;
}

/*----------------------------
 CHANGE THE EDIT-BUTTON STATE
 -----------------------------*/
- (void)changeButtonState:(NSDictionary*)pDictOfSelected
{
    //NSLog(@"에디트버튼 활성화 조정: %li", pDictOfSelected.count);
    
    TblContFile* controller = self.needHelp;
    // DISABLE ALL EDIT BUTTONS
    [self changeButtonStateOfAll:NO];
    
    /*------------------
     IS 1 ROW SELECTED?
     -------------------*/
    if (pDictOfSelected.count == 1)
    {
        [self changeButtonStateOfAll:YES];
    }
    
    /*----------------------------
     IS MORE THAN 1 ROW SELECTED?
     -----------------------------*/
    if (pDictOfSelected.count > 1)
    {
        controller.btnMoveFile.enabled = YES;
        controller.btnDeleteFile.enabled = YES;
    }
    
    /*---------------------------------
     CHECK IS THERE SELECTED DIRECTORY
     ----------------------------------*/
    NSArray* arrKey = [pDictOfSelected allKeys];
    for (int i = 0; i < pDictOfSelected.count; i++)
    {
        NSString* key = [arrKey objectAtIndex:i];
        FileInfo* fifo = [pDictOfSelected valueForKey:key];
        
        if (fifo.isTypeOfDir)
            controller.btnMoveFile.enabled = NO;
        
        if (![[Config shared] isSupportedFile:fifo.fileNameFull.pathExtension])
            controller.btnOpenAs.enabled = NO;
    }
}

/*----------------------------------
 CHECK ALL DIGITS IS NEMERIC OR NOT
 -----------------------------------*/
- (BOOL)isNumeric:(NSString*)pValue
{
    // NULL CHECK
    if (!pValue)
        return NO;
    
    // BLANK CHECK INCLUDING NEW-LINE
    NSString *trimmedString = [pValue stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedString isEqualToString:@""])
        return NO;
    
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [pValue rangeOfCharacterFromSet: nonNumbers];
    return r.location != NSNotFound;
}

/*-------------------
 RESIZE TABLE HEIGHT
 --------------------*/
- (void)resizeTableHeight
{
    return;
    /*TblContFile* controller = self.needHelp;
    
    // SET TABLE VIEW HEIGHT
    CGRect newFrame = controller.TblForFile.frame;
    if (controller.viwForEdit.hidden && controller.viwForPlaying.hidden)
    {
        newFrame.size.height = controller.view.frame.size.height;
    }
    else
    {
        newFrame.size.height = controller.view.frame.size.height -
        controller.viwForEdit.frame.size.height;
    }
    
    // SET NEW FRAME
    [controller.TblForFile setFrame:newFrame];*/
}

/*--------------------------
 MESSAGE FOR DOWNLOAD ERROR
 ---------------------------*/
- (void)errorAlertOfPreparing {
    
    NSString* msg = [NSString stringWithFormat:@"%@\n%@",
                     [[Config shared] trans:@"아직 준비되지 않은 파일일 수 있습니다"],
                     [[Config shared] trans:@"다른 파일 이용을 권장합니다"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertController
         showAlertInViewController:self.needHelp
         withTitle:[[Config shared] trans:@"다운로드 오류"].uppercaseString
         message:msg
         cancelButtonTitle:nil
         destructiveButtonTitle:[[Config shared] trans:@"확인"]
         otherButtonTitles:nil
         tapBlock:^(UIAlertController *controller,
                    UIAlertAction *action, NSInteger buttonIndex) {
         }];
    });
}

/*-------------------------------
 SHOW LATEST PLAYING INFO OR NOT
 --------------------------------*/
- (void)showRecentPlaying:(BOOL)pOnOff
{
    TblContFile* controller = self.needHelp;
    
    // SET PLAYING-PROGRESS-VIEW HIDDEN
    controller.viwForPlaying.hidden = YES;
    if (pOnOff)
    {
        // PREV PLAYING VIEW SETTING
        // 이전 플레이뷰 설정
        // 1. 콘피그로부터 이전 플레이중인 파일이 있는지 확인한다
        // 2. 없다면 비지블을 끈다
        // 3. 있다면..?
        // 4. CURRENT PLAYING VIEW 를 알맞게 설정한다
        NSString *pFilePath = nil;
        NSString *pFileSize = nil;
        NSString *pCurreSec = nil;
        NSString *pTotalSec = nil;
        [[Config shared] getRecentPlaying:&pFilePath
                                     fileSize:&pFileSize
                                   currentSec:&pCurreSec
                                     totalSec:&pTotalSec];
        //NSLog(@"-");
        //NSLog(@"최근플레이 정보");
        //NSLog(@"파일: %@", [pFilePath lastPathComponent]);
        //NSLog(@"크기: %@", pFileSize);
        //NSLog(@"길이: %@", pTotalSec);
        //NSLog(@"지점: %@", pCurreSec);
        
        BOOL isBeingTrue1 = ![pFilePath isEqualToString:@""];
        BOOL isBeingTrue2 = ([[KSPath shared] isExistPath:pFilePath]);
        BOOL isBeingTure3 = ([[Config shared] isSupportedFile:[pFilePath pathExtension]]);
        
        if ((!isBeingTrue1) || (!isBeingTrue2) || (!isBeingTure3))
        {
            //NSLog(@"파일 존재하지 않음: %@", pFilePath);
            controller.viwForPlaying.hidden = YES;
            return;
        }
        else
        {
            controller.viwForPlaying.alpha = 0.0;
            [self fadeInPlayingView:nil];
            
            FileInfo* fifo = [[KSPath shared] createFileInfoObject:pFilePath];
            // SET VIDEO FILE NAME
            controller.lblFileNameForPlaying.text = fifo.fileNameOnly.stringByDeletingPathExtension;
            
            // SET VIDEO DURATION
            controller.lblCurrentMovieLength.text = [NSString stringWithFormat:@"[%@] %@ %@",
                                                     fifo.durationTimeFormatted,
                                                     fifo.fileExtention.uppercaseString,
                                                     fifo.fileSize];
            
            if (![self isNumeric:pCurreSec])
                pCurreSec = @"0.00";
            if (![self isNumeric:pTotalSec])
                pTotalSec = fifo.durationSec;
            
            if (fifo.durationSec.floatValue == 0) {
                NSLog(@"TOTAL SIZE ERROR: %@", fifo.durationSec);
                [self errorAlertOfPreparing];
                return;
            }
            
            // SET PROGRESS
            float percentage = (pCurreSec.floatValue / fifo.durationSec.floatValue) * 100;
            //NSLog(@"최근플레이 퍼센티지: %.2f", percentage);
            [controller updatePlayingProgress:percentage];
            
            controller.viwForPlaying.hidden = NO;
        }
    }
    return;
}

- (void)fadeInPlayingView:(id)sender
{
    TblContFile* cont = self.needHelp;
    cont.viwForPlaying.alpha = cont.viwForPlaying.alpha + 0.05;
    
    if (cont.viwForPlaying.alpha < 1.0)
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
                                       selector:@selector(fadeInPlayingView:)
                                       userInfo:nil
                                        repeats:NO];
    
}

/*---------------------------------------------
 GET RENEW NAME FROM PROMPT-ALERT-VIEW
 ----------------------------------------------*/
- (void)newNamePrompt:(NSString*)pDefaultName
               title:(NSString*)pTitle
             message:(NSString*)pMessage
    handlerOnComplete:(void(^)(NSString* pNewName))phandlerOnComplete;
{
    TblContFile* controller = self.needHelp;
    
    Config* trans = [Config shared];
    NSString* ttlForRename = [trans trans:pTitle].uppercaseString;
    NSString* msgForRename = [trans trans:pMessage];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:ttlForRename
                                message:msgForRename
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok =
    [UIAlertAction actionWithTitle:[trans trans:@"확인"]
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action)
     {
         UITextField *txtReName = alert.textFields.firstObject;
         dispatch_async(dispatch_get_main_queue(), ^{
             phandlerOnComplete(txtReName.text);
         });
     }];
    
    UIAlertAction* cc =
    [UIAlertAction actionWithTitle:[trans trans:@"취소"]
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {}];
    
    [alert addAction:cc];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // UIText 가운데정렬하고 블락잡아주자(블락잡기 실패)
        textField.textAlignment = NSTextAlignmentCenter;
        textField.text = pDefaultName;
        
    }];
    [alert.view setNeedsDisplay];
    [controller presentViewController:alert animated:YES completion:nil];
}

/*-------------------
 GET RANDOM MOVIE FILE
 --------------------*/
- (NSString*)randomMovieFileIn:(NSDictionary*)pDictFile
                      currFile:(NSString*)pCurrMovieFile
{
    // DECLAIR VARS
    NSString* movieFileToReturn = pCurrMovieFile;
    
    // MAKE SET OF AVAILABLE MOVIE FILES
    int indexOfCurrFile = -1;
    NSMutableArray* arrAvailableFile = [NSMutableArray array];
    for (int i = 0; i < pDictFile.count; i++)
    {
        FileInfo* fifo = [pDictFile valueForKey:@(i).description];
        
        // FIND CURRENT FILE INDEX
        if ([pCurrMovieFile isEqualToString:fifo.fileNameFull]) {
            indexOfCurrFile = i;
            //NSLog(@"찾아낸 폴더내 재생 끝난파일 인덱스: %d", i);
        }
        
        // CHECK WHETHER IT IS MOVIE FILE OR .SMI, .SRT, .TXT
        // DETERMINE WHAT YPE OF VIDEO
        NSString* extention = [[fifo.fileNameFull pathExtension] uppercaseString];
        if ([[Config shared] isSupportedFile:extention]) {
            [arrAvailableFile addObject:fifo.fileNameFull];
            //NSLog(@"폴더내 찾은 파일: %@", fifo.fileNameOnly);
        }
    }
    
    int randomNumber;
    while (true) {
        randomNumber = 0 + rand() % ((arrAvailableFile.count -1) - 0);
        if (randomNumber != indexOfCurrFile)
            break;
    }
    
    // FOUND RANDOM FILE TO PLAY
    movieFileToReturn = [arrAvailableFile objectAtIndex:randomNumber];    
    return movieFileToReturn;
}

/*-------------------
 GET NEXT MOVIE FILE
 --------------------*/
- (NSString*)nextMovieFileIn:(NSDictionary*)pDictFile
                    currFile:(NSString*)pCurrMovieFile
{
    // DECLAIR VARS
    NSString* movieFileToReturn = pCurrMovieFile;
    
    // MAKE SET OF AVAILABLE MOVIE FILES
    int indexOfCurrFile = -1;
    NSMutableArray* arrAvailableFile = [NSMutableArray array] ;
    for (int i = 0; i < pDictFile.count; i++)
    {
        FileInfo* fifo = [pDictFile valueForKey:@(i).description];
        
        // FIND CURRENT FILE INDEX
        if ([pCurrMovieFile isEqualToString:fifo.fileNameFull]) {
            indexOfCurrFile = i;
            //NSLog(@"찾아낸 폴더내 재생 끝난파일 인덱스: %d", i);
        }
        
        // CHECK WHETHER IT IS MOVIE FILE OR .SMI, .SRT, .TXT
        // DETERMINE WHAT YPE OF VIDEO
        NSString* extention = [[fifo.fileNameFull pathExtension] uppercaseString];
        if ([[Config shared] isSupportedFile:extention]) {
            [arrAvailableFile addObject:fifo.fileNameFull];
            //NSLog(@"폴더내 찾은 파일: %@", fifo.fileNameOnly);
        }
    }
    
    // THERE ARE NO AVAILABLE MOVIE FILE
    if (arrAvailableFile.count == 0)
        return @"";
    
    // THERE ARE ONLY ONE MOVIE FILE
    if (arrAvailableFile.count == 1)
        return pCurrMovieFile;
    
    // IF CURRENT FILE IS LAST ONE OF FILE LIST
    if ((indexOfCurrFile + 1) == arrAvailableFile.count)
        indexOfCurrFile = -1;
    
    // FOUND NEXT FILE TO PLAY
    movieFileToReturn = [arrAvailableFile objectAtIndex:indexOfCurrFile+1];
    
    //NSLog(@"다음파일 인덱스: %d", indexOfCurrFile+1);
    //NSLog(@"다음파일 파일명: %@", [movieFileToReturn lastPathComponent]);
    
    return movieFileToReturn;
}

/*-----------------
 GET CELL IDENTITY
 ------------------*/
- (NSString*)cellIdentityString:(FileInfo*)pFifo isEditmode:(BOOL)isEditmode
{
    // 1. CellFileinNormal
    // 2. CellFileinEdit
    // 3. CellMovieinEdit
    // 4. CellMovieinNormal
    
    NSString* extention = pFifo.fileExtention;
    if (isEditmode) {
        if ([[Config shared] isSupportedFile:extention])
            return @"CellMovieinEdit";
        return @"CellFileinEdit";
    }
    else
    {
        if ([[Config shared] isSupportedFile:extention])
            return @"CellMovieinNormal";
        return @"CellFileinNormal";
    }
    
    return nil;
}

@end
