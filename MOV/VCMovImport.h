//
//  ContTemp.h
//  repeater
//
//  Created by admin on 2016. 5. 8..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface VCMovImport : UIViewController
    <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIImageView *imgMovie;
@property (weak, nonatomic) IBOutlet UIImageView *imgBtnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnImport;
- (IBAction)tchBtnImport:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end
