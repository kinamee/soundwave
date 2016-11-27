//
//  VCMovieConfig.h
//  repeater
//
//  Created by admin on 2016. 2. 2..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCMovieConfig : UIViewController

+ (VCMovieConfig*)shared;
- (void)loadConfigData;

@property (weak, nonatomic) IBOutlet UIView *viwBack;
@property (weak, nonatomic) IBOutlet UIView *viwFront;
- (IBAction)chgRepeatCount:(id)sender;
- (IBAction)chgPlaySpeed:(id)sender;
- (IBAction)chgMinimumSenLen:(id)sender;
- (IBAction)chgCaptionSupport:(id)sender;
- (IBAction)chgEndOfPlay:(id)sender;

- (void)playSpeedBtnEnble:(float)pPlaySpeed;

@property (weak, nonatomic) IBOutlet UIButton *btnRepeatCntDown;
@property (weak, nonatomic) IBOutlet UIButton *btnRepeatCntUp;

@property (weak, nonatomic) IBOutlet UIButton *btnSpeedDown;
@property (weak, nonatomic) IBOutlet UIButton *btnSpeedUp;

@property (weak, nonatomic) IBOutlet UIButton *btnSenLenDown;
@property (weak, nonatomic) IBOutlet UIButton *btnSenLenUp;

@property (weak, nonatomic) IBOutlet UIButton *btnCaptionSupport;

@property (weak, nonatomic) IBOutlet UIButton *btnPlayNext;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayRepeat;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayRandom;

@property (weak, nonatomic) IBOutlet UILabel *lblRepeatOne;

@property (weak, nonatomic) IBOutlet UILabel *lblRepeatCount;
@property (weak, nonatomic) IBOutlet UILabel *lblRepeatCountValue;

@property (weak, nonatomic) IBOutlet UILabel *lblPlaySpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaySpeedValue;

@property (weak, nonatomic) IBOutlet UILabel *lblMinimumSenLen;
@property (weak, nonatomic) IBOutlet UILabel *lblMinimumSenLenValue;

@property (weak, nonatomic) IBOutlet UILabel *lblSubCaptionSupport;
@property (weak, nonatomic) IBOutlet UILabel *lblSubCaptionValue;

@property (weak, nonatomic) IBOutlet UILabel *lblEndOfPlay;

@end
