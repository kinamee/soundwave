//
//  VCVoiceRecorderInRec.h
//  repeater
//
//  Created by admin on 2016. 9. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TblContRecorded.h"

@interface VCVoiceRecorderInRec : UIViewController <AVAudioSessionDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{    
}

+ (VCVoiceRecorderInRec*)shared;

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
@property (nonatomic, retain) TblContRecorded* vcParent;

@property (nonatomic, retain) AVAudioRecorder* recorder;
@property (nonatomic, retain) AVAudioPlayer* player;
@property (nonatomic, copy) NSURL *temporaryRecFile;

@property (nonatomic, assign) float value4VS01;
@end
