//
//  VCTestorForEZAudio.h
//  repeater
//
//  Created by admin on 2016. 1. 22..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCTestorForEZAudio : UIViewController <EZAudioPlayerDelegate>
{
    NSTimer *_tmrRedraw;
}

+(VCTestorForEZAudio*)shared;

- (void)playWithFile:(NSString*)pMovieFile parent:(UIViewController*)pParent;

- (IBAction)gesSingleTap:(id)sender;

//------------------------------------------------------------------------------
#pragma mark - Components
//------------------------------------------------------------------------------

/**
 An EZAudioFile that will be used to load the audio file at the file path specified
 */
@property (nonatomic, strong) EZAudioFile *audioFile;

//------------------------------------------------------------------------------

/**
 The CoreGraphics based audio plot
 */
@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;

//------------------------------------------------------------------------------

@property (nonatomic, assign) SInt64 currentFrameNumber;

@end