//
//  MVAdjustor.m
//  repeater
//
//  Created by admin on 2016. 1. 22..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "AudioFromVideo.h"
#import "GraphFromAudio.h"
#import "KSPath.h"
#import "Config.h"

static AudioFromVideo* instance = nil;

@implementation AudioFromVideo

+(AudioFromVideo*)shared {
    if (instance == nil) {
        instance = [[AudioFromVideo alloc] init];
    }
    return instance;
}

- (BOOL)coreAudioCanOpenURL:(NSURL*)url {
    
    OSStatus openErr = noErr;
    AudioFileID audioFile = NULL;
    openErr = AudioFileOpenURL((__bridge CFURLRef) url,
                               kAudioFileReadPermission ,
                               0,
                               &audioFile);
    if (audioFile) {
        AudioFileClose (audioFile);
    }
    return openErr ? NO : YES;
    
}

// CONVERT MP3 VIDEO TO M4A AUDIO
- (BOOL)conversionMP3ToM4A:(NSString*)pMP3FilePath
              destFM4APath:(NSString*)pDestM4APath
                    staSec:(float)pStaSec
                    endSec:(float)pEndSec
{
    NSURL *assetURL = [NSURL fileURLWithPath:pMP3FilePath];
    //NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSLog (@"Core Audio %@ directly open library URL %@",
           [self coreAudioCanOpenURL:assetURL] ? @"can" : @"cannot",
           assetURL);
    
    //NSLog (@"compatible presets for songAsset: %@",
    //       [AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset]);
    
    CMTime audioDuration = songAsset.duration;
    //float totalSecond = CMTimeGetSeconds(audioDuration);
    CMTime timeToSta = CMTimeMakeWithSeconds(pStaSec, audioDuration.timescale);
    CMTime timePeiro = CMTimeMakeWithSeconds((pEndSec - pStaSec), audioDuration.timescale);
    CMTimeRange readingRange = CMTimeRangeMake(timeToSta, timePeiro);
    CMTimeRange timeRange = readingRange;;
    
    /* approach 1: export just the song itself
     */
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: songAsset
                                      presetName: AVAssetExportPresetAppleM4A];
    //NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    exporter.outputFileType = @"com.apple.m4a-audio";
    exporter.timeRange = timeRange;
    
    // set up export (hang on to exportURL so convert to PCM can find it)
    // myDeleteFile(exportFile);
    //[exportURL release];
    
    //NSString* pathToSave = [NSString stringWithFormat:@"%@/tempm4a.m4a", [[KSPath shared] documentPath]];
    
    NSURL* exportURL = [NSURL fileURLWithPath:pDestM4APath];
    exporter.outputURL = exportURL;
    
    // START LOADING
    // [[VCLoading shared] showupOnParent:[TblContFileHelper shared].needHelp];
    
    __block BOOL isConverted = NO;
    __block BOOL isCompleted = NO;
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                // log error to text view
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                //errorView.text = exportError ? [exportError description] : @"Unknown failure";
                //errorView.hidden = NO;
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                isConverted = NO;
                isCompleted = YES;
                
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                NSLog (@"AVAssetExportSessionStatusCompleted");

                // FIRE COMPLETE METHOD
                isConverted = YES;
                isCompleted = YES;
                
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog (@"AVAssetExportSessionStatusUnknown");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                isConverted = NO;
                isCompleted = YES;
                
                break;
            }
            case AVAssetExportSessionStatusExporting: {
                NSLog (@"AVAssetExportSessionStatusExporting");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                NSLog (@"AVAssetExportSessionStatusCancelled");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                isConverted = NO;
                isCompleted = YES;
                
                break;
            }
            case AVAssetExportSessionStatusWaiting: {
                NSLog (@"AVAssetExportSessionStatusWaiting");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
            default: {
                NSLog (@"didn't get export status");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
        }
    }];
    
    while (YES)
    {
        [NSThread sleepForTimeInterval:0.1f];
        if (isCompleted)
            break;
    }
    
    //NSLog(@"원래저장할곳:%@", pDestM4APath);
    //NSLog(@"실제저장된곳:%@", pathToSave);
    
    return isConverted;
}


// CONVERT MP4 VIDEO TO M4A AUDIO
- (BOOL)conversionMP4ToM4A:(NSString*)pMP4FilePath
              destFM4APath:(NSString*)pDestM4APath
                    staSec:(float)pStaSec
                    endSec:(float)pEndSec
{
    //NSLog(@"MP4 를 M4A 로 변환시작 시작시간 끝시간: %@", [pDestM4APath lastPathComponent]);
    NSURL* dstURL = [NSURL fileURLWithPath:pDestM4APath];
    [[NSFileManager defaultManager] removeItemAtURL:dstURL
                                              error:nil];
    
    AVMutableComposition* newAudioAsset = [AVMutableComposition composition];
    
    AVMutableCompositionTrack* dstCompositionTrack;
    dstCompositionTrack = [newAudioAsset addMutableTrackWithMediaType:AVMediaTypeAudio
                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSURL* srcURL = [NSURL fileURLWithPath:pMP4FilePath];
    AVAsset* srcAsset = [AVURLAsset URLAssetWithURL:srcURL options:nil];
    AVAssetTrack* srcTrack = [[srcAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    CMTime audioDuration = srcAsset.duration;
    //float totalSecond = CMTimeGetSeconds(audioDuration);
    CMTime timeToSta = CMTimeMakeWithSeconds(pStaSec, audioDuration.timescale);
    CMTime timePeiro = CMTimeMakeWithSeconds((pEndSec - pStaSec), audioDuration.timescale);
    CMTimeRange readingRange = CMTimeRangeMake(timeToSta, timePeiro);
    CMTimeRange timeRange = readingRange;;
    
    NSError* error;
    if(NO == [dstCompositionTrack insertTimeRange:timeRange
                                          ofTrack:srcTrack
                                           atTime:kCMTimeZero
                                            error:&error]) {
        //NSLog(@"track insert failed: %@\n", error);
        return NO;
    }
    
    AVAssetExportSession* exportSesh = [[AVAssetExportSession alloc]
                                        initWithAsset:newAudioAsset
                                        presetName:AVAssetExportPresetPassthrough];
    
    exportSesh.outputFileType = AVFileTypeAppleM4A;
    //exportSesh.outputFileType = AVFileTypeAIFF;
    //exportSesh.shouldOptimizeForNetworkUse = YES;
    
    __block BOOL isConverted = NO;
    __block BOOL isCompleted = NO;
    
    exportSesh.outputURL = dstURL;
    [exportSesh exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus status = exportSesh.status;
        // NSLog(@"exportAsynchronouslyWithCompletionHandler: %li\n", (long)status);
        
        if(AVAssetExportSessionStatusFailed == status) {
            NSLog(@"AUDIO CREATE FAIL: %@", exportSesh.error);
        } else if(AVAssetExportSessionStatusCompleted == status) {
            //NSLog(@"AUDIO CREATE SUCCESS");
        }
        // FIRE COMPLETE METHOD
        isConverted = (AVAssetExportSessionStatusCompleted == status);
        isCompleted = YES;
        //NSLog(@"MP4 를 M4A 로 변환완료");
    }];
    
    while (YES)
    {
        [NSThread sleepForTimeInterval:0.1f];
        if (isCompleted)
            break;
    }
    
    return isConverted;
}

/*-------------------------
 MAKE PATH FOR AUDIO FILE
 --------------------------*/
- (NSString*)audioFilePath:(NSString*)pMediaPath
{
    NSString* extention = [[pMediaPath pathExtension]
                           uppercaseString];
    
    NSString* audioPath;
    if ([extention isEqualToString:@"M4A"] ||
        [extention isEqualToString:@"MP3"])
        /*-------------------------------------
         오디오 파일은 임시 오디오파일이 필요 없다
         따라서, 미디어 파일 자체를 오디오파일 경로화 한다
         --------------------------------------*/
        audioPath = [NSString stringWithFormat:@"%@", pMediaPath];
    else {
        audioPath = [NSString stringWithFormat:@"%@/%@.m4a",
                     [[KSPath shared] tempDirFrom:pMediaPath makeOption:YES],
                     [pMediaPath lastPathComponent]];
    }
    return audioPath;
}

/*---------------------------------
 DELEGATE BY GraphFromAudio CLASS
-----------------------------------*/
- (void)onDrawingSpectrumWithAudio:(float)pTotal current:(float)pCurrent
{
    [self.delegate onDrawingSpectrum:pTotal current:pCurrent];
}

@end
