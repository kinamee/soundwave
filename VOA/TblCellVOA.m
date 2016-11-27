//
//  TblCellVOA.m
//  repeater
//
//  Created by admin on 2016. 2. 11..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblCellVOA.h"
#import "TblContVOAHelper.h"

@implementation TblCellVOA

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
    //NSLog(@"데이터셋: %@", pInfo.movieTitle);
    
    self.movieInfo = pInfo;
    self.lblMovieTitle.text = pInfo.movieTitle;
    self.lblMoviePublished.text = [NSString stringWithFormat:@"Published: %@", pInfo.pubDateTime];
    
    if ([self.movieInfo.linkToDownload isEqualToString:@"UNAVAILABLE"])
        self.lblSubtitle.text = @"UNAVAILABLE";
    else self.lblSubtitle.text = @"";

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
                 //NSLog(@"%@", self.movieInfo.movieTitle);
                 self.movieInfo.durationTime = [[TblContVOAHelper shared] findDuration:pSource];
                 self.movieInfo.htmlOfDetailPage = [NSData dataWithData:pSource];
                 
                 // FIND DOWNLOAD LINK
                 self.movieInfo.linkToDownload = [[TblContVOAHelper shared] findLinkToDownload:pSource];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if ([self.movieInfo.linkToDownload isEqualToString:@"UNAVAILABLE"])
                        self.lblSubtitle.text = @"UNAVAILABLE";
                     else {
                         self.lblSubtitle.text = @"";
                         self.lblDuration.text = self.movieInfo.durationTime;
                         if (self.movieInfo.durationTime.length == 4)
                             self.lblDuration.text = [NSString
                                                      stringWithFormat:@"0%@",
                                                      self.movieInfo.durationTime];
                     }
                 });
             }];
        }
    });
}

@end
