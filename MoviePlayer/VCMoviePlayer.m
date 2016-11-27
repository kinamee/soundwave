//
//  VCMoviePlayer.m
//  repeater
//
//  Created by admin on 2016. 1. 14..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCMoviePlayer.h"
#import "Config.h"
#import "VCMovieConfig.h"
#import "VCVoiceRecorder.h"
#import "KSPath.h"
#import "TblContFile.h"
#import "TblContFileHelper.h"
#import "GraphFromAudio.h"
#import "AudioFromVideo.h"
#import "UIImage+Category.h"
#import "VCMoviePlayerHelper.h"
#import "SubTitle.h"
#import "SubTitleCaption.h"
#import "UIAlertController+Blocks.h"
#import "UIImage+Category.h"
#import "SentGroup.h"
#import "SentInfo.h"
#import <AVFoundation/AVFoundation.h>

@interface VCMoviePlayer ()

@end

static VCMoviePlayer* instance = nil;
static BOOL isWaitingDoubleTap = NO;

@implementation VCMoviePlayer

/*----------------------------------
 SINGLETON IMPLEMENTATION OF CLASS
 -----------------------------------*/
+(VCMoviePlayer*)shared {
    if (instance == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        instance = [storyboard instantiateViewControllerWithIdentifier:@"MoviePlayer"];
        [SentGroup shared].delegate = instance;
    }
    return instance;
}

/*------------------------------------
 VIEW LOADED, INITINALIZATION OF VARS
 -------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad VCMoviePlayer");
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
        NSLog(@"Error setting up audio session category: %@",
              error.localizedDescription);

    [session setActive:YES error:&error];
    if (error)
        NSLog(@"Error setting up audio session active: %@",
              error.localizedDescription);
    
    // FOR DETECTING SCREEN RETATION
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // INIT TIME LABLE
    self.lblTotalTime.text   = @"00:00";
    self.lblCurrentTime.text = @"00:00";
    
    // INIT PROGRESS FOR CONVERTING VIDEO TO AUDIO SPECTRUM
    self.imgSpectrum.hidden   = YES;
    self.imgSpectrumOfCenter.hidden = YES;
    self.prgConverting.hidden = YES;
    self.lblConPercent.hidden = YES;
    
    // INIT CONIFG VIEW
    self.viwConfig.hidden   = YES;
    self.viwRecorder.hidden   = YES;
    self.viwSubtitle.hidden = YES;
    self.lblSubtitle.text   = @"";
    
    // INIT HELPER
    [VCMoviePlayerHelper shared].needHelp = self;
    
    // TAP ON TEXTVIEW
    UITapGestureRecognizer *tapOnTextView = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleTapOnTextView:)];
    tapOnTextView.numberOfTapsRequired = 1;
    [self.viwText addGestureRecognizer:tapOnTextView];
    self.viwText.delegate = self;
}

/*---------------------
 TAP ON TEXT VIEW AREA
 ----------------------*/
- (void)handleTapOnTextView:(id)sender
{
    // 콘피그나 레코더가 떠 있다면 내려라
    if (self.viwConfig.hidden == NO) {
        [self tchConfig:nil];
        return;
    }
    // 콘피그나 레코더가 떠 있다면 내려라
    if (self.viwRecorder.hidden == NO) {
        [self tchRecorder:nil];
        return;
    }
    
    // 스크립트 모드에서 메뉴숨겨져 있다면 무조건 보여라
    if (self.viwText.hidden == NO) {
        if (self.viwMenu.hidden == YES) {
            [self menuShowHide];
            return;
        }
    }
    
    OPTION_TypeOnGestureAction action = [[Config shared] getGesture:OPTION_GES_SINGLE];
    [self doActionForGesture:action];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // ON SCROLL START, HIDE CURRENT POSITION TIME
    self.viwCurrScroll.hidden = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.viwCurrScroll.hidden = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isItOkayToShowScrollTime = YES;
}

-(NSRange)visibleRangeOfTextView:(UITextView *)textView {
    CGRect bounds = textView.bounds;
    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))].end;
    return NSMakeRange([textView offsetFromPosition:textView.beginningOfDocument toPosition:start],
                       [textView offsetFromPosition:start toPosition:end]);
}

/*--------------------------------------
 MP3+스크립트일 경우 스크립트 텍스트뷰를 스크롤한댜
 ---------------------------------------*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // ONLY DO IN MODE OF SCRIPT
    if (self.viwText.hidden == YES)
        return;
    
    // 스크롤바 위치
    [self.viwText sizeThatFits:CGSizeMake(self.viwText.frame.size.width, FLT_MAX)];
    self.heightOfScriptView = self.viwText.contentSize.height;
    if (self.heightOfScriptView == 0)
        return;
    
    if (self.isItOkayToShowScrollTime == YES)
        self.viwCurrScroll.hidden = NO;
    
    // 위치비율 확인
    float scrollRatio = (scrollView.contentOffset.y / self.heightOfScriptView);
    float visibleHeight = scrollView.frame.size.height;
    float yToGo = visibleHeight * scrollRatio;
    if (self.viwMenu.hidden == NO)
        yToGo = yToGo + self.viwMenuTop.frame.size.height;
    
    //NSLog(@"비지블부분 높이:%.2f 퍼센트:%.2f 이동위치:%.2f", visibleHeight, scrollRatio, yToGo);
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.0 animations:^{
            self.viwCurrScrollTopCons.constant = yToGo;
        } completion:nil];
    
        // 현재라인 위치 찾기
        NSRange range = [self visibleRangeOfTextView:self.viwText];
        NSString *stringToRange = [self.viwText.text substringWithRange:range];
        stringToRange = [stringToRange stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        stringToRange = [stringToRange stringByReplacingOccurrencesOfString:@" " withString:@""];
        //NSLog(@"%li 전체길이:%li",
        //      [self.scriptNoSpace rangeOfString:stringToRange].location,
        //      self.scriptNoSpace.length);
        NSInteger curLine = ([self.scriptNoSpace rangeOfString:stringToRange].location +
                             [self.scriptNoSpace rangeOfString:stringToRange].length / 2.0);
        NSInteger totLine = self.scriptNoSpace.length;
        float percent = (curLine * 100 / totLine);
        
        //NSLog(@"현재길이:%li 전체길이:%li 퍼센트:%.2f", curLine, totLine, percent);
        
        // GET TIME RELATED TO CURRENT SCROLL
        float currSecToPos = (self.movieTotalSec) * (percent / 100);
        if (currSecToPos < 0)
            currSecToPos = 0;
        NSString* formattedTime = [[Config shared] timeFormatted:currSecToPos];
        //dispatch_async(dispatch_get_main_queue(), ^{
        self.lblCurrScrollTime.text = formattedTime;
    });
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
-(void)viewDidAppear:(BOOL)animated
{
    [self resizeGestureView];
    [self orientationChanged:nil];    
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    //NSLog(@"remoteControlReceivedWithEvent");
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:
            //NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
            [self playOpause];
            break;
        case UIEventSubtypeRemoteControlPlay:
            //NSLog(@"UIEventSubtypeRemoteControlPlay");
            [self play];
            break;
        case UIEventSubtypeRemoteControlPause:
            //NSLog(@"UIEventSubtypeRemoteControlPause");
            [self pause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            //NSLog(@"UIEventSubtypeRemoteControlNextTrack");
            [self playNextSentence];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            //NSLog(@"UIEventSubtypeRemoteControlNextTrack");
            [self playPrevSentence];
            break;
        default:
            break;
    }
}

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    //NSLog(@"백그라운드 진입 뮤비플레이어 뷰에서 이벤트 받음");
    if ([self isInPlaying])
        [_player performSelector:@selector(play) withObject:nil afterDelay:0.01];
}

/*-----------------------------------------------------
 SHOW MYSELF AS A MODAL VIEW ON PARENT VIEW-CONTROLLER
 ------------------------------------------------------*/
- (void)showupOnParent:(UIViewController*)pParent
{
    // SHOW THIS VIEW
    self.vwcParent = pParent;
    
    UIViewController *topController =
    [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
        topController = topController.presentedViewController;
    
    [self setModalPresentationStyle:UIModalPresentationFullScreen];
    [topController presentViewController:self animated:YES completion:nil];
}

/*-----------------------------------------
 BACK BUTTON TOUCH TO CLOSE MOVIE PLAYER
 -----------------------------------------*/
- (IBAction)tchBtnBack:(id)sender
{
    // CLOSE CONFIG VIEW
    self.viwConfig.hidden = YES;
    self.viwRecorder.hidden = YES;
    self.viwSubtitle.hidden = YES;
    self.lblSubtitle.text = @"";
    
    // CLOSE SELF VIEW
    [[self presentingViewController]
     dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupPlayer:(NSString*)pFilePath
             parent:(UIViewController*)pParent
     funcNameOnComplete:(NSString*)pFuncNameOnComplete
          funcOwner:(NSObject*)pFuncOwner
{
    /*--------------------------------------
     SET FUNCTION TO PLAY ON SETUP COMPLETE
     ---------------------------------------*/
    self.funcNameToExecute = pFuncNameOnComplete;
    self.funcOwner = pFuncOwner;
    
    /*---------------------
     SET PARENT CONTROLLER
     ----------------------*/
    self.vwcParent = pParent;
    
    /*---------------------
     PLAYER BUTTONS ADJUST
     ----------------------*/
    [self repositionPlayerButton];
    
    /*---------------------------------------------
     IF SAME FILE IS ON RUNNING? DO NOT RE-SETTING
     ----------------------------------------------*/
    BOOL isSameFile = [pFilePath isEqualToString:self.movieFilePath];
    if (isSameFile)
    {
        if ([self isInPlaying])
            return; //--SAME FILE IS PLAYING
        else {
            return; //--SAME FILE IS PAUSED
        }
    }
    
    // SET SELF PROPERTY OF MOVIE FILE INFO
    self.movieFilePath = pFilePath;
    self.movieFileSize = [[KSPath shared] getFileSize:self.movieFilePath];
    
    /*--------------------------
     SETUP PLAYER WITH NEW FILE
     ---------------------------*/
    self.repeatCount = 0;
    [self setupPlayer:self.movieFilePath];
    
    /*----------------
     ERROR FILE CHECK
     -----------------*/
    if (self.movieTotalSec == 0)
    {
        [self msgForErrFile];
        return;
    }
    
    // WAIT UNTIL PLAYER'S SETUP COMPLETE
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self
                                   selector:@selector(onTimeCreatePlayer:)
                                   userInfo:nil repeats:NO];
}

- (void)onTimeCreatePlayer:(id)sender
{
    if ((_player.status != AVPlayerItemStatusReadyToPlay) ||
        (_playerItem.status != AVPlayerItemStatusReadyToPlay))
    {
        [NSTimer scheduledTimerWithTimeInterval:0.25 target:self
                                       selector:@selector(onTimeCreatePlayer:)
                                       userInfo:nil repeats:NO];
        return;
    }
    
    /*----------------------
     오디오 파일 경로를 만들어준다
     -----------------------*/
    self.audioFilePath = [[AudioFromVideo shared] audioFilePath:self.movieFilePath];
    //NSLog(@"-");
    //NSLog(@"오디오 파일 경로: %@", self.audioFilePath);
    
    // 재생기록이 있는지 확인하고 없다면 시작위치로 있다면 해당위치로 이동하자
    float secToPlay = [[Config shared] secFromHistory:self.movieFilePath];
    //NSLog(@"플레이할 시간: %2.f", secToPlay);
    //NSLog(@"문장제작 시작");
    
    // 문장 만들기 시작한다
    [[SentGroup shared] createSentGroup:self.movieFilePath
                              audioPath:self.audioFilePath
                              audioDura:self.movieTotalSec
                              direction:DIRECTION_NEW
                                currSec:secToPlay];
    
    // 현재문장과 반복확인 시간을 설정
    self.currentSent = [[SentGroup shared] getBySecond:secToPlay nextIfInBlank:YES];
    self.secToStopForDetermine = self.currentSent.endSec;
    [self seekAt:secToPlay playOnComplete:NO];
    
    // EXECUTE FUNCTION BY NAME JUST ONE TIME
    // WHEN PLAYER IS READY TO PLAY (SETUP IS COMPLETE)
    dispatch_async(dispatch_get_main_queue(), ^
    {
        // 스크린 레이어 다시한번 그려주자
        [self orientationChanged:nil];
        
        // 플레이 준비완료 콜백펑션 실행해주자
        if (![self.funcNameToExecute isEqualToString:@""])
        {
            SEL selector = NSSelectorFromString(self.funcNameToExecute);
            ((void (*)(id, SEL))[self.funcOwner methodForSelector:selector])(self.funcOwner, selector);
            self.funcNameToExecute = @"";
        }
    });
    
    return;
}

/*-------------------
 CLEAN MOVIE PLAYER
 --------------------*/
- (void)clearPlayer {
    
    if (_player != nil)
    {
        [_player removeTimeObserver:_playerTimeObserver];
        [_playerLayer removeFromSuperlayer];
    }
    
    _asset       = nil;
    _player      = nil;
    _playerItem  = nil;
    _playerLayer = nil;
}

/*----------------------------------
 SETUP PLAYER WITH VIDEO FILE PATH
 -----------------------------------*/
- (void)setupPlayer:(NSString*)pFilePath
{
    /*---------------------
     INITIALIZATION PLAYER
     ----------------------*/
    [self clearPlayer];
    
    NSURL* urlToPlay = [NSURL fileURLWithPath:self.movieFilePath];
    
    // PREPARE VIDEO PLAYER
    _asset = [AVAsset assetWithURL:urlToPlay];
    _playerItem = [AVPlayerItem playerItemWithAsset:_asset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    // SET SELF PROPERTY
    CMTime duration = _player.currentItem.asset.duration;
    float totSecond = CMTimeGetSeconds(duration);
    self.movieTotalSec = totSecond;
    self.movieCurreSec = [[Config shared] secFromHistory:self.movieFilePath];
    
    // SET TOTAL LENGTH
    self.lblTotalTime.text = [self timeFormatted:CMTimeGetSeconds(duration)];
    
    // SCREEN SET
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [_playerLayer setFrame:
     CGRectMake(self.viwPlayScreen.bounds.origin.x,
                self.viwPlayScreen.bounds.origin.y,
                self.viwPlayScreen.bounds.size.width,
                self.viwPlayScreen.bounds.size.height)];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.viwPlayScreen.layer addSublayer:_playerLayer];
    
    // EVENT SET FOR PROGRESS
    CMTime interval = CMTimeMake(33, 1000); // 30FPS
    __block NSObject *blockSelf = self;
    _playerTimeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:NULL
                                                           usingBlock:^(CMTime time)
                           { [(VCMoviePlayer*)blockSelf updateInPlaying]; }];
    
    // SHOW PROGRESS
    self.imgSpectrum.hidden = NO;
    self.imgSpectrumOfCenter.hidden = NO;
    
    // LOAD SUBTITLE
    [self loadSubtitle];
    
    // LOAD TEXT SCRIPT OR OPEN VISUALIZATION
    self.viwText.hidden = YES;
    self.viwAudioVisualBase.hidden = YES;
    
    BOOL scriptLoaded = [self loadTextScript];
    NSString* extention = self.movieFilePath.pathExtension.uppercaseString;
    if ([extention isEqualToString:@"MP3"] ||
        [extention isEqualToString:@"M4A"])
    {
        self.viwText.hidden = (scriptLoaded == NO);
        self.viwAudioVisualBase.hidden = (scriptLoaded == YES);
        
        if (scriptLoaded == NO)
        {
            // VISULIZATION OPEN
            // NSLog(@"비쥬얼라이제이션 켬");
            CGRect frame = CGRectMake(0, 0, 300, 64);
            //CGRect frame = self.viwAudioVisualGraph.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            //NSLog(@"x(%.2f) y(%.2f) w(%.2f) h(%.2f)", frame.origin.x, frame.origin.y,
            //      frame.size.width, frame.size.height);
            
            if (self.audioVisualizer == nil) {
                self.audioVisualizer = [[AudioVisualizer alloc]
                                        initWithBarsNumber:12
                                        frame:frame
                                        andColor:[UIColor whiteColor]];
                [self.viwAudioVisualGraph addSubview:self.audioVisualizer];
            }
            
            self.lblFileNameInVisual.text = self.movieFilePath.lastPathComponent.stringByDeletingPathExtension;
            self.lblFileLenInVisual.text = [NSString stringWithFormat:@"%@ %@ Type Length [%@]",
                              self.movieFileSize,
                              self.movieFilePath.pathExtension.uppercaseString,
                              [[Config shared] timeFormatted:self.movieTotalSec]];
        }
    }
    
    // SET PLAY SEED AS DEFAULT
    [Config shared].playSpeed = 1.0;
    [[VCMovieConfig shared] playSpeedBtnEnble:1.0];
    
    // SET PLAYER VOLUME
    [self turnOffvolume:[Config shared].isVolumeMuted];
    
    // SET ALLOW REPEAT
    self.isStopToRepeat = NO;
    [self turnOffRepeat:self.isStopToRepeat];
}

/*------------------
 IS LANDSCAPE MODE
 -------------------*/
- (BOOL)isLandscapeMode
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    return isLandscape;
}

/*----------------
 LOAD TEXT SCRIPT
 -----------------*/
- (BOOL)loadTextScript
{
    NSString* txtFilePath = [[KSPath shared]
                             changeFileNameByNewExt:self.movieFilePath
                             newExt:@".TXT"];
    if ([[KSPath shared] isExistPath:txtFilePath] == NO) {
        self.lblNoScriptWarning.numberOfLines = 0;
        self.lblNoScriptWarning.text = [[Config shared] trans:@"스크립트가 없습니다"];
        return NO;
    }
    
    NSString* content = [NSString stringWithContentsOfFile:txtFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    if (content == nil) {
        txtFilePath = [[KSPath shared]
                       changeFileNameByNewExt:self.movieFilePath
                       newExt:@".txt"];
        content = [NSString stringWithContentsOfFile:txtFilePath
                                            encoding:NSUTF8StringEncoding
                                               error:NULL];
        content = [content stringByReplacingOccurrencesOfString:@"\n\n\n\n" withString:@"\n\n"];
    }
    
    self.viwText.hidden = NO;
    [self.viwText setText:content];
    [self.viwText setContentOffset:CGPointZero animated:YES];
    
    // SAVE WHOLE HEIGHT OF TEXT SCRIPT VIEW
    NSString* contentNoSpace = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    contentNoSpace = [contentNoSpace stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.scriptNoSpace = contentNoSpace;
    
    [self.viwText sizeThatFits:CGSizeMake(self.viwText.frame.size.width, FLT_MAX)];
    self.heightOfScriptView = self.viwText.contentSize.height;
    self.viwCurrScroll.hidden = YES;
    
    return YES;
}

/*-----------------
 LOAD SUBTITLE FIE
 ------------------*/
- (BOOL)loadSubtitle
{
    [[SubTitle shared] loadSRT:self.movieFilePath];
    
    // DETERMINE SUBTITLE WILL BE SHOWN
    self.lblSubtitle.text = @"";
    self.viwSubtitle.hidden = (([SubTitle shared].isLoaded) == NO);
    
    return [SubTitle shared].isLoaded;
}

/*------------------------------
 사운드 그펙트럼 그릴 때 호출되는 메소드
 -------------------------------*/
- (void)onDrawingSpectrum:(float)pTotal current:(float)pCurrent
{
    return;
}

/*----------------------
 문장 그릴 때 호출되는 메소드
 -----------------------*/
- (void)onDrawingSentenceOnSpectrum:(float)pTotal current:(float)pCurrent
{
    return;
}

/*---------------------------------
 SAVE CURRENT FILE AS A LATEST ONE
 ----------------------------------*/
- (void)saveCurrPlaying {
    //NSLog(@"최신플레이 정보 저장: %@", self.movieFilePath.lastPathComponent);
    
    [[Config shared] setRecentPlaying:self.movieFilePath
                                 fileSize:self.movieFileSize
                                 curreSec:self.movieCurreSec
                                 totalSec:self.movieTotalSec];
}

/*---------------------
  GET STATE OF PLAYER
 ----------------------*/
- (BOOL)isInPlaying {
    // NO WHEN FINISH AND PAUSE
    if (_player.rate > 0 && _player.error == nil)
        return YES;
    return NO;
}

/*-----------------------------------------------
 GET STATE WHERE MOVIE PLAYER IS PAUSE OR FINISH
 ------------------------------------------------*/
- (BOOL)isPauseOrFinish {
    // PAUSE = YES, FINISH = NO
    double duration = CMTimeGetSeconds(_playerItem.duration);
    double time = CMTimeGetSeconds(_player.currentTime);
    if (duration == time) {
        //NSLog(@"FINISH");
        return NO;
    }
    //NSLog(@"PAUSE");
    return YES;
}

/*---------------------------------------------
 WHEN MOVIE PLAYER FINISH PLAYING A MOVIE FILE
 ----------------------------------------------*/
- (void)nextActionOnEndPlaying
{
    // IF CONFIG-VIEW IS SHOWN
    if (!self.viwConfig.hidden)
        [self tchConfig:nil];
    
    if (!self.viwRecorder.hidden)
        [self tchRecorder:nil];
    
    // 다음재생할 파일 기본값은 자신
    NSString* nextMovie = self.movieFilePath;
    self.movieFilePath = @"";
    
    // GET ACTION ON END OF PLAYING
    OPTION_TypeOnPlayEnd opt = [[Config shared] getAfterEndOfPlay];
    if (opt == OPTION_PLY_REPEAT)
    {
    }
    
    // FIND NEXT FILE TO PLAY
    if (opt == OPTION_PLY_NEXT)
    {
        nextMovie = [(TblContFile*)self.vwcParent
                     nextMovieFile:self.movieFilePath];
    }
    
    // FIND NEXT RANDOM TO PLAY
    if (opt == OPTION_PLY_RANDOM)
    {
        nextMovie = [(TblContFile*)self.vwcParent
                     randomMovieFile:self.movieFilePath];
    }
    
    // 처음부터 재생하기 위해 재생 히스토리에서 삭제한다
    [[Config shared] removeFromHistory:nextMovie];
    [self clearPlayer];
    
    // 플레이어 셋업 후 플레이
    [self setupPlayer:nextMovie
               parent:(TblContFile*)self.vwcParent
   funcNameOnComplete:@"play"
            funcOwner:self];
}

/*---------------------
 ADJUST PLAYER BUTTONS
 ----------------------*/
- (void)repositionPlayerButton {
    
    CGFloat scrwidth = [UIScreen mainScreen].bounds.size.width;
    
    //NSLog(@"SCRWIDTH:%.2f", scrwidth);
    CGFloat aWidth = (scrwidth / 6.0);
    CGFloat halfAWidth = (aWidth / 2.0);
    
    self.btnMute.center        = CGPointMake(aWidth * 1 - halfAWidth, self.btnMute.center.y);
    self.btnPrev.center        = CGPointMake(aWidth * 2 - halfAWidth, self.btnPrev.center.y);
    self.btnPlay.center        = CGPointMake(aWidth * 3 - halfAWidth, self.btnPlay.center.y);
    self.btnNext.center        = CGPointMake(aWidth * 4 - halfAWidth, self.btnNext.center.y);
    self.btnRecorder.center    = CGPointMake(aWidth * 5 - halfAWidth, self.btnRecorder.center.y);
    self.btnConfig.center      = CGPointMake(aWidth * 6 - halfAWidth, self.btnConfig.center.y);
}

/*-------------------------
 EVENT ON DEVICE ROTATION
 --------------------------*/
- (void)orientationChanged:(NSNotification *)note
{
    //NSLog(@"- (void)orientationChanged:(NSNotification *)note");
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
    
    // ADJUST MENU VIEW
    if (isLandscape) {
        // LANDSCAPE
        self.viwMenuBottomSpectrum.hidden = YES;
        self.viwMenu.hidden = YES;
        self.viwConfig.hidden = YES;
        self.btnConfig.enabled = NO;
        self.viwRecorder.hidden = YES;
        self.btnRecorder.enabled = NO;
    }
    else {
        // PORTRAIT
        self.viwMenuBottomSpectrum.hidden = NO;
        self.viwMenu.hidden = NO;
        self.btnConfig.enabled = YES;
        self.btnRecorder.enabled = YES;
    }
    
    // ADJUST VIDEO SCREEN SIZE
    if (_playerLayer != nil)
    {
        float bottomLenOfVisualizationView = 0;
        
        if (self.viwRecorder.hidden && self.viwConfig.hidden)
        {
            [_playerLayer setFrame:
             CGRectMake(self.viwPlayScreen.bounds.origin.x,
                        self.viwPlayScreen.bounds.origin.y,
                        self.viwPlayScreen.bounds.size.width,
                        self.viwPlayScreen.bounds.size.height)];
        } else {
            // MAKE MOVE PLAYER SIZE LARGE
            [_playerLayer setFrame:
             CGRectMake(self.viwPlayScreen.bounds.origin.x,
                        self.viwPlayScreen.bounds.origin.y,
                        self.viwPlayScreen.bounds.size.width,
                        self.viwPlayScreen.frame.size.height -
                        (self.viwConfig.frame.size.height +
                         self.viwMenuBottomNavi.frame.size.height))];
            
            bottomLenOfVisualizationView = self.viwConfig.frame.size.height * 0.325;
        }
        
        // VISULIZATION VIEW SIZE CHANGE
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomConsOfViwAudioVisualBase.constant = bottomLenOfVisualizationView;
        } completion:nil];
    }
    
    // ADJUST SCRIPT VIEW SCREEN SIZE
    self.viwCurrScroll.hidden = YES;
    if (self.viwText.hidden == NO)
    {
        /*----------------
         RESIZE TEXT VIEW
         -----------------*/
        [self resizeScriptView];
        self.viwGesture.hidden = (isLandscape);
    }
    
    // REPOSITION PLAYER BUTTONS
    [self repositionPlayerButton];
    
    // ADJUST SUBTITLE VIEW
    [self repositionSubtitle];
}

/*--------------------
 GESTURE VIEW RESIZE
 ---------------------*/
- (void)resizeGestureView
{
    BOOL isLandscape = [self isLandscapeMode];
    BOOL isScriptMode = (self.viwText.hidden == NO);
    
    // 스크립트모드이면서 가로화면이면 터치스크린 없앰
    if (isScriptMode && isLandscape) {
        self.viwGesture.hidden = YES;
        return;
    }

    self.viwGesture.hidden = NO;
    // 스크립트모드이면서 세로화면이면 터치스크린은 하단 화면의 4분의 1을 차지
    if (isScriptMode && isLandscape == NO) {
        [UIView animateWithDuration:0.0 animations:^{
            self.viwGestureTopCons.constant = round(self.view.frame.size.height * 0.718);
            [self.view layoutIfNeeded];
        } completion:nil];
        return;
    }
    
    // 그 외의 경우라면 터치스크린은 전체화면에서 상단 하단 조금씩만 제외
    [UIView animateWithDuration:0.0 animations:^{
        self.viwGestureTopCons.constant = 39.0;
        [self.view layoutIfNeeded];
    } completion:nil];
}

/*------------------------
 SCRIPT VIEW (MP3) RESIZE
 -------------------------*/
- (void)resizeScriptView
{
    [self resizeGestureView];
    
    if (self.viwMenu.hidden == NO)
    {
        // MENU ON
        [UIView animateWithDuration:0.1 animations:^{
            self.viwTextTopCons.constant = 40.0;
            [self.view layoutIfNeeded];
        } completion:nil];
        
        if ([self isLandscapeMode])
            [UIView animateWithDuration:0.1 animations:^{
                self.viwTextBottonCons.constant = 50.0;
                [self.view layoutIfNeeded];
            } completion:nil];
        else
            [UIView animateWithDuration:0.1 animations:^{
                self.viwTextBottonCons.constant = 130;
                [self.view layoutIfNeeded];
            } completion:nil];
        
    } else {
        // MENU OFF
        [UIView animateWithDuration:0.1 animations:^{
            self.viwTextTopCons.constant = 0.0;
            [self.view layoutIfNeeded];
        } completion:nil];
        
        [UIView animateWithDuration:0.1 animations:^{
            self.viwTextBottonCons.constant = 0.0;
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)repositionSubtitle {
    //return;
    [[VCMoviePlayerHelper shared] repositionSubtitle];
}

/*----------------
 GESTURE OF SWIPE
 -----------------*/
- (IBAction)gestureOfSwipe:(id)sender
{
    UISwipeGestureRecognizer* gesture = (UISwipeGestureRecognizer*)sender;
    OPTION_TypeOnGestureAction action = OPTION_GAT_NONE;
    //NSLog(@"SWIPE GESTURE EVENT");
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        //NSLog(@"오른쪽");
        action = [[Config shared] getGesture:OPTION_GES_RIGHT];
    }
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        //NSLog(@"왼쪽");
        action = [[Config shared] getGesture:OPTION_GES_LEFT];
    }
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        //NSLog(@"위쪽");
        action = [[Config shared] getGesture:OPTION_GES_UP];
    }
    if (gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        //NSLog(@"아래쪽");
        action = [[Config shared] getGesture:OPTION_GES_DOWN];
    }
    [self doActionForGesture:action];
}

- (IBAction)gestureOfTap:(id)sender {
    if (isWaitingDoubleTap) {
        //NSLog(@"더블탭");
        isWaitingDoubleTap = NO;
        
        OPTION_TypeOnGestureAction action = [[Config shared] getGesture:OPTION_GES_DOUBLE];
        [self doActionForGesture:action];
        return;
    }
    isWaitingDoubleTap = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.25
                                     target:self
                                   selector:@selector(singleTapTimeOut:)
                                   userInfo:nil
                                    repeats:NO];
}
-(void)singleTapTimeOut:(NSTimer*)timer
{
    if (isWaitingDoubleTap) {
        //NSLog(@"싱글탭");
        [timer invalidate];
        isWaitingDoubleTap = NO;
        
        // 콘피그나 레코더가 떠 있다면 내려라
        if (self.viwConfig.hidden == NO) {
            [self tchConfig:nil];
            return;
        }
        // 콘피그나 레코더가 떠 있다면 내려라
        if (self.viwRecorder.hidden == NO) {
            [self tchRecorder:nil];
            return;
        }
        
        OPTION_TypeOnGestureAction action = [[Config shared] getGesture:OPTION_GES_SINGLE];
        [self doActionForGesture:action];
    }
}

/*-----------------
 EXECUTE GUESTURE
 ------------------*/
- (void)doActionForGesture:(OPTION_TypeOnGestureAction)pAction
{
    if (pAction == OPTION_GAT_PLAY)
        [self playOpause];
    if (pAction == OPTION_GAT_MENU)
        [self menuShowHide];
    if (pAction == OPTION_GAT_PREV)
        [self playPrevSentence];
    if (pAction == OPTION_GAT_NEXT)
        [self playNextSentence];
    if (pAction == OPTION_GAT_BACK)
        [self tchBtnBack:nil];
    if (pAction == OPTION_GAT_SAME)
        [self playSameSentence];
    if (pAction == OPTION_GAT_PASS)
        self.isOneTimePassNoRepeat = YES;
}

/*-----------------
 MENU SHOW OR HIDE
 ------------------*/
- (void)menuShowHide {
    
    // IF CONFIG-VIEW SHOWN, DO NOT ANYTHING
    if (!self.viwConfig.hidden)
        return;
    if (!self.viwRecorder.hidden)
        return;
    
    // MENU SHOW ON-OFF
    self.viwMenu.hidden = !self.viwMenu.hidden;
    
    /*----------------
     RESIZE TEXT VIEW
     -----------------*/
    if (self.viwText.hidden == NO)
        [self resizeScriptView];
    
    // REPOSITIONING SUBTITLE VIEW
    [self repositionSubtitle];
}

// CONVERT SECONDS
// TO 00:00:00 TIME FORMAT
- (NSString*)timeFormatted:(int)totalSeconds
{
    return [[Config shared] timeFormatted:totalSeconds];
}

/*---------------------------------
 SET CURRENT REPEAT COUNT ON LABEL
 ----------------------------------*/
- (void)setRepeatCountOnLabel
{
    // IF REPEAT IS ON INFINITELY
    if ([[Config shared] getRepeatInfiniteOnOff])
    {
        if (self.isOneTimePassNoRepeat == YES)
            self.lblCurrRepeatCount.text = @"1";
        else self.lblCurrRepeatCount.text = @"E";
        return;
    }

    int cntRemainder = [[Config shared] getRepeatCount] - self.repeatCount;
    if (self.isOneTimePassNoRepeat == YES)
        cntRemainder = 1;
    self.lblCurrRepeatCount.text = [NSString stringWithFormat:@"%d", cntRemainder];
}

/*--------------------------------
 PRESENT SENTENCE GRAPH ON SCREEN
 ---------------------------------*/
- (void)displaySentenceGraphOnScreen:(float)pCurrSec {

    // 발견된 문장이 없는 상태라면..?
    if ([[SentGroup shared] countOfallSen] == 0)
        return;
    
    if (self.frmAmtPer1Sec == 0)
        return;
    
    UIImage* imgToDigitaGraph;
    UIImage* imgToAnalogGraph;
    UIImage* imgToSentenGraph;
    
    [self getSentImageIn80Sec:self.movieTotalSec
                      currSec:pCurrSec
                    analogImg:&imgToAnalogGraph
                    digitaImg:&imgToDigitaGraph
                    sentenImg:&imgToSentenGraph];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // SET THE CROPED IMAGE TO SCREEN
        [self.imgSpectrum setImage:imgToSentenGraph];
        [self.imgSpectrumAnal setImage:imgToAnalogGraph];
        
        // 중앙 아날로그 그래프를 3 프레임 만큼 짜르자
        // 10 넓이 뷰에 STECTCH 효과로 뿌린다
        float centerFrame = imgToAnalogGraph.size.width / 2.0;
        CGRect cropedRect = CGRectMake(centerFrame - 1.5, 0, 3.0, imgToAnalogGraph.size.height);
        UIImage* cropImge = [imgToAnalogGraph crop:cropedRect];
        
        // 자른 이미지를 보여준다
        [self.imgSpectrumOfCenter setImage:cropImge];
        self.imgSpectrumOfCenter.image = [cropImge imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imgSpectrumOfCenter.tintColor = [UIColor whiteColor];
        
        if (self.imgSpectrumOfCenter.hidden == YES) {
            //NSLog(@"왜 비지블이 꺼져있지..?");
            self.imgSpectrumOfCenter.hidden = NO;
        }
        if ([self isLandscapeMode] == NO) {
            if (self.viwMenu.hidden == NO) {
                self.viwMenuBottomSpectrum.hidden = NO;
            }
        }
    });
}

/*---------------------------------
 VISUALIZATION FOR AUDIO ONLY FILE
 ----------------------------------*/
- (void)visualizationProcess:(float)curSec
{
    if (self.viwAudioVisualBase.hidden)
        return;
    
    float width = self.imgSpectrumOfCenter.frame.size.width * 2;
    CGRect frame = CGRectMake(width * -1,
                              0,
                              self.imgSpectrumOfCenter.frame.size.height,
                              width * 2.0);
    float value41 = [self.imgSpectrumOfCenter.image amountOfColor:frame] * 0.5;
    float value42 = arc4random_uniform(100) * 0.01;
    
    if (value41 > 1)
        value41 = 1;
    if (value41 == 0)
        value42 = 0;
    
    //NSLog(@"비쥬얼값:%.2f %.2f", value41, value42);
    
    [self.audioVisualizer animateAudioVisualizerWithChannel0Level:value41
                                                 andChannel1Level:value42];
}

/*----------------------------------------------------
 EVENT ON PLAYING OF MOVIE PLAYER ABOUT 4TIMES / 1SEC
 ----------------------------------------------------*/
- (void)updateInPlaying {
    
    // CALC PROGRESS TIME INFO
    double totSec = CMTimeGetSeconds(_playerItem.duration);
    double curSec = CMTimeGetSeconds(_player.currentTime);
    double divide = (curSec / totSec);
    float percentage = divide * 100;
    double seconds = round(curSec);
    
    // SET SELF PROPERTY OF MOVIE FILE LENGTH
    self.movieCurreSec = curSec;
    
    // UPDATE PROGRESS SLIDER
    self.sldProgress.value = divide;
    
    // DELEGATE FIRE
    [self.delegate onPlaying:self.movieFilePath
                    duration:totSec
                  currentSec:curSec
                  percentage:percentage];
    
    // UPDATE CURRENT TIME
    self.lblCurrentTime.text = [self timeFormatted:seconds];
    if (self.lblTotalTime.text.length !=
        self.lblCurrentTime.text.length)
        self.lblCurrentTime.text = [NSString stringWithFormat:@"0:%@",
                                    self.lblCurrentTime.text];
    
    // SET SUBTITLE
    if ([SubTitle shared].isLoaded) {
        NSString* currSec2Digit = [NSString stringWithFormat:@"%.2f", curSec];
        SubTitleCaption* caption = [[SubTitle shared] captionAtSec:currSec2Digit.floatValue];
        if (caption != nil)
        {
            if (caption.secToEnd == currSec2Digit.floatValue) {
                // END SUBTITLE AFTER 1 SEC LATER
                [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(onTickAfterSubTitle:)
                                               userInfo:currSec2Digit
                                                repeats:NO];
            } else {
                // START SUBTITLE
                self.viwSubtitle.hidden = NO;
                self.lblSubtitle.text = caption.text;
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.viwSubtitle.hidden = YES;
            });
        }
    }
    
    // SET REPEAT COUNT ON LABEL
    [self setRepeatCountOnLabel];
    
    // PRENT CURRENT SENTENCE GRAPH ON SCREEN
    [self displaySentenceGraphOnScreen:curSec];
    
    // VISUALIZATION FOR AUDIO ONLY FILE
    [self visualizationProcess:curSec];
    
    // 문장 끝에 다다랐다면 다음문장으로 넘길지 반복할지 판단
    // 스크러빙 중에는 문장의 끝부분 찾기를 할 필요 없다
    // 문장이 하나도 없다면 마찬가지로 끝부분 찾기 필요 없다
    if ((self.isScrubing == NO) &&
        ([[SentGroup shared] countOfallSen] != 0) &&
        (self.secToStopForDetermine < curSec))
    {
        // 검사시작
        // [self pause];
        
        // GET LIMIT REPEAT COUNT
        //int repeatCntFromConfig = [[Config shared] getRepeatCount];
        
        // 반복 안하기 버튼 눌린상태라면..?
        if (self.isStopToRepeat || self.isOneTimePassNoRepeat) {
            
            if (self.isOneTimePassNoRepeat)
            {
                self.repeatCount = 0;
                self.isOneTimePassNoRepeat = NO;
            }
                
            if ([self.currentSent isLastSen])
            {
                [self nextActionOnEndPlaying];
                return;
            }
            
            SentInfo* nextSen = [[SentGroup shared] getBySecond:self.currentSent.endSec + 1
                                                  nextIfInBlank:YES];
            self.secToStopForDetermine = nextSen.endSec;
            self.currentSent = nextSen;
            //[self play];
            
            // 우측으로 추가 문장 찾아주자 - 쓰레드 사용
            [[SentGroup shared] createSentGroupInThread:self.movieFilePath
                                              audioPath:self.audioFilePath
                                              audioDura:self.movieTotalSec
                                              direction:DIRECTION_RIGHT
                                                currSec:curSec];
            return;
        }
        
        // 검사시작
        [self pause];
        
        // GET LIMIT REPEAT COUNT
        int repeatCntFromConfig = [[Config shared] getRepeatCount];
        
        // 무한반복이라면..?
        if (repeatCntFromConfig == 0) {
            //NSLog(@"무한반복이므로 같은문장 반복재생");
            [self playSameSentence];
            return;
        }
        
        // 이미 충분히 반복이 이루어졌다면..?
        if (self.repeatCount >= repeatCntFromConfig -1) {
            
            self.repeatCount = 0;
            
            if ([self.currentSent isLastSen]) {
                [self nextActionOnEndPlaying];
                return;
            }
            SentInfo* nextSen = [[SentGroup shared] getBySecond:self.currentSent.endSec + 1
                                                  nextIfInBlank:YES];
            self.secToStopForDetermine = nextSen.endSec;
            self.currentSent = nextSen;
            
            //NSLog(@"다음문장으로 통과 #1");
            //NSLog(@"다음찾는 시간: %.2f", self.currentSent.endSec);
            [self play];
            
            // 우측으로 추가 문장 찾아주자 - 쓰레드 사용
            [[SentGroup shared] createSentGroupInThread:self.movieFilePath
                                              audioPath:self.audioFilePath
                                                     audioDura:self.movieTotalSec
                                                     direction:DIRECTION_RIGHT
                                                       currSec:curSec];
            return;
        }
        
        // 아직 반복이 충분하지 않다면..?
        if (self.repeatCount < (repeatCntFromConfig -1))
        {
            //NSLog(@"같은문장 반복재생");
            self.repeatCount++;
            [self playSameSentence];
            return;
        } else {
            //NSLog(@"문장반복 검사없음 #1");
        }
    }
    
    // 파일끝이라면?
    if (totSec == curSec) {
        //NSLog(@"파일끝 다음 플레이 액션");
        [self nextActionOnEndPlaying];
    }
}

/*-------------------------------------
 ON AFTER MEETING END TIME OF SUBTITLE
 --------------------------------------*/
- (void)onTickAfterSubTitle:(NSTimer*)theTimer
{
    NSString* sec = theTimer.userInfo;
    float currSec = sec.floatValue + 1;
    //NSLog(@"자막끝 타이머: %f", currSec);
    SubTitleCaption* caption = [[SubTitle shared] captionAtSec:currSec];
    if (!caption) {
        // HIDE SUBTITLE
        self.viwSubtitle.hidden = YES;
        self.lblSubtitle.text = @"";
    }
}

- (void)seekAt:(float)pSec playOnComplete:(BOOL)pPlayOnComplete
{
    [self pause];
    
    // SEEK THE POSITION TO PLAY
    if (pSec > 0.25) pSec = pSec - 0.25;
    CMTimeScale timeScale = _player.currentItem.asset.duration.timescale;
    CMTime timeToSeek = CMTimeMakeWithSeconds(pSec, timeScale);
    //NSLog(@"현재시간(%.2f) 찾아서 재생시킬 시작시간(%.2f)", self.movieCurreSec, pSec);
    
    [_player seekToTime:timeToSeek toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pPlayOnComplete)
        {
            [self play];
        } else {
            [self displaySentenceGraphOnScreen:pSec];
        }
    });
}

/*---------------------------------------
 SLIDER TOUCH TO CHANGE PLAYER POSITION
 ---------------------------------------*/
- (IBAction)sldStartScrub:(id)sender
{
    [self pause];
    self.isScrubing = YES;
}

/*---------------------------------------
 MOVING SLIDER TO CHANGE PLAYER POSITION
 ---------------------------------------*/
- (IBAction)sldScrubbing:(UISlider*)sender
{
    [self pause];
    
    //GETS THE VIDEO DURATION
    CMTime videoLength = _playerItem.duration;
    double time = CMTimeGetSeconds(_player.currentTime);
    double seconds = round(time);
    
    //TRANSFER THE CMTIME DURATION INTO SECONDS
    float videoLengthInSeconds = videoLength.value / videoLength.timescale;
    
    // SEEK CURRENT SCINE
    CGFloat nearest = videoLengthInSeconds * sender.value;
    CMTime timeToSeek = CMTimeMakeWithSeconds(nearest, videoLength.timescale);
    
    //NSLog(@"이동중 위치값: %f", nearest);
    [_player seekToTime:timeToSeek
        toleranceBefore:kCMTimeZero
         toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             // UPDATE CURRENT TIME
             self.lblCurrentTime.text = [self timeFormatted:seconds];
             if (self.lblTotalTime.text.length !=
                 self.lblCurrentTime.text.length)
                 self.lblCurrentTime.text = [NSString stringWithFormat:@"0:%@",
                                             self.lblCurrentTime.text];
         });
     }];
}

/*----------------------------------------
 END OF DRAG FOR CHANGING PLAYER POSITION
 ----------------------------------------*/
- (IBAction)sldEndScrub:(id)sender
{
    // 기존 문장을 모두 지우고, 현재시간을 기준으로 새롭게 찾아라
    double curSec = CMTimeGetSeconds(_player.currentTime);
    self.movieCurreSec = curSec;
    //NSLog(@"스크러빙 완료: %.2f", curSec);
    
    self.repeatCount = 0;
    
    /*------------------------------------
     이미 만들어진 문장들이 존재한다면 또 만들지 말자
     -------------------------------------*/
    float staSecToFind = curSec - 40;
    if (staSecToFind < 0)
        staSecToFind = 0;
    
    float endSecToFind = curSec + 40;
    if (endSecToFind > self.movieTotalSec)
        endSecToFind = self.movieTotalSec;
    
    SentInfo* senSta = [[SentGroup shared] getBySecond:staSecToFind];
    SentInfo* senEnd = [[SentGroup shared] getBySecond:endSecToFind];
    
    //NSLog(@"스크러빙 완료 - 문장찾기시작");
    if (senSta == nil && senEnd == nil) {
        [[SentGroup shared] createSentGroup:self.movieFilePath
                                  audioPath:self.audioFilePath
                                audioDura:self.movieTotalSec
                                  direction:DIRECTION_NEW
                                    currSec:curSec];
    }
    if (senSta == nil && senEnd != nil) {
        [[SentGroup shared] createSentGroup:self.movieFilePath
                                  audioPath:self.audioFilePath
                                audioDura:self.movieTotalSec
                                  direction:DIRECTION_LEFT
                                    currSec:curSec];
    }
    if (senSta != nil && senEnd == nil) {
        [[SentGroup shared] createSentGroup:self.movieFilePath
                                  audioPath:self.audioFilePath
                                audioDura:self.movieTotalSec
                                  direction:DIRECTION_RIGHT
                                    currSec:curSec];
    }
    
    self.currentSent = [[SentGroup shared] getBySecond:curSec nextIfInBlank:YES];
    self.secToStopForDetermine = self.currentSent.endSec;
    [self seekAt:curSec playOnComplete:YES];
    
    self.isScrubing = NO;
}

/*------------------------------------
 BUTTON TOUCH OF STARTING TO PLAY
 ------------------------------------*/
- (IBAction)tchPlay:(id)sender
{
    if ([self isInPlaying])
        [self pause];
    else [self resume];
}

- (void)play
{
    /*------------
     버튼 이미지 변경
     -------------*/
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.btnPlay setImage:[UIImage imageNamed:@"icn_player_pause_40x40"]
                      forState:UIControlStateNormal];
        [[TblContFileHelper shared].needHelp changePlayButtonImage:YES];
    });
    
    /*-------------------
     페어런트 뷰에 진행율 표시
     --------------------*/
    TblContFile* parent = (TblContFile*)self.vwcParent;
    parent.viwForPlaying.hidden = NO;
    
    /*------------------
     설정된 속도에 맞게 재생
     -------------------*/
    [_player play];
    _player.rate = [Config shared].playSpeed;
}

- (void)pause {
    if (_player == nil)
        return;
    
    [_player pause];
    
    // 최신 플레이 정보 업데이트 및 히스토리 정보 저장
    self.movieCurreSec = CMTimeGetSeconds(_player.currentTime);
    [self saveCurrPlaying];
    [[Config shared] insertIntoHistory:self.movieFilePath
                               currSec:self.movieCurreSec];
    [[Config shared] writeToFile];
    // NSLog(@"플레이 정보 저장됨: %@", self.movieFilePath);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.btnPlay setImage:[UIImage imageNamed:@"icn_player_play_40x40"]
                      forState:UIControlStateNormal];
        [[TblContFileHelper shared].needHelp changePlayButtonImage:NO];
    });
}

- (void)resume {
    [self play];
}

- (void)playOpause {
    [self tchPlay:nil];
}

/*--------------------
 TOUCH ON PREV BUTTON
 ---------------------*/
- (IBAction)tchNextSen:(id)sender {
    [self playNextSentence];
}

/*--------------------
 TOUCH ON NEXT BUTTON
 ---------------------*/
- (IBAction)tchPrevSen:(id)sender {
    [self playPrevSentence];
}

/*-------------------------------------------
 TOUCH FOR PLAYING CURRENT SENTENCE ONE MORE
 --------------------------------------------*/
- (IBAction)tchSameSen:(id)sender
{
    self.repeatCount = 0;
    [self playSameSentence];
}

/*--------------------------------
 TOUCH FOR REPEAT ALLOWING OR NOT
 ---------------------------------*/
- (IBAction)tchRepeatAllow:(id)sender
{
    self.isStopToRepeat = !self.isStopToRepeat;
    [self turnOffRepeat:self.isStopToRepeat];
}

- (void)turnOffRepeat:(BOOL)pOffRepeat {
    
    self.isStopToRepeat = pOffRepeat;
    //NSString* imageName = @"icn_player_replay_40x40";
    if (self.isStopToRepeat) {
        //imageName = @"icn_player_goahead_40x40";
        //[self.btnAllowRepeat setTintColor:[UIColor colorWithRed:0.263 green:0.263 blue:0.263 alpha:1.00]];
    } else {
        //[self.btnAllowRepeat setTintColor:self.btnPlay.tintColor];
    }
    
    //[self.btnAllowRepeat setImage:[UIImage imageNamed:imageName]
    //                     forState:UIControlStateNormal];
}

- (IBAction)tchMakeCountTo1:(id)sender
{
    self.isOneTimePassNoRepeat = YES;
}

/*-----------------
 TOUCH VOLUME MUTE
 ------------------*/
- (IBAction)tchMute:(id)sender
{
    BOOL isOn = _player.muted;
    [self turnOffvolume:!isOn];
    [Config shared].isVolumeMuted = !isOn;
}

- (void)turnOffvolume:(BOOL)pOffVolume {
    
    [_player setMuted:pOffVolume];
    
    NSString* imageName = @"icn_player_voloff_40x40";
    if (!pOffVolume)
        imageName = @"icn_player_volon_40x40";
    
    [self.btnMute setImage:[UIImage imageNamed:imageName]
                  forState:UIControlStateNormal];
}

/*-----------------------------
 TOUCH FOR SHOWING CONFIG VIEW
 ------------------------------*/
- (IBAction)tchRecorder:(id)sender
{
    if (self.viwConfig.hidden == NO)
        [self tchConfig:nil];
    
    self.viwRecorder.hidden = !self.viwRecorder.hidden;
    if (self.viwRecorder.hidden == NO)
        [[VCVoiceRecorder shared] initRecorder];
    
    // IF LANDSCAPE MODE, DO NOT RESIZE MOVIE PLAYER
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        return;
    
    [self orientationChanged:nil];
    // IS IPAD OR IPHONE
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [VCVoiceRecorder shared].viwBack.backgroundColor = [UIColor clearColor];
    } else {
        [VCVoiceRecorder shared].viwBack.backgroundColor = [VCVoiceRecorder shared].viwFront.backgroundColor;
    }
}

/*-----------------------------
 TOUCH FOR SHOWING CONFIG VIEW
 ------------------------------*/
- (IBAction)tchConfig:(id)sender
{
    if (self.viwRecorder.hidden == NO)
        [self tchRecorder:nil];
    
    // CHANGE CONFIG VIEW VISIBLE
    self.viwConfig.hidden = !self.viwConfig.hidden;
    
    // IF LANDSCAPE MODE, DO NOT RESIZE MOVIE PLAYER
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        return;
    
    // RELOAD CONFIG DATA
    [[VCMovieConfig shared] loadConfigData];
    
    [self orientationChanged:nil];
    
    // IS IPAD OR IPHONE
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [VCMovieConfig shared].viwBack.backgroundColor = [UIColor clearColor];
    } else {
        [VCMovieConfig shared].viwBack.backgroundColor = [VCMovieConfig shared].viwFront.backgroundColor;
    }
}

/*----------------------
 MESSAGE FOR FILE ERROR
 -----------------------*/
- (void)msgForErrFile {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertController
         showAlertInViewController:self
         withTitle:[[Config shared] trans:@"알림"]
         message:[[Config shared] trans:@"정상 무비파일이 아닙니다"]
         cancelButtonTitle:nil
         destructiveButtonTitle:[[Config shared] trans:@"확인"]
         otherButtonTitles:nil
         tapBlock:^(UIAlertController *controller,
                    UIAlertAction *action, NSInteger buttonIndex) {
         }];
    });
}

/*------------------------------
 MESSAGE FOR NOT FOUND SENTENCE
 -------------------------------*/
- (void)msgForNotFoundSentence {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertController
         showAlertInViewController:self
         withTitle:[[Config shared] trans:@"알림"]
         message:[[Config shared] trans:@"문장을 발견하지 못했습니다"]
         cancelButtonTitle:nil
         destructiveButtonTitle:[[Config shared] trans:@"확인"]
         otherButtonTitles:nil
         tapBlock:^(UIAlertController *controller,
                    UIAlertAction *action, NSInteger buttonIndex) {
         }];
    });
}

/*--------------------------------
 METHOD FOR PLAYING NEXT SENTENCE
 ---------------------------------*/
- (void)playNextSentence
{
    /*-------------------------
     발견된 문장이 한개도 없을 수 있다
     --------------------------*/
    if ([SentGroup shared].dictOfSent.count == 0) {
        [self msgForNotFoundSentence];
        return;
    }
    
    /*------------------------------
     문장찾기가 작업중에 있다면 작동하지 말자
     -------------------------------*/
    if ([SentGroup shared].isProcessingNow)
        return;
    
    // 현재 문장을 찾아보자
    SentInfo* currSen = [[SentGroup shared] getBySecond:self.movieCurreSec nextIfInBlank:YES];
    if (currSen == nil) {
        //NSLog(@"-");
        //NSLog(@"마지막 문장이 지난 공백상태에서 다음문장 찾기...?");
        [self playSameSentence];
        return;
    }
    
    // 다음 문장 찾기
    SentInfo* nextSen = [[SentGroup shared] getByIndex:currSen.index + 1];
    if (nextSen == nil) {
        /*NSLog(@"-");
        NSLog(@"다음 문장 없음");
        if ([[SentGroup shared] checkIndexOfAllSen])
            NSLog(@"문장인덱스 검사결과 정상");
        NSLog(@"현재문장 인덱스: %li", currSen.index);
        NSLog(@"전체문장 시작인: %li", [[SentGroup shared] getFirstSen].index);
        NSLog(@"전체문장 종료인: %li", [[SentGroup shared] getLastSen].index);
         */
        return;
    }
    
    //NSLog(@"-");
    //NSLog(@"다음문장 찾기 현재시간(%@) 다음문장 찾은 후 시작시간: %@",
    //      [self timeFormatted:self.movieCurreSec],
    //      [self timeFormatted:nextSen.staSec]);
    
    // 플레이
    self.repeatCount = 0;
    self.currentSent = nextSen;
    self.secToStopForDetermine = nextSen.endSec;
    [self seekAt:nextSen.staSec playOnComplete:YES];
    
    // 추가적으로 문장을 더 찾아놓는다 (쓰레드)
    [[SentGroup shared] createSentGroupInThread:self.movieFilePath
                                      audioPath:self.audioFilePath
                                      audioDura:self.movieTotalSec
                                      direction:DIRECTION_RIGHT
                                        currSec:self.movieCurreSec];
}

/*--------------------------------
 METHOD FOR PLAYING PREV SENTENCE
 ---------------------------------*/
- (void)playPrevSentence
{
    /*-------------------------
     발견된 문장이 한개도 없을 수 있다
     --------------------------*/
    if ([SentGroup shared].dictOfSent.count == 0) {
        [self msgForNotFoundSentence];
        return;
    }
    
    /*------------------------------
     문장찾기가 작업중에 있다면 작동하지 말자
     -------------------------------*/
    if ([SentGroup shared].isProcessingNow)
        return;
    
    // 현재 문장을 찾아보자
    SentInfo* currSen = [[SentGroup shared] getBySecond:self.movieCurreSec prevIfInBlank:YES];
    if (currSen == nil) {
        //NSLog(@"-");
        //NSLog(@"처음 문장보다 앞선 공백상태에서 앞문장 찾기...?");
        [self playSameSentence];
        return;
    }
    
    // 앞 문장 찾기
    SentInfo* prevSen = [[SentGroup shared] getByIndex:currSen.index - 1];
    if (prevSen == nil) {
        //NSLog(@"-");
        //NSLog(@"첫번째 문장에서 이전문장 찾기...?");
        [self playSameSentence];
        return;
    }
    
    // 플레이
    self.repeatCount = 0;
    self.currentSent = prevSen;
    self.secToStopForDetermine = prevSen.endSec;
    [self seekAt:prevSen.staSec playOnComplete:YES];
    
    // 추가적으로 앞 문장을 더 찾아놓는다 (쓰레드)
    [[SentGroup shared] createSentGroupInThread:self.movieFilePath
                                      audioPath:self.audioFilePath
                                      audioDura:self.movieTotalSec
                                      direction:DIRECTION_LEFT
                                        currSec:self.movieCurreSec];
}

/*--------------------------------
 METHOD FOR PLAYING SAME SENTENCE
 ---------------------------------*/
- (void)playSameSentence
{
    [self seekAt:self.currentSent.staSec playOnComplete:NO];
 
    /*------------------
     딜레이 타임 수행 후 재생
     -------------------*/
    float delaySec = [[Config shared] getWaitingSec];
    [self performSelector:@selector(play) withObject:nil afterDelay:delaySec];
}

/*------------------------------------
 문장제작이 완료 된 후 병합된 이미지들을 저장한다
 -------------------------------------*/
- (void)onCreateSenGroupComplete:(UIImage*)pTotImageAnalog
                  totImageDigita:(UIImage*)pTotImageDigita
                  totImageSenten:(UIImage*)pTotImageSenten
           staSecOfTotSoundGraph:(float)pStaSecOfTotSoundGraph
           endSecOfTotSoundGraph:(float)pEndSecOfTotSoundGraph
                         currSec:(float)pCurrSec
{
    //NSLog(@"-");
    self.frmAmtPer1Sec = [[SentGroup shared] getFrmAmtPer1Sec];
    //NSLog(@"분석완료 초당프레임(%.5f)", self.frmAmtPer1Sec);
    
    self.imgTotGraphAnalog = [UIImage imageWithData:UIImagePNGRepresentation(pTotImageAnalog)];
    self.imgTotGraphDigita = [UIImage imageWithData:UIImagePNGRepresentation(pTotImageDigita)];
    self.imgTotGraphSenten = [UIImage imageWithData:UIImagePNGRepresentation(pTotImageSenten)];
    self.staSecOfTotSoundGraph = pStaSecOfTotSoundGraph;
    self.endSecOfTotSoundGraph = pEndSecOfTotSoundGraph;
    
    //[[SentGroup shared] printSummary:0];
}

/*---------------------------------------
 현재시간을 기준으로 양옆 40초 분량의 이미지를 반환
 ----------------------------------------*/
- (void)getSentImageIn80Sec:(float)pTotDuration
                    currSec:(float)pCurrSec
                  analogImg:(UIImage**)pAnalogImg
                  digitaImg:(UIImage**)pDigitaImg
                  sentenImg:(UIImage**)pSentenImg {
    
    // 전체 문장의 시작시간과 전체 문장의 이미지가 매칭된다.
    // 따라서 현재시간에서 전체문장의 시작시간의 거리만큼
    // 프레임의 크기를 구하고, 그 프레임을 기준으로 양쪽으로 40초씩을 잘라낸다.
    self.frmAmtPer1Sec = (self.imgTotGraphDigita.size.width) /
                         (self.endSecOfTotSoundGraph - self.staSecOfTotSoundGraph);
    
    // self.frmAmtPer1Sec = round(self.frmAmtPer1Sec * 100) * 0.01;
    
    float distanceSeco = pCurrSec - self.staSecOfTotSoundGraph;
    float currentFrame = distanceSeco * self.frmAmtPer1Sec;
    
    // 40초에 해당하는 프레임 수
    float frmAmt40Seco = 40 * self.frmAmtPer1Sec;
    
    float staFrameToCut = (currentFrame - frmAmt40Seco);
    float endFrameToCut = (currentFrame + frmAmt40Seco);
    
    CGRect rectToCrop = CGRectMake(staFrameToCut, 0,
                                  (endFrameToCut - staFrameToCut),
                                   self.imgTotGraphDigita.size.height);
    
    //*pAnalogImg = [self.imgTotGraphAnalog crop:rectToCrop];
    *pDigitaImg = [self.imgTotGraphDigita crop:rectToCrop];
    *pSentenImg = [self.imgTotGraphSenten crop:rectToCrop];
    *pAnalogImg = [self.imgTotGraphAnalog crop:rectToCrop];
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

@end
