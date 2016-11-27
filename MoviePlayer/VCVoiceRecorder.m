//
//  VCVoiceRecorder.m
//  repeater
//
//  Created by admin on 2016. 9. 6..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCVoiceRecorder.h"
#import "VCMoviePlayer.h"
#import "UIImage+Category.h"
#import "KSPath.h"
#import "Config.h"
#import "TblContFile.h"

@interface VCVoiceRecorder ()

@end

static VCVoiceRecorder* instance = nil;

@implementation VCVoiceRecorder

+ (VCVoiceRecorder*)shared
{
    return instance;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (instance == nil)
        instance = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)visualizeProcInPlay
{
    [self.player updateMeters];
    
    const double ALPHA = 1.05;
    double averagePowerForChannel1 = pow(10, (0.05 * [self.player averagePowerForChannel:0]));
    self.value4VS01 = ALPHA * averagePowerForChannel1 + (1.0 - ALPHA) * self.value4VS01;
    
    float radius2x = self.imgSpectrum.frame.size.width * (self.value4VS01 * 5);
    if (radius2x > self.imgSpectrum.frame.size.width)
        radius2x = self.imgSpectrum.frame.size.width;
    
    UIImage* circle = [self.imgSpectrum.image
                       imageByDrawingCircle:self.imgSpectrum.frame
                       radius:radius2x * 0.5];
    [self.imgSpectrum setImage:circle];
    
    if (self.isPlaying)
        [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(visualizeProcInPlay)
                                       userInfo:nil repeats:NO];
    else {
        [self.imgSpectrum setImage:[UIImage imageNamed:@"first"]];
    }
}

- (void)visualizeProcInRec
{
    [self.recorder updateMeters];
    
    const double ALPHA = 1.05;
    double averagePowerForChannel1 = pow(10, (0.05 * [self.recorder averagePowerForChannel:0]));
    self.value4VS01 = ALPHA * averagePowerForChannel1 + (1.0 - ALPHA) * self.value4VS01;
    
    float radius2x = self.imgSpectrum.frame.size.width * (self.value4VS01 * 5);
    if (radius2x > self.imgSpectrum.frame.size.width)
        radius2x = self.imgSpectrum.frame.size.width;
    
    // NSLog(@"음량수치(%.2f)", self.value4VS01);
    UIImage* circle = [self.imgSpectrum.image
                       imageByDrawingCircle:self.imgSpectrum.frame
                       radius:radius2x * 0.5];
    [self.imgSpectrum setImage:circle];
    
    if (self.isRecording)
        [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(visualizeProcInRec)
                                       userInfo:nil repeats:NO];
    else {
        [self.imgSpectrum setImage:[UIImage imageNamed:@"first"]];
    }
}

- (void)stopPlaying
{
    [self.player pause];
    // CHANGE BUTTON IMAGE
    [self.btnPause setImage:[UIImage imageNamed:@"icn_player_play_40x40"]
                   forState:UIControlStateNormal];
    self.isPlaying = NO;
    self.lblDesc.text = [[Config shared] trans:@"Ready to record"];
}

- (void)stopRecording
{
    // LET'S STOP RECORDING
    [self.recorder stop];
    self.btnRec.tintColor = self.imgMike.tintColor;
    self.isRecording = NO;
    
    // CHANGE BUTTON IMAGE
    [self.btnPause setImage:[UIImage imageNamed:@"icn_player_play_40x40"]
                   forState:UIControlStateNormal];
    self.lblDesc.text = [[Config shared] trans:@"Ready to record"];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory :AVAudioSessionCategoryPlayback error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
}

- (void)initRecorder
{
    //NSLog(@"이닛!");
    NSError* error = nil;
    NSDictionary *rs = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                        [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                        [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                        nil];
    
    self.recordedTmpFile = [NSURL fileURLWithPath:
                            [[[KSPath shared] documentPath] stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"_rec/_tmp/rec_%.0f.%@",
                              [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"m4a"]]];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedTmpFile settings:rs error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    
    //[self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    [self.recorder record];
    [self.recorder stop];
    
    self.recordedTmpFile = nil;
}

- (IBAction)tchRec:(id)sender {
    //NSLog(@"TCH REC");
    
    if (self.isRecording == YES) {
        [self stopRecording];
        return;
    }
    
    self.isRecording = YES;
    
    // IF IS PLAYING
    if ((self.player != nil) &&
        self.isPlaying == YES)
        [self stopPlaying];
    
    // SAVE CURRENT TIME
    self.timeToStart = [NSDate date];
    
    [self.btnPause setImage:[UIImage imageNamed:@"icn_player_pause_40x40"]
                   forState:UIControlStateNormal];
    
    // DELETE PREVIOUS RECORDED FILE
    [[KSPath shared] deleteAllTempRedcorded];    
    
    self.lblDesc.text = [[Config shared] trans:@"Voice recording.."];
    
    // PREPARE
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (NO == [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
        NSLog(@"audioSession for record failed: %@\n", error);
    [audioSession setActive:YES error:nil];
    
    /* Recording settings
    NSMutableDictionary *rs = [[NSMutableDictionary alloc] init];
    [rs setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    [rs setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [rs setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];*/
    
    //NSLog(@"USING FILE CALLED: %@", self.recordedTmpFile);
    NSDictionary *rs = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                        [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                        [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                        nil];
    
    self.recordedTmpFile = [NSURL fileURLWithPath:
                            [[[KSPath shared] documentPath] stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"_rec/_tmp/rec_%.0f.%@",
                              [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"m4a"]]];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordedTmpFile settings:rs error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    [self.recorder record];
    
    // VISULIZATION
    self.recorder.meteringEnabled = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(visualizeProcInRec)
                                   userInfo:nil repeats:NO];
    
    // START TIMER
    [self onTimerOfRecOrPlay:nil];
    
    // CHANGE BUTTON COLOR
    self.btnRec.tintColor = [UIColor colorWithRed:0.824 green:0.200 blue:0.290 alpha:1.00];
}

/*---------------
 PAUSE AND PLAY
 ----------------*/
- (IBAction)tchPause:(id)sender {
    //NSLog(@"TCH PAUSE");
    
    if (self.isRecording == YES)
    {
        [self stopRecording];
        return;
    }
    
    if ((self.isRecording == NO) && (self.isPlaying == NO))
    {
        if (self.recordedTmpFile == nil)
            return;
        
        // LET'S PLAYING THE RECORDED VOICE
        [self playBack];
        return;
    }
    
    if (self.isPlaying == YES)
    {
        [self stopPlaying];
        return;
    }
}

- (IBAction)tchSave:(id)sender {
    //NSLog(@"TCH SAVE");
    
    if (self.recordedTmpFile == nil) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:[[Config shared] trans:@"오류"]
                                   message:[[Config shared] trans:@"저장 할 녹음파일이 없습니다"]
                                  delegate:nil
                         cancelButtonTitle:[[Config shared] trans:@"확인"]
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.isRecording)
        [self tchPause:nil];
    
    if (self.isPlaying)
        [self tchPause:nil];
    
    NSString* recDir = [NSString stringWithFormat:@"%@/_rec/", [[KSPath shared] documentPath]];
    if ([[KSPath shared] isExistPath:recDir] == NO)
        [[KSPath shared] createDirectory:recDir];
    
    NSString* pathToSource = [NSString stringWithFormat:@"%@_tmp/%@", recDir,
                              self.recordedTmpFile.absoluteString.lastPathComponent];
    
    /*----------------------------
     MOVIE NAME FOR NEW FILE NAME
     -----------------------------*/
    NSString* fileName = [VCMoviePlayer shared].movieFilePath.
                            lastPathComponent.stringByDeletingPathExtension;
    if (fileName.length > 15)
        fileName = [fileName substringToIndex:15];
    
    /*---------------------------
     DATE TIME FOR NEW FILE NAME
     ----------------------------*/
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMddyyyy-hhmmss"];
    NSString *newName = [dateFormat stringFromDate:date];
    
    NSString* pathToTarget = [NSString stringWithFormat:@"%@%@ %@.m4a",
                              recDir, newName, fileName];
    //NSLog(@"저장경로:%@", pathToTarget);
    
    if (self.previousSavedFile != nil)
    if ([self.previousSavedFile isEqualToString:pathToSource]) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:[[Config shared] trans:@"오류"]
                                   message:[[Config shared] trans:@"이미 저장된 파일입니다"]
                                  delegate:nil
                         cancelButtonTitle:[[Config shared] trans:@"확인"]
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[KSPath shared] copyFile:pathToSource targetPath:pathToTarget];
    self.previousSavedFile = [NSString stringWithFormat:@"%@", pathToSource];
    
    // SET BADGE VALUE +1
    TblContFile* viwBase = (TblContFile*)[VCMoviePlayer shared].vwcParent;
    NSString* badgeValue = [viwBase.tabBarController.tabBar.items objectAtIndex:1].badgeValue;
    int badege = 0;
    if (badgeValue)
        badege = badgeValue.intValue;
    badgeValue = [NSString stringWithFormat:@"%i", badege+1];
    [[viwBase.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:badgeValue];
    
    /* MAKE A THUMNAIL IMAGE
    float curreSec = [VCMoviePlayer shared].movieCurreSec;
    
    NSString* fullpath = [VCMoviePlayer shared].movieFilePath;
    FileInfo* fifo = [[KSPath shared] createFileInfoObject:fullpath];
    UIImage* thumb = [fifo loadThumb:curreSec];// convertToGrayscale];
    NSString* pathToSave = [[KSPath shared] tempDirFrom:pathToTarget makeOption:YES];
    pathToSave = [pathToSave stringByAppendingFormat:@"/%@.png", pathToTarget.lastPathComponent];
    //NSLog(@"SAVE THUMB: %@", pathToSave);
    [UIImagePNGRepresentation(thumb) writeToFile:pathToSave atomically:YES];*/
    
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:[[Config shared] trans:@"성공"]
                               message:[[Config shared] trans:@"녹음파일이 저장되었습니다"]
                              delegate:nil
                     cancelButtonTitle:[[Config shared] trans:@"확인"]
                     otherButtonTitles:nil];
    [alert show];        
}

- (void)playBack
{
    //NSLog(@"PLAY:%@", self.recordedTmpFile);
    
    self.isPlaying = YES;
    [self.btnPause setImage:[UIImage imageNamed:@"icn_player_pause_40x40"]
                   forState:UIControlStateNormal];
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory :AVAudioSessionCategoryPlayback error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordedTmpFile error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    
    self.player.delegate = self;
    [self.player setNumberOfLoops:0];
    self.player.volume = 1;
    [self.player prepareToPlay];
    [self.player play];
    
    self.player.meteringEnabled = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(visualizeProcInPlay)
                                   userInfo:nil repeats:NO];
    
    self.timeToStart = [NSDate date];
    [self onTimerOfRecOrPlay:nil];
}

- (void)onTimerOfRecOrPlay:(id)sender {
    
    NSDate *endingDate = [NSDate date];
    NSTimeInterval timeInterval = 0.0;
    timeInterval = [endingDate timeIntervalSinceDate:self.timeToStart];
    
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    self.lblRecTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
                            (long)hours, (long)minutes, (long)seconds];
    
    if (self.isRecording || self.isPlaying)
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                       selector:@selector(onTimerOfRecOrPlay:)
                                       userInfo:nil
                                        repeats:NO];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //NSLog (@"audioPlayerDidFinishPlaying:successfully:");
    self.isPlaying = NO;
    // CHANGE BUTTON IMAGE
    [self.btnPause setImage:[UIImage imageNamed:@"icn_player_play_40x40"]
                   forState:UIControlStateNormal];
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:    (BOOL)flag
{
    //NSLog (@"audioRecorderDidFinishRecording:successfully: %d", flag);
    [self.imgSpectrum setImage:[UIImage imageNamed:@"first"]];
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}
-(void)beginInterruption{
    NSLog(@"INTERRUPT");
}

@end
