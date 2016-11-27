//
//  TblContAlbum.m
//  repeater
//
//  Created by admin on 2016. 9. 11..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContAlbum.h"
#import "KSPath.h"
#import "TblContFileHelper.h"
#import "TblCellAlbum.h"
#import "VCLoading.h"
#import "VCWebServ.h"
#import "Config.h"

@interface TblContAlbum ()

@end

@implementation TblContAlbum

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dictToHistory = [self loadHistory];
    if (self.dictToHistory == nil)
        self.dictToHistory = [[NSDictionary alloc] init];
    
    NSArray *arrKeys = [self.dictToHistory.allKeys sortedArrayUsingSelector:
                        @selector(localizedCaseInsensitiveCompare:)];
    self.arrToHistoryKeys = [NSMutableArray arrayWithArray:arrKeys];
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

- (IBAction)tchWebServ:(id)sender
{
    // CHECK WIFI CONNECTION
    if (self.viwWebServ.hidden)
        if ([[Config shared] isWiFiConnect] == NO)
        {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:[[Config shared] trans:@"오류"]
                                       message:[[Config shared] trans:@"WiFi connection is needed"]
                                      delegate:nil
                             cancelButtonTitle:[[Config shared] trans:@"확인"]
                             otherButtonTitles:nil];
            [alert show];
            return;
        }
    
    self.viwWebServ.hidden = !self.viwWebServ.hidden;
    
    NSInteger height = 0;
    if (self.viwWebServ.hidden == NO)
    {
        [VCWebServ shared].vcParent = self;
        [[VCWebServ shared] startWebServ];
        
        height = self.viwWebServ.frame.size.height;
    }
    else
    {
        [[VCWebServ shared] stopWebServ];
    }
    
    [UIView animateWithDuration:1.0 animations:^{
        self.constraintTopOfTable.constant = height;
    } completion:nil];
    
    return;
}

- (IBAction)tchBtnImpVideo:(id)sender
{
    self.videoPicker = [[UIImagePickerController alloc] init];
    self.videoPicker.delegate = self;
    self.audioPicker.allowsPickingMultipleItems = NO;
    self.videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.videoPicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    //self.videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:self.videoPicker.sourceType];
    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ])
    {
        //NSLog(@"no video");
    }
    
    [self presentViewController:self.videoPicker animated:YES completion:nil];
}

- (IBAction)tchBtnImpAudio:(id)sender {
    
    self.audioPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    self.audioPicker.delegate = self;
    self.audioPicker.allowsPickingMultipleItems = NO;
    //self.audioPicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    //mediaPicker.prompt = NSLocalizedString(@"Select Your Favourite Song!", nil);
    //[mediaPicker loadView];
    
    [self.navigationController presentViewController:self.audioPicker animated:YES completion:^
     {
     }];
}

- (IBAction)tchBtnImpClear:(id)sender {
    
    self.dictToHistory = [[NSDictionary alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:self.dictToHistory forKey:@"HISTORY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self refreshDataInTable];
}

- (IBAction)tchTest:(id)sender {
}

/*--------------------------------
 LOAD HISTORY FROM NSUSERDEFAULT
 ---------------------------------*/
- (NSDictionary*)loadHistory {
    NSMutableDictionary* dictToRet = [NSMutableDictionary dictionaryWithDictionary:
                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"HISTORY"]];
    if (dictToRet == nil)
        return nil;
    
    NSArray *arrKeys = [self.dictToHistory.allKeys sortedArrayUsingSelector:
                        @selector(localizedCaseInsensitiveCompare:)];
    for (NSInteger i = 0; i < arrKeys.count; i++)
    {
        NSString* key = [arrKeys objectAtIndex:i];
        NSString* filePath = [dictToRet objectForKey:key];
        if ([[KSPath shared] isExistPath:filePath] == NO)
            [dictToRet removeObjectForKey:key];
    }
    
    // 가배지 정리한걸로 다시 저장해둔다
    NSDictionary* dictToSave = [NSDictionary dictionaryWithDictionary:dictToRet];
    [[NSUserDefaults standardUserDefaults] setObject:dictToSave forKey:@"HISTORY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return dictToRet;
}

/*-------------
 REFRESH TABLE
 --------------*/
- (void)refreshDataInTable
{
    // RELOAD HISTORY
    self.dictToHistory = [self loadHistory];
    if (self.dictToHistory == nil) {
        self.dictToHistory = [[NSDictionary alloc] init];
        NSLog(@"히스토리 닐이여서 초기화");
    }
    
    NSArray *arrKeys = [self.dictToHistory.allKeys sortedArrayUsingSelector:
                        @selector(localizedCaseInsensitiveCompare:)];
    self.arrToHistoryKeys = [NSMutableArray arrayWithArray:arrKeys];
    [self.viwTable reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // NSLog(@"로우카운트: %li", [_dictFileDirectory count]);
    return self.dictToHistory.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* key = [self.arrToHistoryKeys objectAtIndex:
                     (self.arrToHistoryKeys.count - (indexPath.row + 1))];
    NSString* filePath = [self.dictToHistory objectForKey:key];
    FileInfo* fifo = [[KSPath shared] createFileInfoObject:filePath];
    // [fifo printLog];
    
    NSString* cellIdentifier = @"CellHistory";
    
    // GET RESUSABLE CELL WITH CELL IDENTIFIER
    TblCellAlbum *cell = [tableView dequeueReusableCellWithIdentifier:
                                   cellIdentifier forIndexPath:indexPath];
    
    if(!cell) {
        // MAKE NEW CELL
        cell = [[TblCellAlbum alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
    }
    
    // DATA SET
    [cell dataFill:fifo];
    
    return cell;
}

/*---------------------
 USER SECLECTED A CELL
 ----------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    TblCellAlbum *cell = [tableView cellForRowAtIndexPath:indexPath];
    FileInfo* fifo = cell.fileInfo;
    
    // PLAY IT
    VCMoviePlayer *mpv = [VCMoviePlayer shared];
    
    if ([mpv.movieFilePath isEqualToString:fifo.fileNameFull] == NO) {
        [mpv pause];
        [mpv clearPlayer];
    }
    
    mpv.delegate = [TblContFileHelper shared].needHelp;
    // NSLog(@"현재 플레이어: %@", mpv.movieFilePath);
    [mpv showupOnParent:[TblContFileHelper shared].needHelp];
    [mpv setupPlayer:fifo.fileNameFull
              parent:[TblContFileHelper shared].needHelp
  funcNameOnComplete:@"play" funcOwner:mpv];
}


#pragma mark - MPMediaPickerController delegate

BOOL coreAudioCanOpenURL (NSURL* url){
    
    OSStatus openErr = noErr;
    AudioFileID audioFile = NULL;
    openErr = AudioFileOpenURL((__bridge CFURLRef) url,
                               kAudioFileReadPermission ,
                               0,
                               &audioFile);
    if (audioFile) {
        AudioFileClose (audioFile);
    }
    return openErr ? NO : YES;
    
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    NSURL *assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    /*NSLog (@"Core Audio %@ directly open library URL %@",
           coreAudioCanOpenURL (assetURL) ? @"can" : @"cannot",
           assetURL);
    
    NSLog (@"compatible presets for songAsset: %@",
           [AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset]);*/
    
    
    /* approach 1: export just the song itself
     */
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: songAsset
                                      presetName: AVAssetExportPresetAppleM4A];
    //NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString* destPath = [NSString stringWithFormat:@"%@",
                          [TblContFileHelper shared].needHelp.currDir];
    
    // MAKE NEW NAME
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMddyyyy-hhmmss"];
    NSString *newName = [dateFormat stringFromDate:date];
    destPath = [destPath stringByAppendingString:@"/IMPORTED "];
    destPath = [destPath stringByAppendingString:newName];
    destPath = [destPath stringByAppendingString:@".M4A"];
    destPath = [destPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    // end of approach 1
    
    // set up export (hang on to exportURL so convert to PCM can find it)
    // myDeleteFile(exportFile);
    //[exportURL release];
    NSURL* exportURL = [NSURL fileURLWithPath:destPath];
    exporter.outputURL = exportURL;
    
    // START LOADING
    [[VCLoading shared] showupOnParent:self];
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                // log error to text view
                NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                //errorView.text = exportError ? [exportError description] : @"Unknown failure";
                //errorView.hidden = NO;
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
            case AVAssetExportSessionStatusCompleted: {
                //NSLog (@"AVAssetExportSessionStatusCompleted");
                //fileNameLabel.text = [exporter.outputURL lastPathComponent];
                // set up AVPlayer
                //[self setUpAVPlayerForURL: exporter.outputURL];
                ///////////////// get audio data from url
                
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                
                //NSURL *audioUrl = exportURL;
                //NSLog(@"Audio Url=%@",audioUrl);
                //self.audioData = [NSData dataWithContentsOfURL:audioUrl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // SET BADGE VALUE +1
                    NSString* badgeValue = [self.tabBarController.tabBar.items objectAtIndex:0].badgeValue;
                    int badege = 0;
                    if (badgeValue)
                        badege = badgeValue.intValue;
                    badgeValue = [NSString stringWithFormat:@"%i", badege+1];
                    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:badgeValue];
                    
                    // 유저데이터에 저장
                    self.dictToHistory = [[KSPath shared] setValueToDict:self.dictToHistory value:destPath];
                    [[NSUserDefaults standardUserDefaults] setObject:self.dictToHistory forKey:@"HISTORY"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    // REFRESH
                    [self refreshDataInTable];
                    
                    // LOADING CLOSE
                    [[VCLoading shared] close:@"Complete"];
                });
                
                break;
            }
            case AVAssetExportSessionStatusUnknown: {
                NSLog (@"AVAssetExportSessionStatusUnknown");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
            case AVAssetExportSessionStatusExporting: {
                NSLog (@"AVAssetExportSessionStatusExporting");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
            case AVAssetExportSessionStatusCancelled: {
                NSLog (@"AVAssetExportSessionStatusCancelled");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
            case AVAssetExportSessionStatusWaiting: {
                NSLog (@"AVAssetExportSessionStatusWaiting");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
            default: {
                NSLog (@"didn't get export status");
                //[self stopLoader];
                //[self showAlertWithMessage:@"There ia an error!"];
                break;
            }
        }
    }];

    
    /*
    MPMusicPlayerController* appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [appMusicPlayer setQueueWithItemCollection:mediaItemCollection];
    [appMusicPlayer play];
    
    
    // Play the item using AVPlayer
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [player play];  */

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
            NSString* destPath = [NSString stringWithFormat:@"%@",
                                  [TblContFileHelper shared].needHelp.currDir];
            
            // MAKE NEW NAME
            NSDate *date = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"MMddyyyy-hhmmss"];
            NSString *newName = [dateFormat stringFromDate:date];
            destPath = [destPath stringByAppendingString:@"/IMPORTED "];
            destPath = [destPath stringByAppendingString:newName];
            destPath = [destPath stringByAppendingString:@".MOV"];
            destPath = [destPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            
            // COPY IT TO DOC
            //NSLog(@"SOURCE: %@", sourPath);
            //NSLog(@"TARGET: %@", destPath);
            [[KSPath shared] copyFile:sourPath targetPath:destPath];
            
            // 유저데이터에 저장
            self.dictToHistory = [[KSPath shared] setValueToDict:self.dictToHistory value:destPath];
            [[NSUserDefaults standardUserDefaults] setObject:self.dictToHistory forKey:@"HISTORY"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // REFRESH
            [self refreshDataInTable];
            
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

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)userUploadingComplete:(NSString*)pFilePath
{
    BOOL allowed = NO;
    NSString* extension = pFilePath.pathExtension.uppercaseString;
    if ([extension hasSuffix:@"MP3"] ||
        [extension hasSuffix:@"MP4"] ||
        [extension hasSuffix:@"M4A"] ||
        [extension hasSuffix:@"MOV"])
        allowed = YES;
    
    if (allowed == NO)
        return;
    
    // SET BADGE VALUE +1
    NSString* badgeValue = [self.tabBarController.tabBar.items objectAtIndex:0].badgeValue;
    int badege = 0;
    if (badgeValue)
        badege = badgeValue.intValue;
    badgeValue = [NSString stringWithFormat:@"%i", badege+1];
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:badgeValue];
    
    // 유저데이터에 저장
    self.dictToHistory = [[KSPath shared] setValueToDict:self.dictToHistory value:pFilePath];
    [[NSUserDefaults standardUserDefaults] setObject:self.dictToHistory forKey:@"HISTORY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // REFRESH
    [self refreshDataInTable];
}

- (void)repositionButtons {
    
}

@end
