//
//  VCLoading.m
//  repeater
//
//  Created by admin on 2016. 6. 6..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCLoading.h"

@interface VCLoading ()

@end

static VCLoading* instance = nil;

@implementation VCLoading

/*----------------------------------
 SINGLETON IMPLEMENTATION OF CLASS
 -----------------------------------*/
+(VCLoading*)shared {
    if (instance == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        instance = [storyboard instantiateViewControllerWithIdentifier:@"Loading"];
    }
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*-----------------------------------------------------
 SHOW MYSELF AS A MODAL VIEW ON PARENT VIEW-CONTROLLER
 ------------------------------------------------------*/
- (void)showupOnParent:(UIViewController*)pParent
{
    self.isShowing = YES;
    
    // SHOW
    self.indicator.hidden = NO;
    self.lblLoading.text = @"Loading";
    self.imgComplete.hidden = YES;
    self.imgCircle.alpha = 0.9f;
    
    self.view.alpha = 0.0;
    
    [pParent.view addSubview:self.view];
    self.view.center = CGPointMake((pParent.view.frame.size.width / 2.0),
                                   (pParent.view.frame.size.height / 2.50));
    
    [self fadeUp:nil];
}

- (void)fadeUp:(id)sender {
    self.view.alpha = self.view.alpha + 0.05;
    if (self.view.alpha < 1.0)
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self
                                       selector:@selector(fadeUp:)
                                       userInfo:nil
                                        repeats:NO];
}

/*-----------------------------------------------------
 SHOW MYSELF AS A MODAL VIEW ON PARENT VIEW-CONTROLLER
 ------------------------------------------------------*/
- (void)close
{
    self.indicator.hidden = YES;
    self.lblLoading.text = @"Complete";
    self.imgComplete.hidden = NO;
    self.imgCircle.alpha = 0.9f;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                   selector:@selector(onTimeToClose)
                                   userInfo:nil repeats:NO];
}

- (void)close:(NSString*)pMSG
{
    self.indicator.hidden = YES;
    self.lblLoading.text = pMSG;
    self.imgComplete.hidden = NO;
    self.imgCircle.alpha = 0.9f;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                   selector:@selector(onTimeToClose)
                                   userInfo:nil repeats:NO];
}

- (void)onTimeToClose {
    self.isShowing = NO;    
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
