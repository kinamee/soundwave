//
//  TblCellRecordedCommon.m
//  repeater
//
//  Created by admin on 2016. 9. 7..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblCellRecordedCommon.h"
#import "KSPath.h"
#import "Config.h"
#import "UIImage+Category.h"
#import "TblContFileHelper.h"

@implementation TblCellRecordedCommon

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:
     [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.00]];
    [self setSelectedBackgroundView:selectedBackgroundView];
}

- (UIImageView*)imageSelectIcon {
    return (UIImageView*)[self viewWithTag:201];
}

- (UIImageView*)imageFileIcon {
    return (UIImageView*)[self viewWithTag:202];
}

- (UILabel*)lableFileName {
    return (UILabel*)[self viewWithTag:101];
}

- (UILabel*)lableFileDetail {
    return (UILabel*)[self viewWithTag:102];
}

- (UILabel*)lableFileCreated {
    return (UILabel*)[self viewWithTag:103];
}

- (UILabel*)lableSubCount {
    return (UILabel*)[self viewWithTag:104];
}

- (UILabel*)lableLenOfMedia {
    return (UILabel*)[self viewWithTag:204];
}

- (UIButton*)btnPlayPause {
    UIButton* btn = (UIButton*)[self viewWithTag:203];
    [btn addTarget:self action:@selector(tchBtnPlayPause:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)tchBtnPlayPause:(id)sender {
    
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying) {
        // LETS PLAY
        [self playBack];
        
    } else {
        // LETS STOP
        [self stopPlaying];        
    }
}

- (void)stopPlaying
{
    [player pause];
    // CHANGE BUTTON IMAGE
    UIButton* btn = [self btnPlayPause];
    [btn setImage:[UIImage imageNamed:@"icn_player_play"] forState:UIControlStateNormal];
    
    self.isPlaying = NO;
}

- (void)playBack
{
    self.isPlaying = YES;
    
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory :AVAudioSessionCategoryPlayback error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    
    //NSLog(@"%@", self.fileInfo.fileNameFull);
    
    NSURL* url = [NSURL fileURLWithPath:self.fileInfo.fileNameFull];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error)
        NSLog(@"오류발생:%@",error);
    
    player.delegate = self;
    [player setNumberOfLoops:0];
    player.volume = 1;
    [player prepareToPlay];
    [player play];
    
    self.timeToStart = [NSDate date];
    [self onTimerOfRecOrPlay:nil];
    
    UIButton* btn = [self btnPlayPause];
    [btn setImage:[UIImage imageNamed:@"icn_player_pause"] forState:UIControlStateNormal];
}

- (void)onTimerOfRecOrPlay:(id)sender {
    
    NSDate *endingDate = [NSDate date];
    NSTimeInterval timeInterval = 0.0;
    timeInterval = [endingDate timeIntervalSinceDate:self.timeToStart];
    
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    //NSInteger hours = (ti / 3600);
    [self lableLenOfMedia].text = [NSString stringWithFormat:@"%02ld:%02ld",
                            (long)minutes, (long)seconds];
    
    if (self.isPlaying)
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                       selector:@selector(onTimerOfRecOrPlay:)
                                       userInfo:nil
                                        repeats:NO];
}

/*-----------------------
 GET WEEKDAY FROM NSDATE
 ------------------------*/
- (NSString*)weekDayFrom:(NSDate*)pDate
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:pDate];
    //NSLog(@"%@ %li",pDate, [comp weekday]);
    
    if ([comp weekday] == 1)
        return @"Sun";//[[ConfigFile shared] translate:@"일"];
    if ([comp weekday] == 2)
        return @"Mon";//[[ConfigFile shared] translate:@"월"];
    if ([comp weekday] == 3)
        return @"Tue";//[[ConfigFile shared] translate:@"화"];
    if ([comp weekday] == 4)
        return @"Wed";//[[ConfigFile shared] translate:@"수"];
    if ([comp weekday] == 5)
        return @"Thr";//[[ConfigFile shared] translate:@"목"];
    if ([comp weekday] == 6)
        return @"Fri";//[[ConfigFile shared] translate:@"금"];
    if ([comp weekday] == 7)
        return @"Sat";//[[ConfigFile shared] translate:@"토"];
    return @"";
}

/*----------------------
 DATA SET WITH FILEINFO
 -----------------------*/
- (void)dataFill:(FileInfo*)pFifo
{
    self.fileInfo = pFifo;
    
    // SET FILE NAME
    UILabel* lblFileName = [self lableFileName];
    lblFileName.text = pFifo.fileNameOnly.stringByDeletingPathExtension;
    
    // 1. GET WEEKDAY
    NSDateFormatter *dateF = [[NSDateFormatter alloc] init];
    [dateF setDateFormat:@"dd-MM-yyyy"];
    NSDate* date = [dateF dateFromString: pFifo.dateCreated];
    NSString* weekDay = [self weekDayFrom:date];
    
    // 2. SET THE DAY OF CREATED
    UILabel* lblFileCreated = [self lableFileCreated];
    lblFileCreated.text = [NSString stringWithFormat:@"Created %@ %@", pFifo.dateCreated, weekDay];
    //Created 07/08/2016 [FRI]
    //7.3Mb MP4 Type Length [00:03:42]
    
    float sec = [[KSPath shared] duration:self.fileInfo.fileNameFull];
    
    // SET DETAIL INFO FOR ".MP4" TYPE
    UILabel* lblDetail = [self lableFileDetail];
    lblDetail.text = [NSString stringWithFormat:@"%@ %@ Type Length [%@]",
                      pFifo.fileSize,
                      [pFifo.fileExtention uppercaseString],
                      [[Config shared] timeFormatted:sec]];
    
    // SET LENGTH OF SOUND
    UILabel* lblLen = [self lableLenOfMedia];
    lblLen.text = [[Config shared] timeFormatted:sec];
    
    // SET BUTTON
    UIButton* btn = [self btnPlayPause];
    if (self.isPlaying == NO)
        [btn setImage:[UIImage imageNamed:@"icn_player_play"] forState:UIControlStateNormal];
    else
        [btn setImage:[UIImage imageNamed:@"icn_pause_play"] forState:UIControlStateNormal];
    
    // SET THUMB
    UIImageView* viwImg = [self imageFileIcon];
    
    //NSString* imgPath = [[KSPath shared] tempDirFrom:pFifo.fileNameFull makeOption:YES];
    //imgPath = [imgPath stringByAppendingFormat:@"/%@.png", pFifo.fileNameOnly];

    viwImg.image = [viwImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    viwImg.tintColor = [UIColor whiteColor];
    
    // SET ACCESSORY AS NONE
    [self setAccessoryType:UITableViewCellAccessoryNone];
}

/*------------------------------------
 DISPLAY ITSELF SELECTED OR UNSELECTED
 -------------------------------------*/
- (void)changeSelectedState:(BOOL)pOnOff
{
    UIImageView* imageSelect = [self imageSelectIcon];
    if (imageSelect == nil)
        return;
    
    if (pOnOff) {
        [imageSelect setImage:[UIImage imageNamed:@"icn_selected"]];
        //imageSelect.image = [imageSelect.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        //imageSelect.tintColor = [TblContFileHelper shared].needHelp.viwForEdit.backgroundColor;
    }
    else [imageSelect setImage:[UIImage imageNamed:@"icn_unselected"]];
    
    if (self.isPlaying)
        [self stopPlaying];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //NSLog (@"audioPlayerDidFinishPlaying:successfully:");
    self.isPlaying = NO;
    // CHANGE BUTTON IMAGE
    UIButton* btn = [self btnPlayPause];
    [btn setImage:[UIImage imageNamed:@"icn_player_play"] forState:UIControlStateNormal];
}

@end
