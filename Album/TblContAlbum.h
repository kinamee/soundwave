//
//  TblContAlbum.h
//  repeater
//
//  Created by admin on 2016. 9. 11..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "HTTPServer.h"

@interface TblContAlbum : UIViewController
        <UINavigationControllerDelegate, MPMediaPickerControllerDelegate,
        UIImagePickerControllerDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIView *viwWebServ;
@property (weak, nonatomic) IBOutlet UITableView *viwTable;
@property (weak, nonatomic) IBOutlet UIButton *btnImpVideo;
@property (weak, nonatomic) IBOutlet UIButton *btnImpAudio;
@property (weak, nonatomic) IBOutlet UIButton *btnImpClear;
@property (weak, nonatomic) IBOutlet UILabel *lblImpVideo;
@property (weak, nonatomic) IBOutlet UILabel *lblImpAudio;
@property (weak, nonatomic) IBOutlet UILabel *lblImpClear;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopOfTable;

- (IBAction)tchBtnImpVideo:(id)sender;
- (IBAction)tchBtnImpAudio:(id)sender;
- (IBAction)tchBtnImpClear:(id)sender;
- (IBAction)tchWebServ:(id)sender;

- (IBAction)tchTest:(id)sender;
- (void)userUploadingComplete:(NSString*)pFilePath;
- (void)refreshDataInTable;

@property (nonatomic, copy) NSData* audioData;
@property (nonatomic, retain) MPMediaPickerController *audioPicker;
@property (nonatomic, retain) UIImagePickerController *videoPicker;

@property (nonatomic, copy) NSDictionary* dictToHistory;
@property (nonatomic, copy) NSArray* arrToHistoryKeys;

@end
