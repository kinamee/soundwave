//
//  TblCellGesture.m
//  repeater
//
//  Created by admin on 2015. 12. 30..
//  Copyright © 2015년 admin. All rights reserved.
//

#import "TblCellGesture.h"
#import "Config.h"

@implementation TblCellGesture

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dataSetWith:(NSDictionary*)pRow
{
    Config* dataMgr = [Config shared];
    
    // SETTING CAPTION
    NSString* keyNameForCaption = [NSString stringWithFormat:@"CAPTION_%@", dataMgr.language];
    self.lblCaption.text = [pRow objectForKey:keyNameForCaption];
    
    // SETTING SELECTED ITEM OF SUB SECTION ITEMS
    NSString* subSectionName = [pRow objectForKey:@"SUB_SECTION_NAME"];
    NSString* subSectionRow = [pRow objectForKey:@"SUB_SELECTED_ROW"];
    NSString* keyPath = [NSString stringWithFormat:@"%@.ROWS.%@", subSectionName, subSectionRow];
    NSDictionary* rowFromSubSection = [dataMgr.dictToConf valueForKeyPath:keyPath];
    self.lblValue.text = [rowFromSubSection objectForKey:keyNameForCaption];
}

@end
