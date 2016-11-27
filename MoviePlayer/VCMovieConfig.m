//
//  VCMovieConfig.m
//  repeater
//
//  Created by admin on 2016. 2. 2..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCMovieConfig.h"
#import "Config.h"
#import "VCMoviePlayer.h"
#import "UIAlertController+Blocks.h"
#import "SentenceFinder.h"
#import "SentGroup.h"

@interface VCMovieConfig ()

@end

static VCMovieConfig* instance = nil;

@implementation VCMovieConfig

+ (VCMovieConfig*)shared
{    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (instance == nil)
        instance = self;
    
    //NSLog(@"INSTANCE: %@", instance);
    [self loadConfigData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadConfigData
{
    //NSLog(@"콘피그 설정 읽어들임");
    
    // INIT REPEAST COUNT
    self.lblRepeatCount.text = [[Config shared] trans:@"문장 재생 횟수"];
    self.lblRepeatCountValue.text = [NSString stringWithFormat:@"%d %@",
                                     [[Config shared] getRepeatCount],
                                     [[Config shared] trans:@"회"]];
    
    if ([[Config shared] getRepeatCount] == 1)
        self.lblRepeatCountValue.text = [[Config shared] trans:@"반복없음"];
    else if ([[Config shared] getRepeatCount] == 0)
        self.lblRepeatCountValue.text = [[Config shared] trans:@"무한반복"];
    
    // INIT PLAY SPEED
    self.lblPlaySpeed.text = [[Config shared] trans:@"재생 속도"];
    self.lblPlaySpeedValue.text = [NSString stringWithFormat:@"%.1f X", [Config shared].playSpeed];
    
    // INIT MINIMUM SENTENCE LENGTH
    self.lblMinimumSenLen.text = [[Config shared] trans:@"문장인식 최소길이"];
    self.lblMinimumSenLenValue.text = [NSString stringWithFormat:@"%.1f %@",
                                       [[Config shared] getMinimumSenSec],
                                       [[Config shared] trans:@"초"]];
    
    // INIT CAPTION SUPPORT (.SMI, .SRT)
    self.lblSubCaptionSupport.text = [[Config shared] trans:@"자막 지원"];
    [self setCaptionSupport:[[Config shared] getCaptionOnOFF]
                     button:self.btnCaptionSupport];
    
    // INIT AFTER OF END PLAY
    self.btnPlayNext.tintColor = [UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00];
    [self.lblRepeatOne setTextColor:[UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00]];
    self.btnPlayRepeat.tintColor = [UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00];
    self.btnPlayRandom.tintColor = [UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00];
    
    OPTION_TypeOnPlayEnd repeatOption = [[Config shared] getAfterEndOfPlay];
    if (repeatOption == OPTION_PLY_NEXT) {
        self.btnPlayNext.tintColor = [UIColor colorWithRed:0.843 green:0.847 blue:0.867 alpha:1.00];
        self.lblEndOfPlay.text = [[Config shared] trans:@"다음 파일 재생"];
    }
    if (repeatOption == OPTION_PLY_REPEAT) {
        [self.lblRepeatOne setTextColor:[UIColor colorWithRed:0.843 green:0.847 blue:0.867 alpha:1.00]];
        self.btnPlayRepeat.tintColor = [UIColor colorWithRed:0.843 green:0.847 blue:0.867 alpha:1.00];;
        self.lblEndOfPlay.text = [[Config shared] trans:@"같은 파일 반복재생"];
    }
    if (repeatOption == OPTION_PLY_RANDOM) {
        self.btnPlayRandom.tintColor = [UIColor colorWithRed:0.843 green:0.847 blue:0.867 alpha:1.00];;
        self.lblEndOfPlay.text = [[Config shared] trans:@"랜덤 파일 재생"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)chgRepeatCount:(id)sender {
    
    UIButton* sndr = (UIButton*)sender;
    int currRepeatCount = [[Config shared] getRepeatCount];
    
    // FIND ThE INDEX OF CURRENT VALUE IN ARRAY
    // DEFAULT IS "INFINITE"
    NSInteger currIndex = [Config shared].arrRepeatCount.count -1;
    if (currRepeatCount != 0) // NOT INFINITE
        currIndex = [[Config shared].arrRepeatCount indexOfObject:@(currRepeatCount).description];
    
    // FIND NEXT INDEX TO GET VALUE FROM ARRAY
    NSInteger nextIndex = currIndex;
    if (sndr.tag == 1)
        nextIndex++;
    else nextIndex--;
    
    if (nextIndex == [Config shared].arrRepeatCount.count)
        nextIndex = 0;
    if (nextIndex < 0)
        nextIndex = [Config shared].arrRepeatCount.count -1;
    
    // GET NEXT VALUE FROM ARRAY BY USING NEXT INDEX
    // AND DISPLAY THE VALUE ON THE LABLE
    NSString* nextRepeatCount = [[Config shared].arrRepeatCount objectAtIndex:nextIndex];
    if ([nextRepeatCount isEqualToString:@"1"])
    {
        [[Config shared] setRepeatCount:1];
        self.lblRepeatCountValue.text = [[Config shared] trans:@"반복없음"];
    } else if ([nextRepeatCount isEqualToString:@"Infinite"])
    {
        [[Config shared] setRepeatCount:0];
        self.lblRepeatCountValue.text = [[Config shared] trans:@"무한반복"];
    } else {
        [[Config shared] setRepeatCount:nextRepeatCount.intValue];
        self.lblRepeatCountValue.text = [NSString stringWithFormat:@"%@ %@", nextRepeatCount,
                                         [[Config shared] trans:@"회"]];
    }
    
    // RESET CURRENT COUNT THAT MOVIE PLAYER IS REPEATING
    VCMoviePlayer* parent = (VCMoviePlayer*)self.parentViewController;
    parent.repeatCount = 0;
}

- (IBAction)chgPlaySpeed:(id)sender {
    //NSLog(@"- (IBAction)chgPlaySpeed:(id)sender");
    UIButton* sndr = (UIButton*)sender;
    float playSpeed = [Config shared].playSpeed;
    
    if (sndr.tag == 1)
        playSpeed = playSpeed + 0.1;
    else playSpeed = playSpeed - 0.1;
    
    self.lblPlaySpeedValue.text = [NSString stringWithFormat:@"%.1f X", playSpeed];
    [Config shared].playSpeed = playSpeed;
    
    VCMoviePlayer* parent = (VCMoviePlayer*)self.parentViewController;
    [parent pause];
    [parent play];
    
    [self playSpeedBtnEnble:playSpeed];
}

- (void)playSpeedBtnEnble:(float)pPlaySpeed {
    [self.btnSpeedUp setEnabled:(pPlaySpeed < 1.3)];
    [self.btnSpeedDown setEnabled:(pPlaySpeed > 0.7)];
}

- (IBAction)chgMinimumSenLen:(id)sender {
    
    UIButton* sndr = (UIButton*)sender;
    
    // SET MINIMUM SENTENCE LENGTH
    float senLen = [[Config shared] getMinimumSenSec];
    if (sndr.tag == 1)
        senLen = senLen + 0.5;
    else senLen = senLen - 0.5;
    [[Config shared] setMinimumSenSec:senLen];
    
    self.lblMinimumSenLenValue.text = [NSString stringWithFormat:@"%.1f %@",
                                       senLen,
                                       [[Config shared] trans:@"초"]];
    
    // MAKE NEW SENTENSES
    VCMoviePlayer* parent = (VCMoviePlayer*)self.parentViewController;
    
    [[SentGroup shared] createSentGroup:parent.movieFilePath
                              audioPath:parent.audioFilePath
                              audioDura:parent.movieTotalSec
                              direction:DIRECTION_NEW
                                currSec:parent.movieCurreSec];
    
    parent.currentSent = [[SentGroup shared]
                          getBySecond:parent.movieCurreSec
                          nextIfInBlank:YES];
    parent.secToStopForDetermine = parent.currentSent.endSec;
    [parent seekAt:parent.movieCurreSec playOnComplete:[parent isInPlaying]];
}

- (IBAction)chgCaptionSupport:(id)sender {
    UIButton* sndr = (UIButton*)sender;
    BOOL changeTo = [[Config shared] getCaptionOnOFF];
    [self setCaptionSupport:!changeTo button:sndr];

    VCMoviePlayer* parent = (VCMoviePlayer*)self.parentViewController;
    parent.viwSubtitle.hidden = [[Config shared] getCaptionOnOFF];
}

- (void)setCaptionSupport:(BOOL)pOnOff button:(UIButton*)pButton {
    if (pOnOff) {
        [pButton setImage:[UIImage imageNamed:@"icn_switch_on_50x30"]
                 forState:UIControlStateNormal];
        self.lblSubCaptionValue.text = @"On";
        pButton.tintColor = [UIColor colorWithRed:0.843 green:0.847 blue:0.867 alpha:1.00];
    } else {
        self.lblSubCaptionValue.text = @"Off";
        [pButton setImage:[UIImage imageNamed:@"icn_switch_off_50x30"]
                 forState:UIControlStateNormal];
        pButton.tintColor = [UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00];
    }
    [[Config shared] setCaptionOnOFF:pOnOff];
}

- (IBAction)chgEndOfPlay:(id)sender {
    
    self.btnPlayNext.tintColor = [UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00];
    [self.lblRepeatOne setTextColor:[UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00]];
    self.btnPlayRepeat.tintColor = [UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00];
    self.btnPlayRandom.tintColor = [UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00];
    
    UIButton* sndr = (UIButton*)sender;
    sndr.tintColor = [UIColor colorWithRed:0.843 green:0.847 blue:0.867 alpha:1.00];
    if (sndr.tag == 1) {
        [[Config shared] setAfterEndOfPlay:OPTION_PLY_NEXT];
        self.lblEndOfPlay.text = [[Config shared] trans:@"다음 파일 재생"];
    }
    if (sndr.tag == 2) {
        [[Config shared] setAfterEndOfPlay:OPTION_PLY_REPEAT];
        [self.lblRepeatOne setTextColor:[UIColor colorWithRed:0.843 green:0.847 blue:0.867 alpha:1.00]];
        self.lblEndOfPlay.text = [[Config shared] trans:@"같은 파일 반복재생"];
    }
    if (sndr.tag == 3) {
        [[Config shared] setAfterEndOfPlay:OPTION_PLY_RANDOM];
        self.lblEndOfPlay.text = [[Config shared] trans:@"랜덤 파일 재생"];
    }
}

@end
