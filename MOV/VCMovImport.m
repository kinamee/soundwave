//
//  ContTemp.m
//  repeater
//
//  Created by admin on 2016. 5. 8..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCMovImport.h"
#import "Config.h"
#import "KSPath.h"
#import <AVFoundation/AVFoundation.h>

@interface VCMovImport ()

@end

@implementation VCMovImport

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // FOR DETECTING SCREEN RETATION
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self orientationChanged:nil];
}

/*-------------------------
 EVENT ON DEVICE ROTATION
 --------------------------*/
- (void)orientationChanged:(NSNotification *)note
{
    //NSLog(@"- (void)orientationChanged:(NSNotification *)note");
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // 화면 중앙의 위치
    float widthTot = self.view.frame.size.width;
    float widthHaf = widthTot / 2.0;
    float heighTot = self.view.frame.size.height;
    float heighHaf = heighTot / 2.0;
    
    // 모든 콘트롤들을 중앙세로 줄로 정렬시킨다
    self.lblDesc.center = CGPointMake(widthHaf, self.lblDesc.center.y);
    self.imgMovie.center = CGPointMake(widthHaf, self.imgMovie.center.y);
    self.btnImport.center = CGPointMake(widthHaf, self.btnImport.center.y);
    self.imgBtnBack.center = CGPointMake(widthHaf, self.imgBtnBack.center.y);
    
    // ADJUST MENU VIEW
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // LANDSCAPE
        
        // 무비이미지를 좌측 3분의 1에 위치시킨다
        self.imgMovie.center = CGPointMake(widthTot / 3.0, heighHaf);
        
        // 버튼을 중앙가로 줄로 정렬시킨다 (중앙보다 조금 아래)
        self.btnImport.center = CGPointMake((widthTot / 3.0) * 2.25, heighHaf);
        self.imgBtnBack.center = CGPointMake((widthTot / 3.0) * 2.25, heighHaf);
        
        // 라벨을 버튼과 최상단의 가운데로 정렬시킨다
        self.lblDesc.center = CGPointMake((widthTot / 3.0) * 2.25, heighHaf + 50.0);
        //self.lblDesc.text = @"Import movie";
    }
    else {
        // PORTRAIT
        // 비디오 이미지를 중앙보다 약간 위로 정렬시킨다
        self.imgMovie.center = CGPointMake(self.imgMovie.center.x, heighHaf - 25);
        
        // 라벨을 정렬시킨다
        self.lblDesc.center = CGPointMake(self.lblDesc.center.x, heighHaf - (heighHaf / 2.5) - 25);
        
        // 버튼을 정렬시킨다
        self.btnImport.center = CGPointMake(self.btnImport.center.x, heighHaf + (heighHaf / 2.25) - 15);
        self.imgBtnBack.center = CGPointMake(self.imgBtnBack.center.x, heighHaf + (heighHaf / 2.25 - 15));
    }
}

-(void)openVideoLib
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ])
    {
        //NSLog(@"no video");
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker
                    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo)
    {
        
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        //NSLog(@"type=%@",type);
        if ([type isEqualToString:(NSString *)kUTTypeVideo] ||
            [type isEqualToString:(NSString *)kUTTypeMovie])
        {// movie != video
            NSURL *urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
            NSString* sourPath = urlvideo.absoluteString;
            sourPath = [sourPath substringFromIndex:7];
            NSString* destPath = [[KSPath shared] documentPath];            
            
            // MAKE NEW NAME
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"MMddyyhhmmss"];
            NSString *newName = [dateFormat stringFromDate:date];
            destPath = [destPath stringByAppendingString:@"/[LIB] "];
            destPath = [destPath stringByAppendingString:newName];
            destPath = [destPath stringByAppendingString:@".MOV"];
            
            // COPY IT TO DOC
            //NSLog(@"SOURCE: %@", sourPath);
            //NSLog(@"TARGET: %@", destPath);
            [[KSPath shared] copyFile:sourPath targetPath:destPath];
            
            // SET BADGE VALUE +1
            NSString* badgeValue = [self.tabBarController.tabBar.items objectAtIndex:0].badgeValue;
            int badege = 0;
            if (badgeValue)
                badege = badgeValue.intValue;
            badgeValue = [NSString stringWithFormat:@"%i", badege+1];
            [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:badgeValue];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tchBtnImport:(id)sender {
    [self openVideoLib];
}
@end
