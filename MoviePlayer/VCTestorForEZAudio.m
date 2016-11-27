//
//  VCTestorForEZAudio.m
//  repeater
//
//  Created by admin on 2016. 1. 22..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCTestorForEZAudio.h"
#import "EZAudioUtilities.h"
#import <QuartzCore/QuartzCore.h>

@interface VCTestorForEZAudio ()

@end

VCTestorForEZAudio* instance = nil;

@implementation VCTestorForEZAudio

+(VCTestorForEZAudio*)shared {
    if (instance == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        instance = [storyboard instantiateViewControllerWithIdentifier:@"VCTestorForEZAudio"];
    }
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)playWithFile:(NSString*)pMovieFile parent:(UIViewController*)pParent {

    // SHOW THIS VIEW
    [self setModalPresentationStyle:UIModalPresentationFullScreen];
    [pParent presentViewController:self animated:YES completion:NULL];
    
    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    NSLog(@"outputs: %@", [EZAudioDevice outputDevices]);
    
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if (error)
    {
        NSLog(@"Error overriding output to the speaker: %@", error.localizedDescription);
    }
    
    /*
     Try opening the sample file
     */
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:pMovieFile]];
}

- (IBAction)gesSingleTap:(id)sender {
    // CLOSE THIS VIEW
    [[self presentingViewController]
     dismissViewControllerAnimated:YES completion:nil];
}

//------------------------------------------------------------------------------

- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
    
    //[self createDynamicAudioPlot:filePathURL];
    //return;
    
    //
    // Create the EZAudioPlayer
    //
    self.audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    
    //
    // Customizing the audio plot's look
    //
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 1];
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.currentFrameNumber        = 0;
    _tmrRedraw = [NSTimer scheduledTimerWithTimeInterval: .01
                                                  target: self
                                                selector:@selector(onTick:)
                                                userInfo: nil repeats:YES];
    return;
}

-(void)onTick:(NSTimer *)timer {
    
    self.audioPlot.plotType = EZPlotTypeBuffer;
    self.audioPlot.shouldFill = YES;
    self.audioPlot.shouldMirror = YES;
    
    UInt32 numberOfPoints = 2048;
    self.currentFrameNumber = self.currentFrameNumber +2.5;
    SInt64 startFrom = self.currentFrameNumber * 1000;
    
    /*
     Number of frames per 1 sec
     **/
    SInt64 framesPer1Sec = (self.audioFile.totalFrames / self.audioFile.duration);
    NSLog(@"Number of frames per 1sec: %lld", framesPer1Sec);
    NSLog(@"StartFrom: %lld", startFrom);
    
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithNumberOfPoints:numberOfPoints
                                            startFram:startFrom
                                       numberOfFrames:framesPer1Sec * 10
                                           completion:^(float **waveformData,
                                                        int length)
     {
         [weakSelf.audioPlot updateBuffer:waveformData[0] withBufferSize:length];
     }];
}

//------------------------------------------------------------------------------

@end
