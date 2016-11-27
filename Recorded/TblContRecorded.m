//
//  TblContRecorded.m
//  repeater
//
//  Created by admin on 2016. 9. 7..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContRecorded.h"
#import "TblCellRecorded.h"
#import "TblCellRecordedEdit.h"
#import "TblCellRecordedCommon.h"
#import "KSPath.h"
#import "VCLoading.h"
#import "Config.h"
#import "UIAlertController+Blocks.h"
#import "TblContFileHelper.h"
#import "VCVoiceRecorderInRec.h"

@interface TblContRecorded ()

@end

@implementation TblContRecorded

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // LOAD FILE AND FOLDER LIST
    self.dictRecFilesSelected = [NSMutableDictionary dictionary];
    
    NSString* dicToSearch = [NSString stringWithFormat:@"%@/_rec", [[KSPath shared] documentPath]];
    self.dictRecFiles = [NSMutableDictionary dictionaryWithDictionary:
                          [[KSPath shared] listOfFileFromDocument:dicToSearch extention:@"m4a"]];
    
    NSArray *arrKeys = [self.dictRecFiles.allKeys sortedArrayUsingSelector:
                        @selector(localizedCaseInsensitiveCompare:)];
    self.arrRecFileKeys = [NSMutableArray arrayWithArray:arrKeys];
    // NSLog(@"파일:%@", self.arrRecFileKeys);
    
    self.viwRecorder.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*---------------
 ON REFRESH DRAG
 ----------------*/
- (void)dragToRefresh {
    [refreshControl endRefreshing];
    
    // START LOADING
    [[VCLoading shared] showupOnParent:self];
    
    [self refreshDataInTable];
    
    [[VCLoading shared] close:@"Reloaded"];
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
    /*---------------
     리플레시 콘트롤 생성
     ----------------*/
    if (refreshControl != nil)
        [refreshControl removeFromSuperview];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [self.viwTable addSubview:refreshControl];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*-------------
 REFRESH TABLE
 --------------*/
- (void)refreshDataInTable
{
    // RELOAD FILE LIST AND REFRESH TABLE
    [self.dictRecFilesSelected removeAllObjects];
    [self.dictRecFiles removeAllObjects];
    [self.arrRecFileKeys removeAllObjects];
    
    self.dictRecFilesSelected = [NSMutableDictionary dictionary];
    
    NSString* dicToSearch = [NSString stringWithFormat:@"%@/_rec", [[KSPath shared] documentPath]];
    self.dictRecFiles = [NSMutableDictionary dictionaryWithDictionary:
                         [[KSPath shared] listOfFileFromDocument:dicToSearch extention:@"m4a"]];
    NSArray *arrKeys = [self.dictRecFiles.allKeys sortedArrayUsingSelector:
                        @selector(localizedCaseInsensitiveCompare:)];
    self.arrRecFileKeys = [NSMutableArray arrayWithArray:arrKeys];
    
    [self.viwTable reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NSLog(@"로우카운트: %li", [_dictFileDirectory count]);
    return self.dictRecFiles.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* key = [self.arrRecFileKeys objectAtIndex:
                     (self.arrRecFileKeys.count - (indexPath.row + 1))];
    FileInfo* fifo = [self.dictRecFiles valueForKey:key];
    
    NSString* cellIdentifier = @"CellRecorded";
    if (self.isEditMode)
        cellIdentifier = @"CellRecordedEdit";
    
    // GET RESUSABLE CELL WITH CELL IDENTIFIER
    TblCellRecordedCommon *cell = [tableView dequeueReusableCellWithIdentifier:
                                   cellIdentifier forIndexPath:indexPath];
    
    if(!cell) {
        // MAKE NEW CELL
        cell = [[TblCellRecordedCommon alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
    }
    
    // DATA SET
    [cell dataFill:fifo];
    
    // SELECT ICON SET
    if (self.isEditMode) {
        if ([self.dictRecFilesSelected objectForKey:key])
            [cell changeSelectedState:YES];
        else [cell changeSelectedState:NO];
    }
    
    return cell;
}

/*---------------------
 USER SECLECTED A CELL
 ----------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TblCellRecordedCommon *cell = [tableView cellForRowAtIndexPath:indexPath];
    FileInfo* fifo = cell.fileInfo;
    
    if (self.isEditMode == YES)
    {
        NSString* key = [self.arrRecFileKeys objectAtIndex:
                         (self.arrRecFileKeys.count - (indexPath.row + 1))];
        //FileInfo* fifo = [self.dictRecFiles valueForKey:key];
        NSObject* obj = [self.dictRecFilesSelected objectForKey:key];
        if (!obj)
        {
            [self.dictRecFilesSelected setValue:fifo forKey:key];
            [cell changeSelectedState:YES];
        } else {
            [self.dictRecFilesSelected removeObjectForKey:key];
            [cell changeSelectedState:NO];
        }
        
        [self changeButtonState];
    }
    else
    {
        [cell tchBtnPlayPause:nil];
    }
}

- (IBAction)tchBtnDelete:(id)sender {
    //NSLog(@"DELETE: %@", self.dictRecFilesSelected);
    // ON DELETE CONFIRM
    void(^deleteConfirm)(void) = ^{
        
        NSArray* arrSelected = [self.dictRecFilesSelected allKeys];
      
        // DELETE ALL FILES THAT USER SELECTED
        for (int i = 0; i < arrSelected.count; i++) {
            NSString* key = [arrSelected objectAtIndex:i];
            FileInfo* fifo = [self.dictRecFilesSelected valueForKey:key];
            
            // DELETE FILE IN PHYSICAL STORAGE
            [[KSPath shared] deleteFile:fifo.fileNameFull];
        }
        
        // EDIT COMPLETE
        [self tchBtnEdit:nil];
    };
    
    Config* trans = [Config shared];
    NSString* ttlForDelete = [trans trans:@"삭제"];
    NSString* msgForDelete = [NSString stringWithFormat:@"%li %@",
                              self.dictRecFilesSelected.count,
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

- (void)stopPlayingAllOf {
    for (int i = 0; i < [self.viwTable numberOfSections]; i++)
    {
        NSInteger rows =  [self.viwTable numberOfRowsInSection:i];
        for (int row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:i];
            TblCellRecordedCommon *cell = [self.viwTable cellForRowAtIndexPath:indexPath];
            if (cell.isPlaying)
                [cell tchBtnPlayPause:nil];
        }
    }
}

- (IBAction)tchBtnIntoPlayer:(id)sender {
    // NSLog(@"PLAYER: %@", self.dictRecFilesSelected);
    
    [self stopPlayingAllOf];
    
    // GET FILEINFO OBJECT
    NSArray* arrSelected = [self.dictRecFilesSelected allKeys];
    NSString* key = [arrSelected objectAtIndex:0];
    FileInfo* fifo = [self.dictRecFilesSelected valueForKey:key];
    
    // COPY M4A TO DOCUMENT
    NSString* pathToFile = [NSString stringWithFormat:@"%@/%@",
                            [TblContFileHelper shared].needHelp.currDir, fifo.fileNameOnly];
    //같은파일이이미존재하면?
    [[KSPath shared] copyFile:fifo.fileNameFull targetPath:pathToFile];
    
    // CLOSE EDIT MODE
    [self tchBtnEdit:nil];
    
    // REFRESH FILE LIST
    [[TblContFileHelper shared].needHelp refreshDataInTable];
    
    // SET BADGE VALUE +1
    NSString* badgeValue = [self.tabBarController.tabBar.items objectAtIndex:0].badgeValue;
    int badege = 0;
    if (badgeValue)
        badege = badgeValue.intValue;
    badgeValue = [NSString stringWithFormat:@"%i", badege+1];
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:badgeValue];
    
    // PLAY IT
    VCMoviePlayer *mpv = [VCMoviePlayer shared];
    mpv.delegate = [TblContFileHelper shared].needHelp;
    
    if ([mpv.movieFilePath isEqualToString:pathToFile] == NO) {
        [mpv pause];
        [mpv clearPlayer];
    }
    
    // NSLog(@"현재 플레이어: %@", mpv.movieFilePath);
    [mpv showupOnParent:[TblContFileHelper shared].needHelp];
    [mpv setupPlayer:pathToFile
              parent:[TblContFileHelper shared].needHelp
    funcNameOnComplete:@"play" funcOwner:mpv];
}

- (IBAction)tchBtnMail:(id)sender {
    //NSLog(@"EMAIL: %@", self.dictRecFilesSelected);
    [self openShareMenu];
}

- (IBAction)tchBtnEdit:(id)sender {
    
    [self stopPlayingAllOf];
    
    self.viwEdit.hidden = !self.viwEdit.hidden;
    self.isEditMode = (self.viwEdit.hidden == NO);
    
    if (self.isEditMode) {
        [self.btnEdit setImage:[UIImage imageNamed:@"icn_button_exit"]];
        self.btnMail.enabled = NO;
        self.btnDelete.enabled = NO;
        self.btnIntoPlayer.enabled = NO;
    } else {
        [self.btnEdit setImage:[UIImage imageNamed:@"icn_button_edit"]];
    }
    
    [self refreshDataInTable];
}

- (void)changeButtonState
{
    if (self.dictRecFilesSelected.count == 0) {
        self.btnMail.enabled = NO;
        self.btnDelete.enabled = NO;
        self.btnIntoPlayer.enabled = NO;
    }
    if (self.dictRecFilesSelected.count == 1) {
        self.btnMail.enabled = YES;
        self.btnDelete.enabled = YES;
        self.btnIntoPlayer.enabled = YES;
    }
    if (self.dictRecFilesSelected.count > 1) {
        self.btnMail.enabled = YES;
        self.btnDelete.enabled = YES;
        self.btnIntoPlayer.enabled = NO;
    }
}

- (void)openShareMenu
{
    NSArray* arrSelected = [self.dictRecFilesSelected allKeys];
    NSString* key = [arrSelected objectAtIndex:0];
    FileInfo* fifo = [self.dictRecFilesSelected valueForKey:key];
    
    self.documentInteractionController = [UIDocumentInteractionController
                                          interactionControllerWithURL:
                                          [NSURL fileURLWithPath:fifo.fileNameFull]];
    self.documentInteractionController.delegate = self;
    self.documentInteractionController.UTI = @"public.mpeg-4";
    [self.documentInteractionController presentOptionsMenuFromRect:self.view.frame
                                                            inView:self.view animated:YES];
}

- (IBAction)tchBtnRec:(id)sender {
    //NSLog(@"REC");
    [VCVoiceRecorderInRec shared].vcParent = self;
    self.viwRecorder.hidden = !self.viwRecorder.hidden;

    if (self.viwRecorder.hidden == NO)
        [[VCVoiceRecorderInRec shared] initRecorder];
    
    float height = 10 + self.viwRecorder.frame.size.height;
    if (self.viwRecorder.hidden)
        height = 10;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.constraintTableTop.constant = height;
    } completion:nil];
}

@end
