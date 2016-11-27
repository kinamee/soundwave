//
//  WaveformImageVew.m
//  repeater
//
//  Created by admin on 2016. 1. 24..
//  Copyright © 2016년 admin. All rights reserved.
//
#import "GraphFromAudio.h"
#import "Config.h"
#import "KSPath.h"
#import "SentenceFinder.h"

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-37.00) /* DEFAULT -50.0 */
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))
#define imgExt @"png"
#define imageToData(x) UIImagePNGRepresentation(x)

static GraphFromAudio* instance = nil;

@implementation GraphFromAudio

+(GraphFromAudio*)shared
{
    if (instance == nil) {
        instance = [[GraphFromAudio alloc] init];
    }
    return instance;
}

-(UIImage*)smallAudioImageLogGraphForSimple:(Float32*)samples
                               normalizeMax:(Float32)normalizeMax
                                sampleCount:(NSInteger)sampleCount
                               channelCount:(NSInteger)channelCount
                                imageHeight:(float)imageHeight {
    
    // SHRINK SIZE 2 TIMES
    float imgWidth = sampleCount / 4;
    CGSize imageSize = CGSizeMake(imgWidth, imageHeight);
    
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetAlpha(context,1.0);
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef leftColor = [[UIColor colorWithRed:235/255.0
                                            green:235/255.0
                                             blue:241/255.0 alpha:1] CGColor];
    //CGColorRef rightColor = [[UIColor redColor] CGColor];
    
    CGContextFillRect(context, rect);
    CGContextSetLineWidth(context, 1.0);
    
    float center = imageHeight / 2;
    float sampleAdjustmentFactor = (imageHeight/ (float) channelCount) / (normalizeMax - noiseFloor) / 1;
    
    // SHRINK SIZE 2 TIMES
    float loopCount = sampleCount / 4;
    for (NSInteger intSample = 0 ; intSample < loopCount ; intSample ++) {
        Float32 lineValue;
        
        // SHRINK SIZE 2 TIMES
        lineValue = *samples++;
        lineValue = *samples++;
        lineValue = *samples++;
        lineValue = *samples++;
        
        // DRAW SPECTRUM WITH NOIZE MARGIN
        float pixels = (lineValue - noiseFloor) * sampleAdjustmentFactor;
        if (pixels > 1.0)
            pixels = 4.2;
        else
            pixels = 0.0;
        
        CGContextMoveToPoint(context, intSample, center - pixels);
        CGContextAddLineToPoint(context, intSample, center + pixels);
        CGContextSetStrokeColorWithColor(context, leftColor);
        CGContextStrokePath(context);
        
        if (channelCount == 2) {
            // SHRINK SIZE 2 TIMES
            lineValue = *samples++;
            lineValue = *samples++;
            lineValue = *samples++;
            lineValue = *samples++;
        }
    }
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)smallAudioImageLogGraph:(Float32*)samples
                      normalizeMax:(Float32)normalizeMax
                       sampleCount:(NSInteger)sampleCount
                      channelCount:(NSInteger)channelCount
                       imageHeight:(float)imageHeight {
    
    // SHRINK SIZE 2 TIMES
    float imgWidth = sampleCount / 4;
    CGSize imageSize = CGSizeMake(imgWidth, imageHeight);
    
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetAlpha(context,1.0);
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef lineColor = [[UIColor blueColor] CGColor];
    //CGColorRef rightcolor = [[UIColor redColor] CGColor];
    
    CGContextFillRect(context, rect);
    CGContextSetLineWidth(context, 1.0);
    
    float center = imageHeight / 2;
    float sampleAdjustmentFactor = (imageHeight/ (float) channelCount) / (normalizeMax - noiseFloor) / 1;
    
    // SHRINK SIZE 2 TIMES
    float loopCount = sampleCount / 4;
    for (NSInteger intSample = 0 ; intSample < loopCount; intSample ++) {
        Float32 lineValue;
        
        // SHRINK SIZE 2 TIMES
        lineValue = *samples++;
        lineValue = *samples++;
        lineValue = *samples++;
        lineValue = *samples++;
        
        // DRAW SPECTRUM
        float pixels = (lineValue - noiseFloor) * sampleAdjustmentFactor;
        CGContextMoveToPoint(context, intSample, center-pixels);
        CGContextAddLineToPoint(context, intSample, center+pixels);
        CGContextSetStrokeColorWithColor(context, lineColor);
        CGContextStrokePath(context);
        
        if (channelCount == 2) {
            // SHRINK SIZE 2 TIMES
            lineValue = *samples++;
            lineValue = *samples++;
            lineValue = *samples++;
            lineValue = *samples++;
        }
    }
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    
    return newImage;
}

// 2 CHANNEL DRAWING
-(NSMutableDictionary*)audioImageLogGraph:(Float32 *)samples
                             normalizeMax:(Float32) normalizeMax
                              sampleCount:(NSInteger) sampleCount
                             channelCount:(NSInteger) channelCount
                              imageHeight:(float) imageHeight {
 
    NSMutableDictionary* dictSoundSpec = [NSMutableDictionary dictionary];
    float sampleAdjustmentFactor = (imageHeight / (float)channelCount) / (normalizeMax - noiseFloor);
 
    Float32 lineValue;
    for (NSInteger intSample = 0 ; intSample < sampleCount ; intSample++ )
    {
        lineValue = *samples++;
        float pixels = (lineValue - noiseFloor) * sampleAdjustmentFactor;
        [dictSoundSpec setValue:@(pixels).description forKey:@(intSample).description];
        
        if (channelCount == 2)
            lineValue = *samples++;
        
    }

    return dictSoundSpec;
}

/* 2 CHANNEL DRAWING
-(UIImage *) audioImageLogGraph:(Float32 *) samples
                   normalizeMax:(Float32) normalizeMax
                    sampleCount:(NSInteger) sampleCount
                   channelCount:(NSInteger) channelCount
                    imageHeight:(float) imageHeight {
 
    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context,1.0);
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef leftcolor = [[UIColor whiteColor] CGColor];
    CGColorRef rightcolor = [[UIColor redColor] CGColor];
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    
    float halfGraphHeight = (imageHeight / 2) / (float) channelCount ;
    float centerLeft = halfGraphHeight;
    float centerRight = (halfGraphHeight * 3);
    float sampleAdjustmentFactor = (imageHeight/ (float) channelCount) / (normalizeMax - noiseFloor) / 2;
    
    for (NSInteger intSample = 0 ; intSample < sampleCount ; intSample ++ ) {
        Float32 left = *samples++;
        float pixels = (left - noiseFloor) * sampleAdjustmentFactor;
        CGContextMoveToPoint(context, intSample, centerLeft-pixels);
        CGContextAddLineToPoint(context, intSample, centerLeft+pixels);
        CGContextSetStrokeColorWithColor(context, leftcolor);
        CGContextStrokePath(context);
        
        if (channelCount==2) {
            Float32 right = *samples++;
            float pixels = (right - noiseFloor) * sampleAdjustmentFactor;
            CGContextMoveToPoint(context, intSample, centerRight - pixels);
            CGContextAddLineToPoint(context, intSample, centerRight + pixels);
            CGContextSetStrokeColorWithColor(context, rightcolor);
            CGContextStrokePath(context);
        }
    }
    
    // Create new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Tidy up
    UIGraphicsEndImageContext();
    
    return newImage;
}*/

- (UIImage*)renderPNGAudioPictogramLogForAsset:(NSString*)pAudioFile
                                        height:(float)pHeight
                                     simplePNG:(UIImage**)pSimplePng {
    
    //CMTime audioDuration = songAsset.duration;
    //float totalSecond = CMTimeGetSeconds(audioDuration);
    
    NSURL* urlAud = [NSURL fileURLWithPath:pAudioFile];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:urlAud options:nil];
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:urlAsset error:&error];

    // SET TIME RANGE
    // float videoLengthInSeconds = audioDuration.value / audioDuration.timescale;
    // NSLog(@"오디오 길이: %@", [[ConfigFile shared] timeFormatted:videoLengthInSeconds]);

    AVAssetTrack *songTrack = [urlAsset.tracks objectAtIndex:0];
    
    NSDictionary*outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                       //[NSNumber numberWithInt:44100.0],AVSampleRateKey,  /*Not Supported*/
                                       //[NSNumber numberWithInt: 2],AVNumberOfChannelsKey, /*Not Supported*/
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       nil];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc]
                                        initWithTrack:songTrack
                                        outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    
    UInt32 sampleRate = 0, channelCount = 0;
    NSArray* formatDesc = songTrack.formatDescriptions;
    
    for (unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if(fmtDesc)
        {
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
            
            //NSLog(@"channels:%u, bytes/packet: %u, sampleRate %f",
            // fmtDesc->mChannelsPerFrame,
            // fmtDesc->mBytesPerPacket,
            // fmtDesc->mSampleRate);
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    Float32 normalizeMax = noiseFloor;
    //NSLog(@"normalizeMax = %f",normalizeMax);
    
    NSMutableData *fullSongData = [NSMutableData data];
    [reader startReading];
    
    UInt64 totalBytes = 0;
    Float64 totalLeft = 0;
    Float64 totalRight = 0;
    Float32 sampleTally = 0;
    
    NSInteger samplesPerPixel = sampleRate / 50.0;
    
    while (reader.status == AVAssetReaderStatusReading)
    {
        AVAssetReaderTrackOutput *trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef)
        {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
            
            SInt16 * samples = (SInt16 *) data.mutableBytes;
            int sampleCount = round(length / bytesPerSample);
            for (int i = 0; i < sampleCount ; i ++) {
                
                Float32 left = (Float32) *samples++;
                left = decibel(left);
                left = minMaxX(left, noiseFloor, 0);
                
                totalLeft  += left;
                
                Float32 right;
                if (channelCount == 2) {
                    right = (Float32) *samples++;
                    right = decibel(right);
                    right = minMaxX(right, noiseFloor, 0);
                    
                    totalRight += right;
                }
                
                sampleTally++;
                
                if (sampleTally > samplesPerPixel) {
                    
                    left  = totalLeft / sampleTally;
                    if (left > normalizeMax) {
                        normalizeMax = left;
                    }
                    // NSLog(@"left average = %f, normalizeMax = %f",left,normalizeMax);
                    
                    [fullSongData appendBytes:&left length:sizeof(left)];
                    
                    if (channelCount == 2) {
                        right = totalRight / sampleTally;
                        
                        if (right > normalizeMax) {
                            normalizeMax = right;
                        }
                        [fullSongData appendBytes:&right length:sizeof(right)];
                    }
                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                }
            }
            
            // FIRE PROGRESS
            // cnt++;
            // [self.delegate onDrawingSpectrumWithAudio:totalSecond
            //                                  current:pStaSec + (cnt / 5.3855)];
            // 189.31 초 1020 회 = 5.387
            // 441.10 초 2375 회 = 5.384
            //NSLog(@"FULL SONG GRAPH DATA SIZE: %.2lu", (unsigned long)fullSongData.length);
            
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
    
    if (reader.status == AVAssetReaderStatusFailed ||
        reader.status == AVAssetReaderStatusUnknown)
    {
        // Something went wrong. Handle it.
        NSLog(@"AVAssetReaderStatusFailed");
    }
    
    UIImage *imgSpectrum = nil;
    UIImage *imgSpectrumSimple = nil;
    
    if (reader.status == AVAssetReaderStatusCompleted)
    {
        // You're done. It worked.
        // NSLog(@"rendering output graphics using normalizeMax %f", normalizeMax);
        
        // Create analog spectrum image
        imgSpectrum = [self smallAudioImageLogGraph:(Float32 *)fullSongData.bytes
                                    normalizeMax:normalizeMax
                                     sampleCount:fullSongData.length / (sizeof(Float32) * 2) 
                                    channelCount:2
                                     imageHeight:pHeight];
        
        // Create digita spectrum image
        imgSpectrumSimple =
        [self smallAudioImageLogGraphForSimple:(Float32 *)fullSongData.bytes
                                  normalizeMax:normalizeMax
                                   sampleCount:fullSongData.length / (sizeof(Float32) * 2)
                                  channelCount:2
                                   imageHeight:pHeight];
        
        *pSimplePng = imgSpectrumSimple;
    }
    
    return imgSpectrum;
}

- (UIImage*)renderPNGAudioPictogramLogForAsset:(NSString*)pAudioFile
                                        height:(float)pHeight
                                        staSec:(float)pStaSec
                                        endSec:(float)pEndSec
                                     simplePNG:(UIImage**)pSimplePng {
    
    NSURL* urlAud = [NSURL fileURLWithPath:pAudioFile];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:urlAud options:nil];
    
    CMTime audioDuration = urlAsset.duration;
    float totalSecond = CMTimeGetSeconds(audioDuration);
    
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:urlAsset error:&error];
    
    // SET TIME RANGE
    // float videoLengthInSeconds = audioDuration.value / audioDuration.timescale;
    // NSLog(@"오디오 길이: %@", [[Config shared] timeFormatted:videoLengthInSeconds]);
    
    CMTime timeToSta = CMTimeMakeWithSeconds(pStaSec, audioDuration.timescale);
    CMTime timePeiro = CMTimeMakeWithSeconds((pEndSec - pStaSec), audioDuration.timescale);
    CMTimeRange readingRange = CMTimeRangeMake(timeToSta, timePeiro);
    reader.timeRange = readingRange;
    
    AVAssetTrack *songTrack = [urlAsset.tracks objectAtIndex:0];
    
    NSDictionary*outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                       //[NSNumber numberWithInt:44100.0],AVSampleRateKey,  /*Not Supported*/
                                       //[NSNumber numberWithInt: 2],AVNumberOfChannelsKey, /*Not Supported*/
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       nil];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc]
                                        initWithTrack:songTrack
                                        outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    
    UInt32 sampleRate = 0, channelCount = 0;
    NSArray* formatDesc = songTrack.formatDescriptions;
    
    for (unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if(fmtDesc)
        {
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
            
            //NSLog(@"channels:%u, bytes/packet: %u, sampleRate %f",
            // fmtDesc->mChannelsPerFrame,
            // fmtDesc->mBytesPerPacket,
            // fmtDesc->mSampleRate);
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    Float32 normalizeMax = noiseFloor;
    //NSLog(@"normalizeMax = %f",normalizeMax);
    
    NSMutableData *fullSongData = [NSMutableData data];
    [reader startReading];
    
    UInt64 totalBytes = 0;
    Float64 totalLeft = 0;
    Float64 totalRight = 0;
    Float32 sampleTally = 0;
    
    NSInteger samplesPerPixel = sampleRate / 50.0;
    
    NSInteger cnt = 0;
    
    while (reader.status == AVAssetReaderStatusReading)
    {
        AVAssetReaderTrackOutput *trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef)
        {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
            
            SInt16 * samples = (SInt16 *) data.mutableBytes;
            int sampleCount = round(length / bytesPerSample);
            for (int i = 0; i < sampleCount ; i ++) {
                
                Float32 left = (Float32) *samples++;
                left = decibel(left);
                left = minMaxX(left, noiseFloor, 0);
                
                totalLeft  += left;
                
                Float32 right;
                if (channelCount == 2) {
                    right = (Float32) *samples++;
                    right = decibel(right);
                    right = minMaxX(right, noiseFloor, 0);
                    
                    totalRight += right;
                }
                
                sampleTally++;
                
                if (sampleTally > samplesPerPixel) {
                    
                    left  = totalLeft / sampleTally;
                    if (left > normalizeMax) {
                        normalizeMax = left;
                    }
                    // NSLog(@"left average = %f, normalizeMax = %f",left,normalizeMax);
                    
                    [fullSongData appendBytes:&left length:sizeof(left)];
                    
                    if (channelCount == 2) {
                        right = totalRight / sampleTally;
                        
                        if (right > normalizeMax) {
                            normalizeMax = right;
                        }
                        [fullSongData appendBytes:&right length:sizeof(right)];
                    }
                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                }
            }
            
            // FIRE PROGRESS
            cnt++;
            [self.delegate onDrawingSpectrumWithAudio:totalSecond
                                              current:pStaSec + (cnt / 5.3855)];
            // 189.31 초 1020 회 = 5.387
            // 441.10 초 2375 회 = 5.384
            //NSLog(@"FULL SONG GRAPH DATA SIZE: %.2lu", (unsigned long)fullSongData.length);
            
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
    
    if (reader.status == AVAssetReaderStatusFailed ||
        reader.status == AVAssetReaderStatusUnknown)
    {
        // Something went wrong. Handle it.
        NSLog(@"AVAssetReaderStatusFailed");
    }
    
    UIImage *imgSpectrum = nil;
    UIImage *imgSpectrumSimple = nil;
    
    if (reader.status == AVAssetReaderStatusCompleted)
    {
        // You're done. It worked.
        // NSLog(@"rendering output graphics using normalizeMax %f", normalizeMax);
        
        // Create analog spectrum image
        imgSpectrum = [self smallAudioImageLogGraph:(Float32 *)fullSongData.bytes
                                                normalizeMax:normalizeMax
                                                 sampleCount:fullSongData.length / (sizeof(Float32) * 2)
                                                channelCount:2
                                                 imageHeight:pHeight];
        
        // Create digita spectrum image
        imgSpectrumSimple =
        [self smallAudioImageLogGraphForSimple:(Float32 *)fullSongData.bytes
                                  normalizeMax:normalizeMax
                                   sampleCount:fullSongData.length / (sizeof(Float32) * 2)
                                  channelCount:2
                                   imageHeight:pHeight];
        
        *pSimplePng = imgSpectrumSimple;
    }
    
    return imgSpectrum;
}


@end
