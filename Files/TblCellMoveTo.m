//
//  TblCellForMove.m
//  repeater
//
//  Created by admin on 2016. 1. 10..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblCellMoveTo.h"

@implementation TblCellMoveTo

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dataSetWith:(NSString*)pPath {
    //NSLog(@"%@", pPath);
    NSString* folderName = [pPath lastPathComponent];
    
    pPath = [pPath lowercaseString];
    NSInteger idxFrom = [pPath rangeOfString:@"documents"].location;
    pPath = [pPath substringWithRange:NSMakeRange(idxFrom, pPath.length - idxFrom)];
    
    NSInteger countOfSlash = [pPath componentsSeparatedByString:@"/"].count;
    CGFloat blank = 25 * (countOfSlash -1);
    
    self.imgFolder = [[UIImageView alloc] initWithFrame:CGRectMake(18 +blank,
                                                                   14,
                                                                   15,
                                                                   15)];
    [self.imgFolder setImage:[UIImage imageNamed:@"icn_foldertype"]];
    [self.contentView addSubview:self.imgFolder];
    
    self.lblFolderName = [[UILabel alloc] initWithFrame:CGRectMake(39 + blank,
                                                                   11,
                                                                   248,
                                                                   21)];
    self.lblFolderName.textAlignment = NSTextAlignmentLeft;
    [self.lblFolderName setText: folderName];
    [self.lblFolderName setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightThin]];
    [self.contentView addSubview:self.lblFolderName];
    
    [self setAccessoryType:UITableViewCellAccessoryNone];
}

@end
