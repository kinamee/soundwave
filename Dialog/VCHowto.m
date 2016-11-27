//
//  VCHowto.m
//  repeater
//
//  Created by admin on 2016. 6. 12..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCHowto.h"

@interface VCHowto ()

@end

static VCHowto* instance = nil;

@implementation VCHowto

/*----------------------------------
 SINGLETON IMPLEMENTATION OF CLASS
 -----------------------------------*/
+(VCHowto*)shared {
    if (instance == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        instance = [storyboard instantiateViewControllerWithIdentifier:@"Howto"];
    }
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*-----------------------------------------------------
 SHOW MYSELF AS A MODAL VIEW ON PARENT VIEW-CONTROLLER
 ------------------------------------------------------*/
- (void)showupOnParent:(UIViewController*)pParent {
    
    [pParent.view addSubview:self.view];
    self.view.center = CGPointMake((pParent.view.frame.size.width / 2.0),
                                   (pParent.view.frame.size.height / 2.50));
}

- (IBAction)tchBtnClose:(id)sender {
    [self.view removeFromSuperview];
}


@end
