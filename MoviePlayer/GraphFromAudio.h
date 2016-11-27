//
//  WaveformImageVew.h
//  repeater
//
//  Created by admin on 2016. 1. 24..
//  Copyright © 2016년 admin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ProtocolDrawingSpectrumWithAudio <NSObject>
@required
- (void)onDrawingSpectrumWithAudio:(float)pTotal current:(float)pCurrent;
@end

@interface GraphFromAudio : NSObject
{
}

+(GraphFromAudio*)shared;

@property (nonatomic, weak) id <ProtocolDrawingSpectrumWithAudio> delegate;
@property (nonatomic, retain) UIImage* imgWaveForm;

//-(id)initWithUrl:(NSURL*)url;
//-(id)initWithUrl:(NSURL*)url frame:(CGRect)pFrame;

- (UIImage*)renderPNGAudioPictogramLogForAsset:(NSString*)pAudioFile
                                        height:(float)pHeight
                                     simplePNG:(UIImage**)pSimplePng;

- (UIImage*)renderPNGAudioPictogramLogForAsset:(NSString*)pAudioFile
                                        height:(float)pHeight
                                        staSec:(float)pStaSec
                                        endSec:(float)pEndSec
                                     simplePNG:(UIImage**)pSimplePng;

//- (NSData*)createWaveFormData:(NSString*)pAudioFile
//                        heigt:(float)pHeight;

@end
