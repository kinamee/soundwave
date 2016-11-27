//
//  TblContRecorded.h
//  repeater
//
//  Created by admin on 2016. 9. 7..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCVoiceRecorder.h"

@interface TblContRecorded : UIViewController <UITabBarControllerDelegate,
        UIDocumentInteractionControllerDelegate>
{
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *viwTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableTop;
@property (weak, nonatomic) IBOutlet UIView *viwRecorder;

@property (nonatomic, retain) NSMutableArray* arrRecFileKeys;
@property (nonatomic, retain) NSMutableDictionary* dictRecFiles;
@property (nonatomic, retain) NSMutableDictionary* dictRecFilesSelected;
@property (nonatomic, assign) BOOL isEditMode;
@property (weak, nonatomic) IBOutlet UIView *viwEdit;

@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
- (IBAction)tchBtnDelete:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnIntoPlayer;
- (IBAction)tchBtnIntoPlayer:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMail;
- (IBAction)tchBtnMail:(id)sender;

- (IBAction)tchBtnEdit:(id)sender;
- (IBAction)tchBtnRec:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

/*-------------
 REFRESH TABLE
 --------------*/
- (void)refreshDataInTable;

- (void)stopPlayingAllOf;
@end
