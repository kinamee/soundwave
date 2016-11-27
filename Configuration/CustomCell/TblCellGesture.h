//
//  TblCellGesture.h
//  repeater
//
//  Created by admin on 2015. 12. 30..
//  Copyright © 2015년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TblCellGesture : UITableViewCell {
    
}

-(void)dataSetWith:(NSDictionary*)pRow;

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblCaption;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;

@property (copy, nonatomic) NSString* configKeyPath;

@end
