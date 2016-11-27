//
//  FileInfo.m
//  repeater
//
//  Created by admin on 2016. 2. 23..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "FileInfo.h"
#import "KSPath.h"
#import <AVFoundation/AVFoundation.h>
#import "Config.h"

@implementation FileInfo

-(NSString*)fileNamefullByNewExt:(NSString*)pNewExt
{
    NSString* newFileName = [NSString stringWithFormat:@"%@",
                             [[KSPath shared] changeFileNameByNewExt:self.fileNameFull
                                                              newExt:pNewExt]];
    return newFileName;
}

/*----------------------------------------------------
 GET DURATION. IF THE FILE IS NOT PLAYABLE RETURN NIL
 -----------------------------------------------------*/
- (NSString*)durationSec
{
    if ([[Config shared] isSupportedFile:self.fileExtention])
    {
        float audioDurationSeconds = [[KSPath shared] duration:self.fileNameFull];
        return @(audioDurationSeconds).description;
    }
    return nil;
}

- (NSString*)durationTimeFormatted
{
    if ([[Config shared] isSupportedFile:self.fileExtention])
    {
        float audioDurationSeconds = [[KSPath shared] duration:self.fileNameFull];
        return [[Config shared] timeFormatted:audioDurationSeconds];
    }
    return nil;
}

-(UIImage *)loadThumb:(float)pCurrSec
{    
    if ([[Config shared] isSupportedFile:self.fileExtention])
    {
        // LOAD VIDEO FILE
        NSURL* urlPath = [NSURL fileURLWithPath:self.fileNameFull];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:urlPath options:nil];
        AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generate.appliesPreferredTrackTransform = TRUE;
        NSError *err = NULL;
        
        /* FIND POINT OF TIME TO MAKE THUMB
        CMTime audioDuration = asset.duration;
        float videoLengthInSeconds = audioDuration.value / audioDuration.timescale;
        CGFloat nearest = videoLengthInSeconds * pRatio;
        CMTime timeToSeek = CMTimeMakeWithSeconds(nearest, audioDuration.timescale);*/
        
        CMTime audioDuration = asset.duration;
        //float totalSecond = CMTimeGetSeconds(audioDuration);
        CMTime timeToSeek = CMTimeMakeWithSeconds(pCurrSec, audioDuration.timescale);
        
        // MAKE THUMB
        CGImageRef imgRef = [generate copyCGImageAtTime:timeToSeek actualTime:NULL error:&err];
        //NSLog(@"err==%@, imageRef==%@", err, imgRef);
        
        return [[UIImage alloc] initWithCGImage:imgRef];
    }
    return nil;
}

-(void)printLog {
    NSLog(@"FileNameOnly:%@", self.fileNameOnly);
    NSLog(@"fileNameFull:%@", self.fileNameFull);
    NSLog(@"fileExtention:%@", self.fileExtention);
    NSLog(@"directoryPath:%@", self.directoryPath);
    NSLog(@"fileSize:%@", self.fileSize);
    NSLog(@"dateCreated:%@", self.dateCreated);
    NSLog(@"durationSec:%@", self.durationSec);
    NSLog(@"durationTimeFormatted:%@", self.durationTimeFormatted);
    NSLog(@"dateCreatedRaw:%@", self.dateCreatedRaw);
}

@end
