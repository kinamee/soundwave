//
//  TblCellFileinNormal.m
//  repeater
//
//  Created by admin on 2016. 2. 24..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblCellFileinNormal.h"

@implementation TblCellFileinNormal

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*----------------------
 DATA SET WITH FILEINFO
 -----------------------*/
- (void)dataFill:(FileInfo*)pFifo
{
    [super dataFill:pFifo];
}

/*------------------------------------
 DISPLAY ITSELF SELECTED OR UNSELECTED
 -------------------------------------*/
- (void)changeSelectedState:(BOOL)pOnOff
{
    [super changeSelectedState:pOnOff];
}

@end
