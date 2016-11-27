//
//  TblContForMove.h
//  repeater
//
//  Created by admin on 2016. 1. 10..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TblContMove : UIViewController {
    NSString* _selectedDirectory;
    NSMutableDictionary* _dictDirectory;
}

- (IBAction)btnDoneTouch:(id)sender;
- (IBAction)btnCancelTouch:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *TblForMove;
@property (copy, nonatomic) NSDictionary* fileTobeMoved;
@property (weak, nonatomic) UIViewController *vwcParent;

@end
