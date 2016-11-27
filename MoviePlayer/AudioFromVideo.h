//
//  MVAdjustor.h
//  repeater
//
//  Created by admin on 2016. 1. 22..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "GraphFromAudio.h"

// DELEGATE PROTOCAL
@protocol ProtocalGraphFromVideo <NSObject>
@required
//- (void)onCompleteAudioFromVideo:(NSString*)pVideoPath audioPath:(NSString*)pAudioPath;
- (void)onDrawingSpectrum:(float)pTotal current:(float)pCurrent;
@end

@interface AudioFromVideo : NSObject <ProtocolDrawingSpectrumWithAudio>
{
}

@property (nonatomic, weak) id <ProtocalGraphFromVideo> delegate;
@property (nonatomic, assign) float SpectrumHeight;

+(AudioFromVideo*)shared;

/*-------------------------
 MAKE PATH FOR AUDIO FILE
 --------------------------*/
- (NSString*)audioFilePath:(NSString*)pMediaPath;

/* GET AUDIO SPECTRUM OF THE VIDEO FILE
-(void)createAudioSpectrum:(NSString*)pVideoFilePath
                    height:(float)pHeight;*/

// CONVERT MP4 VIDEO TO M4A AUDIO
- (BOOL)conversionMP4ToM4A:(NSString*)pMP4FilePath
              destFM4APath:(NSString*)pDestM4APath
                    staSec:(float)pStaSec
                    endSec:(float)pEndSec;

// CONVERT MP3 VIDEO TO M4A AUDIO
- (BOOL)conversionMP3ToM4A:(NSString*)pMP3FilePath
              destFM4APath:(NSString*)pDestM4APath
                    staSec:(float)pStaSec
                    endSec:(float)pEndSec;

/* CREATE UIIMAGE THAT HAS SPECTREM OF AUDIO
- (UIImage*)createSpectrumImgFromAudio:(NSString*)pAudioFilePath
                                height:(float)pHeight
                           imageSimple:(UIImage**)pImageSimple;*/

@end
