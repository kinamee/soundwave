//
//  TblCellSupportSubtitle.m
//  repeater
//
//  Created by admin on 2016. 3. 25..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblCellSupportSubtitle.h"
#import "Config.h"

@implementation TblCellSupportSubtitle

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)makeEventToChangeValue;
{
    //ConfigFile* dataMgr = [ConfigFile shared];
    [self.swcSubtitle addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}

- (void)setState:(id)sender
{
    BOOL state = [sender isOn];
    [[Config shared] setCaptionOnOFF:state];
}

@end
