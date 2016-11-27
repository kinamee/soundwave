//
//  TblCellVOA.m
//  repeater
//
//  Created by admin on 2016. 2. 11..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblCellTED.h"
#import "TblContTEDHelper.h"

@implementation TblCellTED

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dataSet:(MovieInfo*)pInfo
{
    self.movieInfo = pInfo;
    self.lblMovieTitle.text = pInfo.movieTitle;
    self.lblMoviePublished.text = [NSString stringWithFormat:@"Published: %@", pInfo.pubDateTime];
    self.lblDuration.text = pInfo.durationTime;
    
    if (self.movieInfo.linkToDownload != nil)
    {
        if ([self.movieInfo.linkToDownload hasSuffix:@"-en.mp4"]) {
            //self.lblSubtitle.text = @"ENG-SUBTITLE";
        } else self.lblSubtitle.text = @"NO-SUBTITLE";
    }
    
    // FIND THUMB-IMAGE, DOWNLOAD DETAIL PAGE
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        // LOAD THUMB IMAGE
        if (self.movieInfo.imgShot == nil)
        {
            [pInfo loadThumbImage:pInfo.linkToThumb handlerOnComplete:^(NSData *pImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.movieInfo.imgShot = [NSData dataWithData:pImage];
                    [self.imgMovie setImage:[UIImage imageWithData:self.movieInfo.imgShot]];
                });
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imgMovie setImage:[UIImage imageWithData:self.movieInfo.imgShot]];
            });
        }
        
        // LOAD DETAIL PAGE HTML
        if (self.movieInfo.htmlOfDetailPage == nil)
        {
            [pInfo loadHtmlOfDetailPage:pInfo.linkToDetailPage handlerOnComplete:
             ^(NSData* pSource) {
                 self.movieInfo.htmlOfDetailPage = [NSData dataWithData:pSource];
                 // FIND DOWNLOAD LINK
                 self.movieInfo.linkToDownload = [[TblContTEDHelper shared] findLinkToDownload:self.movieInfo.htmlOfDetailPage];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (self.movieInfo.linkToDownload)
                     {
                        if ([self.movieInfo.linkToDownload hasSuffix:@"-en.mp4"]) {
                         //self.lblSubtitle.text = @"ENG-SUBTITLE";
                        } else self.lblSubtitle.text = @"NO-SUBTITLE";
                     } else {
                         self.lblSubtitle.text = @"NO-DOWNLOAD";
                     }
                 });
             }];
        }
    });
}

@end
