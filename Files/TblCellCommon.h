//
//  TblCellCommon.h
//  repeater
//
//  Created by admin on 2016. 2. 24..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfo.h"

@interface TblCellCommon : UITableViewCell
{
}

- (UIImageView*)imageFileIcon;
- (UIImageView*)imageSelectIcon;
- (UILabel*)lableFileName;
- (UILabel*)lableFileDetail;
- (UILabel*)lableSubCount;
- (UIView*)viewExtBack;
- (UILabel*)lableExt;
- (UIButton*)btnImgSpectrum;

/*----------------------
 DATA SET WITH FILEINFO
 -----------------------*/
- (void)dataFill:(FileInfo*)pFifo;

/*------------------------------------
 DISPLAY ITSELF SELECTED OR UNSELECTED
 -------------------------------------*/
- (void)changeSelectedState:(BOOL)pOnOff;

@property (nonatomic, retain) FileInfo* fileInfo;

@end
