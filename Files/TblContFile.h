//
//  TblContForFile.h
//  repeater
//
//  Created by admin on 2016. 1. 3..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCMoviePlayer.h"
#import "TblCellCommon.h"

@interface TblContFile : UIViewController <protocolMoviePlayer,
    UITabBarControllerDelegate, UIDocumentInteractionControllerDelegate> {
    
    UIRefreshControl *refreshControl;
        
    NSMutableDictionary* _dictSelectedRow;
    NSMutableDictionary* _dictDirectory;
    NSMutableDictionary* _dictFile;
    NSMutableDictionary* _dictFileDirectory;
}

- (void)makeEditState:(BOOL)pOnOff;
- (void)reloadListOfFileDirectory;
- (void)updatePlayingProgress:(float)pPercentage;

/*-------------------
 GET NEXT MOVIE FILE
 --------------------*/
- (NSString*)nextMovieFile:(NSString*)pCurrMovieFile;
- (NSString*)randomMovieFile:(NSString*)pCurrMovieFile;

/*-------------------------------
 GESTURE FROM LEFT EDGE TO RIGHT
 --------------------------------*/
-(IBAction)panGesture:(UIPanGestureRecognizer*)gestureRecognizer;

/*------------------------------
 MOVE INSIDE SPECIFIC DIRECTORY
 -------------------------------*/
- (void)moveInDir:(NSString*)pPath;
- (void)refreshDataInTable;

- (IBAction)btnEditTouch:(id)sender;
- (IBAction)btnRenameTouch:(id)sender;
- (IBAction)btnDeleteTouch:(id)sender;
- (IBAction)btnAddFolderTouch:(id)sender;
- (IBAction)tchPlayAndPause:(id)sender;
- (IBAction)tchRestoreScreen:(id)sender;
- (IBAction)btnOpenAs:(id)sender;

- (void)changePlayButtonImage:(BOOL)pOnOff;

@property (nonatomic, retain) TblContFile* vcBack;

@property (copy, nonatomic) NSString* currDir;
@property (nonatomic, assign) BOOL isEditmode;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UITableView *TblForFile;

@property (weak, nonatomic) IBOutlet UIView *viwForEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFolder;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteFile;
@property (weak, nonatomic) IBOutlet UIButton *btnMoveFile;
@property (weak, nonatomic) IBOutlet UIButton *btnRenameFile;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenAs;
@property (weak, nonatomic) IBOutlet UIView *viwProgress;
@property (weak, nonatomic) IBOutlet UIView *viwForPlaying;
@property (weak, nonatomic) IBOutlet UILabel *lblFileNameForPlaying;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayForPlaying;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentMovieLength;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end
