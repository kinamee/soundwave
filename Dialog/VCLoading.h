//
//  VCLoading.h
//  repeater
//
//  Created by admin on 2016. 6. 6..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCLoading : UIViewController

+(VCLoading*)shared;

/*-----------------------------------------------------
 SHOW MYSELF AS A MODAL VIEW ON PARENT VIEW-CONTROLLER
 ------------------------------------------------------*/
- (void)showupOnParent:(UIViewController*)pParent;
- (void)close;
- (void)close:(NSString*)pMSG;

@property (nonatomic, assign) BOOL isShowing;
@property (weak, nonatomic) IBOutlet UIButton *imgCircle;
@property (weak, nonatomic) IBOutlet UIButton *imgComplete;
@property (weak, nonatomic) IBOutlet UILabel *lblLoading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
