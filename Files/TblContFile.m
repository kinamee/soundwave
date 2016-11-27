//
//  TblContForFile.m
//  repeater
//
//  Created by admin on 2016. 1. 3..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContFile.h"
#import "TblContMove.h"
#import "FileInfo.h"
#import "KSPath.h"
#import "Config.h"
#import "UIAlertController+Blocks.h"
#import "VCMoviePlayer.h"
#import "TblContFileHelper.h"
#import "SentGroup.h"
#import "TblContRecorded.h"
#import "TblContAlbum.h"
#import "VCLoading.h"

@interface TblContFile ()

@end

static TblContFileHelper* helper = nil;

@implementation TblContFile

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TABBAR COLOR
    [UIApplication sharedApplication].delegate.window.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    //[UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1.00];
    
    // FOR DETECTING SCREEN RETATION
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // FOR PLAYING IN BACKGROUND
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // SET DELEGATE
    self.tabBarController.delegate = self;
    
    // TRANSLATE MENU TITLE
    // self.btnEdit.title = [[ConfigFile shared] translate:@"편집"];
    [self.btnEdit setImage:[UIImage imageNamed:@"icn_button_edit"]];
    
    // SET CURRENT PATH
    if (!self.currDir)
        self.currDir = [[KSPath shared] documentPath];
    self.navigationItem.title = self.currDir.lastPathComponent.uppercaseString;
    
    // LOAD FILE AND FOLDER LIST
    _dictSelectedRow = [NSMutableDictionary dictionary];
    _dictFileDirectory = [NSMutableDictionary dictionaryWithDictionary:
                          [[KSPath shared] listFromDocumentByOrder:self.currDir]];
    
    // SET HELPER
    helper = [TblContFileHelper shared];
    helper.needHelp = self;
    
    // SET RECENT PLAYER HIDEN
    //BOOL isBeingRecentPlayer = [[Config shared] isBeingRecentFile];
    //self.viwForPlaying.hidden = !(isBeingRecentPlayer);
    //[helper showRecentPlaying:isBeingRecentPlayer];
    
    // SHOW OR NOT CURRENT PLAYING INFO
    [NSTimer scheduledTimerWithTimeInterval:0.25
                                     target:self
                                   selector:@selector(onTimeOpenView:)
                                   userInfo:nil repeats:NO];
    
    // IS FIRST TIME TO EXEC..?
    if ([Config shared].isFirstExec == YES) {
        // NSLog(@"처음실행");
    }
}

/*---------------
 ON REFRESH DRAG
 ----------------*/
- (void)dragToRefresh {
    [refreshControl endRefreshing];
    
    // START LOADING
    [[VCLoading shared] showupOnParent:self];
    
    [self refreshDataInTable];
}

/*-----------
 ON DRAGGING
 ------------*/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pullDistance = MAX(0.0, - refreshControl.frame.origin.y);
    
    if (pullDistance > self.view.frame.size.height / 10.0)
        [refreshControl beginRefreshing];
}

/*---------------
 ON DRAGGING END
 ----------------*/
- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    if(refreshControl.isRefreshing) {
        [self dragToRefresh];
    }
}

/*---------------
 HIDE SEARCH BAR
 ----------------*/
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    /*---------------
     리플레시 콘트롤 생성
     ----------------*/
    if (refreshControl != nil)
        [refreshControl removeFromSuperview];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [self.TblForFile addSubview:refreshControl];
}

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
- (void)viewWillDisappear:(BOOL)animated
{
    //NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

/*------------------
 FIRE ON VIEW OPENED
 -------------------*/
- (void)onTimeOpenView:(id)sender {
    //return;
    BOOL isBeingRecentPlayer = [[Config shared] isBeingRecentFile];
    [helper showRecentPlaying:isBeingRecentPlayer];
    
    if (isBeingRecentPlayer) {
        // 플레이어셋업
        VCMoviePlayer *mpv = [VCMoviePlayer shared];
        mpv.delegate = self;
        // NSLog(@"현재 플레이어: %@", mpv.movieFilePath);
        if ((mpv.movieFilePath == NULL) ||
            ([mpv.movieFilePath isEqualToString:@""])) {
            NSString* recentFile = [[Config shared] getRecentFile];
            [mpv showupOnParent:self];
            [mpv setupPlayer:recentFile
                      parent:self
          funcNameOnComplete:@"pause" funcOwner:mpv];
        }
    }
}

/*-------------------------
 FOR CONTROL IN BACKGROUND
 --------------------------*/
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    [[VCMoviePlayer shared] remoteControlReceivedWithEvent:event];
}

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    //NSLog(@"백그라운드 진입 파일뷰 화면에서 이벤트 받음");
    BOOL isGoingOn = [[VCMoviePlayer shared] isInPlaying];
    if (isGoingOn)
        [[VCMoviePlayer shared] applicationDidEnterBackground:notification];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //NSLog(@"백그라운드에서 액티브로 올라옴");
    [self refreshDataInTable];
}

/*------------------------------------
 SET NAVIGATION BACK BUTTON & TITLE
 -------------------------------------*/
-(void)viewWillLayoutSubviews{
    BOOL isRoot = [self.currDir isEqualToString:[[KSPath shared] documentPath]];
    if (isRoot) {
        return;
    }
    // CREATE BACKBUTTON
    [self createBackButton];
}

/*------------------------------------
 CREATE BAR BUTTON PROGRAMMATICALLY
 -------------------------------------*/
- (void)createBackButton
{
    // CREATE CONTAINER VIEW
    UIView* buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    // CREATE BUTTON
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setImage:[UIImage imageNamed:@"icn_naviback_25x25"] forState:UIControlStateNormal];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.tintColor = [UIColor blackColor];
    button.autoresizesSubviews = YES;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [button addTarget:self action:@selector(tchBtnBack:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonView addSubview:button];
    
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc]initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = barButton;
}

- (UIViewController *)backViewController {
    NSInteger myIndex = [self.navigationController.viewControllers indexOfObject:self];
    if ( myIndex != 0 && myIndex != NSNotFound ) {
        return [self.navigationController.viewControllers objectAtIndex:myIndex-1];
    }
    return nil;
}

/*----------------------------------
 ON NAVIGATION BACK BUTTON TOUCHED
 -----------------------------------*/
- (void)tchBtnBack:(id)sender {
    
    // GET PREV VIEW CONTROLLER
    TblContFile* prevCont = (TblContFile*)[self backViewController];
    
    // SET PREV CONTROLLER TO THE HELPER'S DELEGATE
    [TblContFileHelper shared].needHelp = prevCont;
    
    // SET PREV CONTROLLER TO THE TABBARCONTROLLER'S DELEGATE
    prevCont.tabBarController.delegate = prevCont;
    
    // SET PLAYER'S DELEGATER
    [VCMoviePlayer shared].delegate = prevCont;
    
    // REFRESH PREV CONTROLLER'S TABLE
    [prevCont refreshDataInTable];
    
    // SHOW OR NOT CURRENT PLAY INFO
    //[helper showRecentPlaying:YES];
    
    // 플레이어가 퍼지 상태라면 이전 뷰에 프로그레스 진행사항 업데이트 해주자
    VCMoviePlayer* vcm = [VCMoviePlayer shared];
    if (([vcm isInPlaying] == NO) && (vcm.movieFilePath != nil))
    {
        double divide = (vcm.movieCurreSec / vcm.movieTotalSec);
        float percentage = divide * 100;
        [prevCont updatePlayingProgress:percentage];
        
        if ([[KSPath shared] isExistPath:vcm.movieFilePath])
        {
            FileInfo* fifo = [[KSPath shared] createFileInfoObject:vcm.movieFilePath];
            prevCont.lblFileNameForPlaying.text = fifo.fileNameOnly.stringByDeletingPathExtension;
            prevCont.lblCurrentMovieLength.text = [NSString stringWithFormat:@"[%@] %@ %@",
                                                   fifo.durationTimeFormatted,
                                                   fifo.fileExtention.uppercaseString,
                                                   fifo.fileSize];
        }
        //NSLog(@"이전뷰에 진행률 업데이트: %@", fifo.fileNameOnly);
    }
    
    // GO BACK
    [self.navigationController popViewControllerAnimated:YES];
}

/*------------------------------------
 DELEGATE METHOD ON SELECTING TAB-BAR
 -------------------------------------*/
- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
{
    NSInteger indexSelected = self.tabBarController.selectedIndex;
    //NSString* badgeValue = [self.tabBarController.tabBar.items objectAtIndex:indexSelected].badgeValue;
    //if (badgeValue == nil)
    //    return;
    
    [[self.tabBarController.tabBar.items objectAtIndex:indexSelected] setBadgeValue:nil];
    
    // IF THERE IS BEDGE, SET IT NIL
    // NSLog(@"탭바 델리게이션 작동");
    if (self.tabBarController.selectedIndex == 0) {
        //if (badgeValue != nil)
        //NSLog(@"%@", self.currDir);
        [self refreshDataInTable];
        
        if ([self.currDir.uppercaseString hasSuffix:@"DOCUMENTS"])
            return;
        
        // 루트폴더를 찾아서 리플레시 해주자
        TblContFile* prevCont = self.vcBack;
        while (prevCont != nil) {
            if ([prevCont.currDir.uppercaseString hasSuffix:@"DOCUMENTS"])
            {
                [prevCont refreshDataInTable];
                break;
            }
            // GET PREV VIEW CONTROLLER
            prevCont = prevCont.vcBack;
        }
    }
    
    if (self.tabBarController.selectedIndex == 1)
    {
        NSArray *viewControllers = self.tabBarController.viewControllers;
        UINavigationController *navi = (UINavigationController*)[viewControllers objectAtIndex:1];
        TblContRecorded* viwCont = (TblContRecorded*)[navi.viewControllers objectAtIndex:0];
        [viwCont refreshDataInTable];
    }
    
    if (self.tabBarController.selectedIndex == 2)
    {
        NSArray *viewControllers = self.tabBarController.viewControllers;
        UINavigationController *navi = (UINavigationController*)[viewControllers objectAtIndex:2];
        TblContAlbum* viwCont = (TblContAlbum*)[navi.viewControllers objectAtIndex:0];
        [viwCont refreshDataInTable];
    }
}

- (void)reloadListOfFileDirectory {
    _dictFileDirectory = [NSMutableDictionary dictionaryWithDictionary:
                          [[KSPath shared] listFromDocumentByOrder:self.currDir]];
}

/*---------------------------------
 INCRESE PROGRESS VIEW OR DECREASE
 ----------------------------------*/
- (void)updatePlayingProgress:(float)pPercentage {
    
    //NSLog(@"updatePlayingProgress: %.2f", pPercentage);
    float totalWidth = self.viwForPlaying.frame.size.width;
    float currentWidth = (totalWidth / 100) * pPercentage;
    //NSLog(@"진행률 넓이(%.2f) 전체넓이(%.2f)", currentWidth, totalWidth);
    [self.viwProgress setFrame:
     CGRectMake(self.viwProgress.frame.origin.x,
                self.viwProgress.frame.origin.y,
                currentWidth,
                self.viwProgress.frame.size.height)];
}

/*---------------------------------------------
 CHANGE EDIT-MODE TO NORMAL-MODE OR VICE VERSA
 ----------------------------------------------*/
- (void)makeEditState:(BOOL)pOnOff {
    self.isEditmode = pOnOff;
    
    if (self.isEditmode) {
        [self.btnEdit setImage:[UIImage imageNamed:@"icn_button_exit"]];
        self.viwForEdit.hidden = NO;
        
        /*--------------------------
         CHANGE EDIT-BUTTONS STATE
         ---------------------------*/
        [helper changeButtonState:_dictSelectedRow];
    } else {
        [self.btnEdit setImage:[UIImage imageNamed:@"icn_button_edit"]];
        self.viwForEdit.hidden = YES;
    }
    
    // DETERMINE SHOW OR NOT
    // PLAYING INFO IN BOTTOM
    [helper showRecentPlaying:!pOnOff];
    
    [_dictSelectedRow removeAllObjects];
    // TABLE HEIGHT RESIZE
    // [helper resizeTableHeight];
}

/*------------------------
 CHANGE VIEW TO EDIT-MODE
 -------------------------*/
- (IBAction)btnEditTouch:(id)sender {
    self.isEditmode = !self.isEditmode;
    [self makeEditState:self.isEditmode];
    [self refreshDataInTable];
}

/*------------------------
 SHARE FILE TO OTHER APPS
 -------------------------*/
- (IBAction)btnOpenAs:(id)sender
{    
    NSIndexPath *selectedIndexPath = [self.TblForFile indexPathForSelectedRow];
    TblCellCommon* cell = [self.TblForFile cellForRowAtIndexPath:selectedIndexPath];
    
    self.documentInteractionController = [UIDocumentInteractionController
                                          interactionControllerWithURL:
                                          [NSURL fileURLWithPath:cell.fileInfo.fileNameFull]];
    self.documentInteractionController.delegate = self;
    self.documentInteractionController.UTI = @"public.mpeg-4";
    [self.documentInteractionController presentOptionsMenuFromRect:self.view.frame
                                                            inView:self.view animated:YES];
    //[self.documentInteractionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
    //[self.documentInteractionController presentOptionsMenuFromBarButtonItem:(UIBarButtonItem*)sender
    //                                                     animated:YES];
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    self.documentInteractionController = nil;
}

/*------------------------
 RENAME FILE OR DIRECTORY
 -------------------------*/
- (IBAction)btnRenameTouch:(id)sender {
    
    // GET DEFAULT NAME TO BE CHANGE
    NSIndexPath *selectedIndexPath = [self.TblForFile indexPathForSelectedRow];
    TblCellCommon* cell = [self.TblForFile cellForRowAtIndexPath:selectedIndexPath];
    NSString* defaultName = [cell.fileInfo.fileNameOnly stringByDeletingPathExtension];
    NSString* defaultExte = cell.fileInfo.fileExtention;
    
    // SHOW PROMPT FOR NEW NAME
    [helper newNamePrompt:defaultName
                    title:@"이름 변경"
                  message:@"변경할 이름을 입력하세요"
            handlerOnComplete:^(NSString* pNewName)
    {
        // SET SOURCE AND TARGET PATH
        NSString* sourcePath = [NSString stringWithFormat:@"%@/%@.%@",
                                self.currDir, defaultName, defaultExte];
        NSString* targetPath = [NSString stringWithFormat:@"%@/%@.%@",
                                self.currDir, pNewName, defaultExte];

        // IF DIRECTORY? NO EXETENTION
        if (cell.fileInfo.isTypeOfDir == YES) {
            sourcePath = [sourcePath substringToIndex:sourcePath.length -1];
            targetPath = [targetPath substringToIndex:targetPath.length -1];
        }
        
        // CHANGE THE NAME
        BOOL noError = [[KSPath shared] moveFile:sourcePath
                                      targetPath:targetPath];
        
        // RENAME IT IF IT WAS IMPORTED
        NSDictionary* dictToUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"HISTORY"];
        dictToUser = [[KSPath shared] changeValue:dictToUser
                                         oldValue:sourcePath
                                         newValue:targetPath];
        [[NSUserDefaults standardUserDefaults] setObject:dictToUser forKey:@"HISTORY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // RENAME IT IF IT IS PLAYING
        if ([VCMoviePlayer shared].movieFilePath)
        {
            if ([[VCMoviePlayer shared].movieFilePath isEqualToString:sourcePath])
            {
                [VCMoviePlayer shared].movieFilePath = targetPath;
                [VCMoviePlayer shared].audioFilePath = [[AudioFromVideo shared]
                                                        audioFilePath:targetPath];
            }
        }
        
        if (noError) {
            // IF THERE IS SRT OR TXT
            sourcePath = [sourcePath stringByDeletingPathExtension];
            sourcePath = [sourcePath stringByAppendingString:@".TXT"];
            if ([[KSPath shared] isExistPath:sourcePath]) {
                targetPath = [NSString stringWithFormat:@"%@/%@",
                              self.currDir, pNewName];
                targetPath = [targetPath stringByDeletingPathExtension];
                targetPath = [targetPath stringByAppendingString:@".TXT"];
                
                // NSLog(@"SOURCE:%@", sourcePath);
                // NSLog(@"TARGET:%@", targetPath);
                
                // CHANGE THE TEMP FILES' NAME
                [[KSPath shared] moveFile:sourcePath targetPath:targetPath];
            }
            
            sourcePath = [sourcePath stringByDeletingPathExtension];
            sourcePath = [sourcePath stringByAppendingString:@".SRT"];
            if ([[KSPath shared] isExistPath:sourcePath]) {
                targetPath = [NSString stringWithFormat:@"%@/%@",
                              self.currDir, pNewName];
                targetPath = [targetPath stringByDeletingPathExtension];
                targetPath = [targetPath stringByAppendingString:@".SRT"];
                
                // NSLog(@"SOURCE:%@", sourcePath);
                // NSLog(@"TARGET:%@", targetPath);
                
                // CHANGE THE TEMP FILES' NAME
                [[KSPath shared] moveFile:sourcePath targetPath:targetPath];
            }
            
            // CHANGE TEMP FILES' NAME
            NSString* wildExp = [NSString stringWithFormat:@"*%@*",
                                 [cell.fileInfo.fileNameOnly substringToIndex:
                                  cell.fileInfo.fileNameOnly.length - 4]];
            NSString* tempDir = [[KSPath shared] tempDirFrom:cell.fileInfo.fileNameFull makeOption:NO];
            NSArray* arrFileToRen = [[KSPath shared] findFileByWildCard:wildExp inDir:tempDir];
            
            for (int j = 0; j < arrFileToRen.count; j++)
            {
                NSString* srcToRename = [NSString stringWithFormat:@"%@/%@",
                                         tempDir, [arrFileToRen objectAtIndex:j]];
                //NSLog(@"변경전 파일명:%@", srcToRename);
                NSString* extention = srcToRename.pathExtension;
                NSString* dstToRename = [NSString stringWithFormat:@"%@/%@.%@.%@",
                                         tempDir, pNewName, defaultExte,extention];
                //NSLog(@"변경후 파일명:%@", dstToRename);
                
                // CHANGE THE TEMP FILES' NAME
                [[KSPath shared] moveFile:srcToRename targetPath:dstToRename];
            }
            // RELOAD FILE & FOLDER LIST
            _dictFileDirectory = [NSMutableDictionary dictionaryWithDictionary:
                                  [[KSPath shared] listFromDocumentByOrder:
                                   self.currDir]];
            
            /* COMPLETE EDIT */
            [self makeEditState:NO];
            [self refreshDataInTable];
        } else {
            
            // IS IT ERROR, PLEASE DIFFRENT NAME
            Config* trans = [Config shared];
            
            [UIAlertController
             showAlertInViewController:self
             withTitle:[trans trans:@"오류"]
             message:[trans trans:@"다른 이름을 사용하세요"]
             cancelButtonTitle:nil
             destructiveButtonTitle:[trans trans:@"확인"]
             otherButtonTitles:nil
             tapBlock:^(UIAlertController *controller,
                        UIAlertAction *action, NSInteger buttonIndex) {
             }];
        }
        
    }];
}

/*------------------------
 DELETE FILE OR DIRECTORY
 -------------------------*/
- (IBAction)btnDeleteTouch:(id)sender {
    
    // ON DELETE CONFIRM
    void(^deleteConfirm)(void) = ^{
        
        NSArray* arrSelected = [_dictSelectedRow allKeys];
        
        // DELETE ALL FILES THAT USER SELECTED
        for (int i = 0; i < arrSelected.count; i++) {
            NSString* key = [arrSelected objectAtIndex:i];
            FileInfo* fifo = [_dictSelectedRow valueForKey:key];
            
            // IF CURRENT PLAYING FILE WILL BE DELETED THEN
            // SET CURRENT PLAYING INFO IN CONFIG "EMTPY"
            if ([fifo.fileNameFull isEqualToString:[VCMoviePlayer shared].movieFilePath])
            {
                [[VCMoviePlayer shared] pause];
                [[VCMoviePlayer shared] clearPlayer];
                [[Config shared] setRecentPlaying:@"" fileSize:@"" curreSec:0.0 totalSec:0.0];
                [helper showRecentPlaying:NO];
            }
            
            // DELETE FILE IN PHYSICAL STORAGE
            [[KSPath shared] deleteFile:fifo.fileNameFull];
            
            // DELETE IT IF IT WAS IMPORTED
            NSDictionary* dictToUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"HISTORY"];
            dictToUser = [[KSPath shared] deletedObject:dictToUser value:fifo.fileNameFull];
            [[NSUserDefaults standardUserDefaults] setObject:dictToUser forKey:@"HISTORY"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // DELETE SCRIPT FILE FOR TXT
            if ([[KSPath shared] isExistPath:[fifo fileNamefullByNewExt:@".TXT"]])
                [[KSPath shared] deleteFile:[fifo fileNamefullByNewExt:@".TXT"]];
            
            // DELETE SCRIPT FILE FOR SRT
            if ([[KSPath shared] isExistPath:[fifo fileNamefullByNewExt:@".SRT"]])
                [[KSPath shared] deleteFile:[fifo fileNamefullByNewExt:@".SRT"]];
            
            // DELETE FILES RELATEVED TO THE MOVIE FILE IN TEMP DIR
            if (!fifo.isTypeOfDir) {
                NSString* wildExp = [NSString stringWithFormat:@"*%@*",
                                     [fifo.fileNameOnly substringToIndex:fifo.fileNameOnly.length - 4]];
                NSString* tempDir = [[KSPath shared] tempDirFrom:fifo.fileNameFull makeOption:NO];
                NSArray* arrFileToDel = [[KSPath shared] findFileByWildCard:wildExp inDir:tempDir];
                // NSLog(@"함께 지울 파일들: %@", arrFileToDel);
                for (int j = 0; j < arrFileToDel.count; j++)
                {
                    NSString* fileToDelete = [NSString stringWithFormat:@"%@/%@",
                                              tempDir, [arrFileToDel objectAtIndex:j]];
                    [[KSPath shared] deleteFile:fileToDelete];
                }
            }
        }
        
        // EDIT COMPLETE
        [self makeEditState:NO];
        [self refreshDataInTable];
    };
    
    Config* trans = [Config shared];
    NSString* ttlForDelete = [trans trans:@"삭제"];
    NSString* msgForDelete = [NSString stringWithFormat:@"%li %@",
                              _dictSelectedRow.count,
                              [trans trans:@"선택됨"]];
    
    // SHOW DELETE-ALERT VIEW
    [UIAlertController
     showAlertInViewController:self
     withTitle:ttlForDelete
     message:msgForDelete
     cancelButtonTitle:[trans trans:@"취소"]
     destructiveButtonTitle:[trans trans:@"확인"]
     otherButtonTitles:nil
     tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
         if (buttonIndex == controller.destructiveButtonIndex) {
             deleteConfirm();
         }
     }];
}

/*-------------
 ADD DIRECTORY
 --------------*/
- (IBAction)btnAddFolderTouch:(id)sender {
    
    // SHOW PROMPT FOR NEW FOLER
    [helper newNamePrompt:@""
                    title:@"새로운 폴더"
                  message:@"폴더 이름을 입력하세요"
        handlerOnComplete:^(NSString* pNewName)
    {
        // CREATE NEW FOLDER
        BOOL noError = [[KSPath shared] createDirectory:
                        [NSString stringWithFormat:@"%@/%@", self.currDir, pNewName]];
        if (noError) {
            // RELOAD FILE & FOLDER LIST
            _dictFileDirectory = [NSMutableDictionary dictionaryWithDictionary:
                                  [[KSPath shared] listFromDocumentByOrder:self.currDir]];
            
            // ADD CELL IN TABLEVIEW THEN COMPLETE EDIT
            // [self reload];
            [self makeEditState:NO];
            [self refreshDataInTable];
        } else {
            // IS IT ERROR, PLEASE DIFFRENT NAME
            Config* trans = [Config shared];
            
            [UIAlertController
             showAlertInViewController:self
             withTitle:[trans trans:@"오류"]
             message:[trans trans:@"다른 이름을 사용하세요"]
             cancelButtonTitle:nil
             destructiveButtonTitle:[trans trans:@"확인"]
             otherButtonTitles:nil
             tapBlock:^(UIAlertController *controller,
                        UIAlertAction *action, NSInteger buttonIndex) {
             }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NSLog(@"로우카운트: %li", [_dictFileDirectory count]);
    return [_dictFileDirectory count];
}

/* SWIPE TO SHOW DELETE BUTTON
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.isEditmode)
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
    }
}*/

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // GET CELL IDENTIFIER
    TblContFileHelper* helper = [TblContFileHelper shared];
    
    NSString* key = [NSString stringWithFormat:@"%li", indexPath.row];
    FileInfo* fifo = [_dictFileDirectory valueForKey:key];
    NSString* cellIdentifier = [helper cellIdentityString:fifo isEditmode:self.isEditmode];
    // NSLog(@"CELL IDENTIFIER: %@", cellIdentifier);
    
    // GET RESUSABLE CELL WITH CELL IDENTIFIER
    TblCellCommon *cell = [tableView dequeueReusableCellWithIdentifier:
                            cellIdentifier forIndexPath:indexPath];
    
    if(!cell) {
        // MAKE NEW CELL
        cell = [[TblCellCommon alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }

    // DATA SET
    // [fifo printLog];
    [cell dataFill:fifo];
    
    // SELECT ICON SET
    if (self.isEditmode) {
        if ([_dictSelectedRow objectForKey:key])
            [cell changeSelectedState:YES];
        else [cell changeSelectedState:NO];
    }
    
    return cell;
}

- (void)refreshDataInTable {
    // RELOAD FILE LIST AND REFRESH TABLE
    [_dictSelectedRow removeAllObjects];
    [_dictFileDirectory removeAllObjects];
    
    _dictFileDirectory = [NSMutableDictionary dictionaryWithDictionary:
                          [[KSPath shared] listFromDocumentByOrder:
                           self.currDir]];
    
    [self.TblForFile reloadData];
    
    // 리로드 시작메세지 떠있다면 닫기
    if ([VCLoading shared].isShowing)
        [[VCLoading shared] close:@"Reloaded"];
    else
        [helper showRecentPlaying:YES];
}

/*---------------------------
 NAVIGATE INTO SUB DIRECTORY
 ----------------------------*/
- (void)moveInDir:(NSString*)pPath {
    TblContFile *vcFile = [self.storyboard
                                  instantiateViewControllerWithIdentifier:
                                  @"vwcForFile"];
    vcFile.vcBack = self;
    vcFile.currDir = pPath;
    [self.navigationController pushViewController:vcFile animated:YES];
}

/*---------------------
 USER SECLECTED A CELL
 ----------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TblCellCommon *cell = [tableView cellForRowAtIndexPath:indexPath];
    FileInfo* fifo = cell.fileInfo;
    
    /*-------------------------------------------
     IF NOT "EDIT MODE" AND A DIRECTORY IS SELECTED?
     GO INSIDE THE DIRECTORY SELECTED
     --------------------------------------------*/
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
    {
        if (!self.isEditmode) {
            NSString* pathToMove = [NSString stringWithFormat:@"%@/%@", self.currDir,
                                    fifo.fileNameOnly];
            //NSLog(@"폴더선택: %@", pathToMove);
            [self moveInDir:pathToMove];
            return;
        }
    }
    
    /*-------------------------------------
     IF "NONE-EDIT-MODE" CALL MOVIE PLAYER
     --------------------------------------*/
    NSString* rowNum = [NSString stringWithFormat:@"%li", indexPath.row];
    if (!self.isEditmode) {
        
        //NSLog(@"선택한 재생파일: %@", fifo.fileNameOnly);
        // SET SELECTED FILE INFO ON BOTTON PLAYING LABEL
        self.lblFileNameForPlaying.text = fifo.fileNameOnly.stringByDeletingPathExtension;
        self.lblCurrentMovieLength.text = [NSString stringWithFormat:@"[%@] %@ %@",
                                           fifo.durationTimeFormatted,
                                           fifo.fileExtention.uppercaseString,
                                           fifo.fileSize];
        
        // GET PLAYER
        VCMoviePlayer *mpv = [VCMoviePlayer shared];
        mpv.delegate = self;
        
        // IF RECENT FILE NOT IS EQUAL THE FILE TO PLAY
        // SAVE THIS FILE AS RECENT FILE
        if ([mpv.movieFilePath isEqualToString:fifo.fileNameFull] == NO) {
            [mpv pause];
            [mpv clearPlayer];
        }
        
        /*----------------------------------
         PLAYER SHOW-UP AND PLAY VIDEO FILE
         -----------------------------------*/
        [mpv showupOnParent:self];
        [mpv setupPlayer:fifo.fileNameFull
                  parent:self
      funcNameOnComplete:@"play"
               funcOwner:mpv];
        return;
    }
    
    NSObject* obj = [_dictSelectedRow objectForKey:rowNum];
    if (!obj)
    {
        [_dictSelectedRow setValue:fifo forKey:rowNum];
        [cell changeSelectedState:YES];
    } else {
        [_dictSelectedRow removeObjectForKey:rowNum];
        [cell changeSelectedState:NO];
    }
    
    /*--------------------------
     CHANGE EDIT-BUTTONS STATE
     ---------------------------*/
    [helper changeButtonState:_dictSelectedRow];
}

/*-------------
 PLAY OR PAUSE
 --------------*/
- (IBAction)tchPlayAndPause:(id)sender {
    [[VCMoviePlayer shared] playOpause];
    
    BOOL isShoudBeChanged = [[VCMoviePlayer shared] isInPlaying];
    [self changePlayButtonImage:isShoudBeChanged];
}

- (void)changePlayButtonImage:(BOOL)pOnOff {
    if (pOnOff)
        [self.btnPlayForPlaying setImage:[UIImage imageNamed:@"icn_player_pause"]
                                forState:UIControlStateNormal];
    else [self.btnPlayForPlaying setImage:[UIImage imageNamed:@"icn_player_play"]
                                 forState:UIControlStateNormal];
}

/*-------------------------------
 GESTURE FROM LEFT EDGE TO RIGHT
 --------------------------------*/
-(IBAction)panGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        UIBarButtonItem* barButton = self.navigationItem.leftBarButtonItem;
        if (barButton)
            [self tchBtnBack:nil];
    }
}

/*-------------------
 JUST SHOW UP PLAYER
 --------------------*/
- (IBAction)tchRestoreScreen:(id)sender
{
    VCMoviePlayer *mpv = [VCMoviePlayer shared];
    mpv.delegate = self;
    
    [mpv showupOnParent:self];
}

/*----------------------------------------------------
 DELEGATE ON EXECUTE BY "VCMoviePlayer" WHEN PLAYING
 -----------------------------------------------------*/
- (void)onPlaying:(NSString *)pMovieFile duration:(float)pDuration
      currentSec:(float)pCurrentSec percentage:(float)pPercentage
{
    if (pPercentage > -1)
        [self updatePlayingProgress:pPercentage];
    
    if ([pMovieFile rangeOfString:self.lblFileNameForPlaying.text].location != NSNotFound)
        return;
    
    FileInfo* fifo = [[KSPath shared] createFileInfoObject:pMovieFile];
    self.lblFileNameForPlaying.text = fifo.fileNameOnly.stringByDeletingPathExtension;
    self.lblCurrentMovieLength.text = [NSString stringWithFormat:@"[%@] %@ Type %@",
                                       fifo.durationTimeFormatted,
                                       fifo.fileExtention.uppercaseString,
                                       fifo.fileSize];
}

/*-------------------
 GET NEXT MOVIE FILE
 --------------------*/
- (NSString*)nextMovieFile:(NSString*)pCurrMovieFile
{
    NSString* dir = [pCurrMovieFile stringByDeletingLastPathComponent];
    NSDictionary* dictSortedFiles = [[KSPath shared] filelistSorted:dir];
    NSString* nextMovie = [helper nextMovieFileIn:dictSortedFiles
                                         currFile:pCurrMovieFile];
    return nextMovie;
}

/*-------------------
 GET NEXT MOVIE FILE
 --------------------*/
- (NSString*)randomMovieFile:(NSString*)pCurrMovieFile
{
    NSString* dir = [pCurrMovieFile stringByDeletingLastPathComponent];
    NSDictionary* dictSortedFiles = [[KSPath shared] filelistSorted:dir];
    
    if (dictSortedFiles.count == 1)
        return pCurrMovieFile;
    
    NSString* randomMovie = [helper randomMovieFileIn:dictSortedFiles
                                             currFile:pCurrMovieFile];
    return randomMovie;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"SequeToFileMove"]) {
        TblContMove* cont = (TblContMove*)segue.destinationViewController;
        cont.fileTobeMoved = _dictSelectedRow;
        cont.vwcParent = self;
    }
}

/*-------------------------
 EVENT ON DEVICE ROTATION
 --------------------------*/
- (void)orientationChanged:(NSNotification *)note
{
    //NSLog(@"- (void)orientationChanged:(NSNotification *)note");
    //UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //BOOL isLandScape = UIInterfaceOrientationIsLandscape(orientation);
    
    UITableView *tableview = self.TblForFile;    //set your tableview here
    NSInteger sectionCount = [tableview numberOfSections];
    for(NSInteger sectionI = 0; sectionI < sectionCount; sectionI++) {
        NSInteger rowCount = [tableview numberOfRowsInSection:sectionI];
        //NSLog(@"sectionCount:%li rowCount:%li", sectionCount, rowCount);
        for (int rowsI=0; rowsI < rowCount; rowsI++) {
            TblCellCommon *cell = (TblCellCommon*)[tableview cellForRowAtIndexPath:
                                                    [NSIndexPath indexPathForRow:rowsI
                                                                    inSection:sectionI]];
            
            // SET TITLE WIDTH NEWLY
            UILabel* lblTitle = [cell lableFileName];
            float newWidth = (cell.frame.size.width - [cell imageFileIcon].frame.size.width) * 0.9;
            CGRect newRect = CGRectMake(lblTitle.frame.origin.x,
                                        lblTitle.frame.origin.y,
                                        newWidth,
                                        lblTitle.frame.size.height);
            [lblTitle setFrame:newRect];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleInsert;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
