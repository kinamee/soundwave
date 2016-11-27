//
//  TblCellSupportSubtitle.h
//  repeater
//
//  Created by admin on 2016. 3. 25..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TblCellSupportSubtitle : UITableViewCell
{
}

-(void)makeEventToChangeValue;

@property (weak, nonatomic) IBOutlet UILabel *lblCaption;
@property (weak, nonatomic) IBOutlet UISwitch *swcSubtitle;
@end
