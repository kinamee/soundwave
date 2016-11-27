//
//  VCVoiceRecorder.h
//  repeater
//
//  Created by admin on 2016. 9. 6..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VCVoiceRecorder : UIViewController <AVAudioSessionDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
}

+ (VCVoiceRecorder*)shared;

@property (weak, nonatomic) IBOutlet UIView *viwBack;
@property (weak, nonatomic) IBOutlet UIView *viwFront;
@property (weak, nonatomic) IBOutlet UIImageView *imgSpectrum;
@property (weak, nonatomic) IBOutlet UIButton *imgMike;
@property (weak, nonatomic) IBOutlet UIImageView *imgCenter;
@property (weak, nonatomic) IBOutlet UIButton *btnRec;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UILabel *lblRecTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;

- (IBAction)tchSave:(id)sender;
- (IBAction)tchRec:(id)sender;
- (IBAction)tchPause:(id)sender;

- (void)initRecorder;

@property (nonatomic, copy) NSURL* recordedTmpFile;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, retain) NSDate* timeToStart;
@property (nonatomic, copy) NSString* previousSavedFile;

@property (nonatomic, retain) AVAudioRecorder* recorder;
@property (nonatomic, retain) AVAudioPlayer* player;
@property (nonatomic, copy) NSURL *temporaryRecFile;

@property (nonatomic, assign) float value4VS01;
@property (nonatomic, assign) float value4VS02;

@end
