//
//  VCMoviePlayer.h
//  repeater
//
//  Created by admin on 2016. 1. 14..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>
#import "AudioFromVideo.h"
#import "SentGroup.h"
#import "SentInfo.h"
#import "AudioVisualizer.h"

@class VCMoviePlayer;

@protocol protocolMoviePlayer <NSObject>
@required
- (void)onPlaying:(NSString*)pMovieFile duration:(float)pDuration
      currentSec:(float)pCurrentSec percentage:(float)pPercentage;
@end

@interface VCMoviePlayer : UIViewController <AVAudioPlayerDelegate, UITextViewDelegate,
                                ProtocalGraphFromVideo, protocolSentGroup>
{
    // COMPENET FOR MOVIE PLAYE
    AVAsset* _asset;
    AVPlayer* _player;
    AVPlayerLayer* _playerLayer;
    AVPlayerItem* _playerItem;
    
    // OBSERVER FOR CHANGING OS PLAYER STATE
    id _playerTimeObserver;
}

+(VCMoviePlayer*)shared;

@property (nonatomic, weak) id <protocolMoviePlayer> delegate;

- (IBAction)gestureOfSwipe:(id)sender;
- (IBAction)gestureOfTap:(id)sender;

- (IBAction)tchBtnBack:(id)sender;
- (IBAction)sldScrubbing:(UISlider*)sender;
- (IBAction)sldStartScrub:(id)sender;
- (IBAction)sldEndScrub:(id)sender;
- (IBAction)tchPlay:(id)sender;

/*-------------------
 CLEAN MOVIE PLAYER
 --------------------*/
- (void)clearPlayer;

/*-------------------
 CLEAN MOVIE PLAYER
 --------------------*/
- (void)setupPlayer:(NSString*)pFilePath
             parent:(UIViewController*)pParent
 funcNameOnComplete:(NSString*)pFuncNameOnComplete
          funcOwner:(NSObject*)pFuncOwner;
- (void)seekAt:(float)pSec playOnComplete:(BOOL)pPlayOnComplete;
- (void)showupOnParent:(UIViewController*)pParent;
- (void)saveCurrPlaying;
- (BOOL)loadSubtitle;

@property (copy, nonatomic) NSString* movieFilePath;
@property (copy, nonatomic) NSString* movieFileSize;
@property (assign, nonatomic) float movieTotalSec;
@property (assign, nonatomic) float movieCurreSec;
@property (copy, nonatomic) NSString* audioFilePath;

@property (weak, nonatomic) IBOutlet UILabel *lblTotalTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrRepeatCount;
@property (weak, nonatomic) IBOutlet UIButton *btnMute;
@property (weak, nonatomic) IBOutlet UIButton *btnPrev;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnConfig;
@property (weak, nonatomic) IBOutlet UIButton *btnRecorder;
@property (weak, nonatomic) IBOutlet UIButton *btnSameSen;
@property (weak, nonatomic) IBOutlet UIButton *btnAllowRepeat;
@property (weak, nonatomic) IBOutlet UISlider *sldProgress;

@property (weak, nonatomic) IBOutlet UIView *viwPlayScreen;
@property (weak, nonatomic) IBOutlet UIView *viwMenu;
@property (weak, nonatomic) IBOutlet UIView *viwMenuTop;
@property (weak, nonatomic) IBOutlet UIView *viwMenuBottomNavi;
@property (weak, nonatomic) IBOutlet UIView *viwConfig;
@property (weak, nonatomic) IBOutlet UIView *viwRecorder;
@property (weak, nonatomic) IBOutlet UIView *viwMenuBottomSpectrum;
@property (weak, nonatomic) IBOutlet UIView *viwSubtitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomOfViwSubTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constBottomOfViewPlayScreen;
@property (weak, nonatomic) UIViewController *vwcParent;
@property (weak, nonatomic) IBOutlet UITextView *viwText;
@property (weak, nonatomic) IBOutlet UIView *viwGesture;
@property (weak, nonatomic) IBOutlet UIView *viwCurrScroll;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrScrollTime;

@property (weak, nonatomic) IBOutlet UIImageView *imgSpectrumAnal;
@property (weak, nonatomic) IBOutlet UIImageView *imgSpectrum;
@property (weak, nonatomic) IBOutlet UIImageView *imgSpectrumOfCenter;
@property (weak, nonatomic) IBOutlet UIProgressView *prgConverting;
@property (weak, nonatomic) IBOutlet UILabel *lblConPercent;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (nonatomic, retain) NSArray* arrSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblNoScriptWarning;

@property (nonatomic, assign) int repeatCount;
@property (nonatomic, assign) BOOL playAfterDrawSentence;
//@property (nonatomic, assign) BOOL isSeekingPlayPosition;

@property (nonatomic, copy) NSString* funcNameToExecute;
@property (nonatomic, retain) NSObject* funcOwner;

@property (nonatomic, assign) float staSecOfSoundGraph;
@property (nonatomic, assign) float endSecOfSoundGraph;

@property (nonatomic, retain) SentInfo* currentSent;

@property (nonatomic, retain) UIImage* imgTotGraphDigita;
@property (nonatomic, retain) UIImage* imgTotGraphAnalog;
@property (nonatomic, retain) UIImage* imgTotGraphSenten;
@property (nonatomic, assign) float staSecOfTotSoundGraph;
@property (nonatomic, assign) float endSecOfTotSoundGraph;
@property (nonatomic, assign) float secToStopForDetermine;
@property (nonatomic, assign) float frmAmtPer1Sec;
@property (nonatomic, assign) BOOL isScrubing;
@property (nonatomic, assign) BOOL isStopToRepeat;
@property (nonatomic, assign) float heightOfScriptView;
@property (nonatomic, copy) NSString* scriptNoSpace;
@property (nonatomic, assign) BOOL isItOkayToShowScrollTime;
@property (nonatomic, assign) BOOL isOneTimePassNoRepeat;

//@property (nonatomic, assign) CGPoint startLocationOfSwipe;
@property (weak, nonatomic) IBOutlet UIView *viwAudioVisualGraph;
@property (nonatomic, retain) AudioVisualizer *audioVisualizer;
@property (weak, nonatomic) IBOutlet UIView *viwAudioVisualBase;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConsOfViwAudioVisualBase;

- (IBAction)tchNextSen:(id)sender;
- (IBAction)tchPrevSen:(id)sender;
- (IBAction)tchSameSen:(id)sender;
- (IBAction)tchRepeatAllow:(id)sender;
- (IBAction)tchMakeCountTo1:(id)sender;
- (IBAction)tchConfig:(id)sender;
- (IBAction)tchRecorder:(id)sender;
- (IBAction)tchMute:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viwTextBottonCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viwTextTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viwGestureTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viwGestureBottomCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viwCurrScrollTopCons;

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
- (void)applicationDidEnterBackground:(NSNotification *)notification;

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;

/*--------------------------------
 METHOD FOR PLAYING PREV SENTENCE
 ---------------------------------*/
- (void)playPrevSentence;

/*--------------------------------
 METHOD FOR PLAYING NEXT SENTENCE
 ---------------------------------*/
- (void)playNextSentence;

- (void)play;
- (void)pause;
- (void)playOpause;
- (BOOL)isInPlaying;

@property (weak, nonatomic) IBOutlet UIButton *btnImgInVisual;
@property (weak, nonatomic) IBOutlet UILabel *lblFileNameInVisual;
@property (weak, nonatomic) IBOutlet UILabel *lblFileLenInVisual;

/*---------------------------------------
 현재시간을 기준으로 양역 40초 분량의 이미지를 반환
 ----------------------------------------*/
- (void)getSentImageIn80Sec:(float)pTotDuration
                    currSec:(float)pCurrSec
                  analogImg:(UIImage**)pAnalogImg
                  digitaImg:(UIImage**)pDigitaImg
                  sentenImg:(UIImage**)pSentenImg;

@end
