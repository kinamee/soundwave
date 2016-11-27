//
//  VCHowto.h
//  repeater
//
//  Created by admin on 2016. 6. 12..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCHowto : UIViewController

+(VCHowto*)shared;

/*-----------------------------------------------------
 SHOW MYSELF AS A MODAL VIEW ON PARENT VIEW-CONTROLLER
 ------------------------------------------------------*/
- (void)showupOnParent:(UIViewController*)pParent;

@property (weak, nonatomic) IBOutlet UILabel *lbl00;
@property (weak, nonatomic) IBOutlet UILabel *lbl01;
@property (weak, nonatomic) IBOutlet UILabel *lbl02;

@property (weak, nonatomic) IBOutlet UILabel *lbl03;
@property (weak, nonatomic) IBOutlet UILabel *lbl04;
@property (weak, nonatomic) IBOutlet UILabel *lbl05;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

- (IBAction)tchBtnClose:(id)sender;

@end
