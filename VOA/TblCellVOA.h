//
//  TblCellVOA.h
//  repeater
//
//  Created by admin on 2016. 2. 11..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieInfo.h"

@interface TblCellVOA : UITableViewCell
{
    
}

- (void)dataSet:(MovieInfo*)pInfo;

@property (weak, nonatomic) IBOutlet UIImageView *imgMovie;
@property (weak, nonatomic) IBOutlet UILabel *lblMovieTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMoviePublished;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UIProgressView *prsDownload;

@property (nonatomic, retain) MovieInfo* movieInfo;

@end
