//
//  TblCellAlbum.h
//  repeater
//
//  Created by admin on 2016. 9. 12..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileInfo.h"

@interface TblCellAlbum : UITableViewCell
{
    
}

- (UIImageView*)imageFileIcon;
- (UIImageView*)imageSelectIcon;
- (UILabel*)lableFileName;
- (UILabel*)lableFileDetail;
- (UILabel*)lableSubCount;

/*----------------------
 DATA SET WITH FILEINFO
 -----------------------*/
- (void)dataFill:(FileInfo*)pFifo;

@property (nonatomic, retain) FileInfo* fileInfo;

@end
