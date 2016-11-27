//
//  TblCellAlbum.m
//  repeater
//
//  Created by admin on 2016. 9. 12..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblCellAlbum.h"
#import "KSPath.h"
#import "Config.h"
#import "UIImage+Category.h"

@implementation TblCellAlbum

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

- (UIView*)viewExtBack  {
    return (UIView*)[self viewWithTag:203];
}

- (UILabel*)lableExt  {
    return (UILabel*)[self viewWithTag:204];
}

- (UIButton*)btnImgSpectrum {
    return (UIButton*)[self viewWithTag:205];
}

- (void)tchBtnPlayPause:(id)sender {

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
    lblFileName.text = pFifo.fileNameOnly;
    
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
    
    // SET ACCESSORY AS NONE
    [self setAccessoryType:UITableViewCellAccessoryNone];
    
    // SET DETAIL INFO
    UILabel* lblDetail = [self lableFileDetail];
    NSString* extention = pFifo.fileExtention;
    
    if ([[Config shared] isSupportedFile:extention])
    {
        // SET FILE NAME
        lblFileName.text = [pFifo.fileNameOnly substringToIndex:pFifo.fileNameOnly.length - 4];
        
        // SET DETAIL INFO FOR ".MP4" TYPE
        lblDetail.text = [NSString stringWithFormat:@"%@ %@ Type Length [%@]",
                          pFifo.fileSize,
                          [pFifo.fileExtention uppercaseString],
                          pFifo.durationTimeFormatted];
        
        if ([extention.uppercaseString isEqualToString:@"MP3"] == YES ||
            [extention.uppercaseString isEqualToString:@"M4A"] == YES)
        {
            [self lableExt].hidden = NO;
            [self lableExt].text = extention.uppercaseString;
            
            [self viewExtBack].hidden = NO;
            [[self imageFileIcon] setImage:nil];
            
            [self btnImgSpectrum].hidden = NO;
        }
        
        if ([extention.uppercaseString isEqualToString:@"MOV"] == YES ||
            [extention.uppercaseString isEqualToString:@"MP4"] == YES)
        {
            // SET THUMB IMAGE 45x30
            NSString* pathToThumb = [[KSPath shared] tempDirFrom:pFifo.fileNameFull makeOption:YES];
            pathToThumb = [NSString stringWithFormat:@"%@/%@.png", pathToThumb, pFifo.fileNameOnly];
            UIImage* imageThumb = nil;
            
            // IF THERE IS NO THUMB FILE
            if ([[KSPath shared] isExistPath:pathToThumb] == NO) {
                imageThumb = [pFifo loadThumb:pFifo.durationSec.floatValue * 0.5];
                [UIImagePNGRepresentation(imageThumb) writeToFile:pathToThumb atomically:YES];
            } else {
                imageThumb = [UIImage imageWithContentsOfFile:pathToThumb];
            }
            
            [[self imageFileIcon] setImage:imageThumb];
            [self lableExt].hidden = YES;
            [self viewExtBack].hidden = YES;
            [self btnImgSpectrum].hidden = YES;
        }
        
    }
}

@end
