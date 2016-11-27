//
//  TblCellRecordedCommon.h
//  repeater
//
//  Created by admin on 2016. 9. 7..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FileInfo.h"

@interface TblCellRecordedCommon : UITableViewCell <AVAudioSessionDelegate, AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
}

- (UIImageView*)imageFileIcon;
- (UIImageView*)imageSelectIcon;
- (UILabel*)lableFileName;
- (UILabel*)lableFileDetail;
- (UILabel*)lableSubCount;
- (UILabel*)lableLenOfMedia;
- (UIButton*)btnPlayPause;

/*----------------------
 DATA SET WITH FILEINFO
 -----------------------*/
- (void)dataFill:(FileInfo*)pFifo;

/*------------------------------------
 DISPLAY ITSELF SELECTED OR UNSELECTED
 -------------------------------------*/
- (void)changeSelectedState:(BOOL)pOnOff;

- (void)tchBtnPlayPause:(id)sender;

@property (nonatomic, retain) FileInfo* fileInfo;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, retain) NSDate* timeToStart;

@end
