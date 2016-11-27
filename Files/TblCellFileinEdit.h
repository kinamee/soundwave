//
//  TblCellFileinEdit.h
//  repeater
//
//  Created by admin on 2016. 2. 24..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TblCellCommon.h"

@interface TblCellFileinEdit : TblCellCommon

@property (weak, nonatomic) IBOutlet UIImageView *imgFileIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelectedIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblSubCount;

@end
