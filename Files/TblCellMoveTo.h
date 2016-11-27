//
//  TblCellForMove.h
//  repeater
//
//  Created by admin on 2016. 1. 10..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TblCellMoveTo : UITableViewCell {
    
}

- (void)dataSetWith:(NSString*)pPath;

@property (retain, nonatomic) IBOutlet UIImageView *imgFolder;
@property (retain, nonatomic) IBOutlet UILabel *lblFolderName;

@end
