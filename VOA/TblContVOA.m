//
//  TBLContVOA.m
//  repeater
//
//  Created by admin on 2016. 2. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContVOA.h"
#import "TblCellVOA.h"
#import "MovieInfo.h"
#import "TblContVOAHelper.h"
#import "KSPath.h"
#import "TblContFileHelper.h"
#import "Config.h"
#import "UIAlertController+Blocks.h"
#import "VCLoading.h"

@interface TblContVOA ()

@end

@implementation TblContVOA

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    /*----------------------------
     CREATE BAR BUTTON FOR PAGING
     -----------------------------*/
    [self createButtomForPaging:@"NEXT"];
    [self createButtomForPaging:@"PREV"];
    
    self.selectedIndex = -1;
    self.dictMovie = [NSMutableDictionary dictionary];
    
    /*----------------------
     LOAD VOA PAGE NUMBER 1
     -----------------------*/
    self.pageNumber = 1;
    [self loadPage:self.pageNumber];
    
    /*-----------------------
     SEARCH BAR BORDER COLOR
     ------------------------*/
    self.txtSearch.borderStyle = UITextBorderStyleNone;
    self.txtSearch.layer.cornerRadius = 8.0f;
    self.txtSearch.layer.masksToBounds = YES;
    self.txtSearch.layer.borderColor = [[UIColor clearColor] CGColor];
    self.txtSearch.layer.borderWidth = 1.0f;
    
    /*------------------------------
     SEARCH BAR TEXT FIELD DELEGATE
     -------------------------------*/
    self.txtSearch.delegate = self;
}

/*---------------
 ON REFRESH DRAG
 ----------------*/
- (void)dragToRefresh {
    [refreshControl endRefreshing];
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
        [self loadPage:self.pageNumber];
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
    [self.tableView addSubview:refreshControl];
    
    //NSLog(@"viewDidAppear: (%.2f)", self.tableView.contentOffset.y);
    if (self.dictMovie.count == 0)
        if (self.tableView.contentOffset.y < -28) {
            self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
            self.tableView.contentOffset = CGPointMake(0, 0 - 28.0);
        }
}

/*------------------------------------
 CREATE BAR BUTTON PROGRAMMATICALLY
 -------------------------------------*/
- (void)createButtomForPaging:(NSString*)pPosition
{
    // CREATE CONTAINER VIEW
    UIView* buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    // CREATE BUTTON
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor clearColor];
    
    // POSITION SETTING
    if ([pPosition isEqualToString:@"NEXT"])
        button.frame = CGRectMake(8, 0, 40, 40);
    if ([pPosition isEqualToString:@"PREV"])
        button.frame = CGRectMake(0, 0, 40, 40);

    // IMAGE SETTING
    if ([pPosition isEqualToString:@"NEXT"])
        [button setImage:[UIImage imageNamed:@"icn_navinext"] forState:UIControlStateNormal];
    if ([pPosition isEqualToString:@"PREV"])
        [button setImage:[UIImage imageNamed:@"icn_naviprev"] forState:UIControlStateNormal];
    
    [button setTitle:@"" forState:UIControlStateNormal];
    button.tintColor = [UIColor blackColor];
    button.autoresizesSubviews = YES;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;

    // METHOD SETTING
    if ([pPosition isEqualToString:@"NEXT"])
        [button addTarget:self action:@selector(tchBtnNext:) forControlEvents:UIControlEventTouchUpInside];
    if ([pPosition isEqualToString:@"PREV"])
        [button addTarget:self action:@selector(tchBtnPrev:) forControlEvents:UIControlEventTouchUpInside];

    // ADD VIEW ON THE NAVI BAR
    if ([pPosition isEqualToString:@"NEXT"]) {
        self.btnNext = button;
        [buttonView addSubview:self.btnNext];
    }
    if ([pPosition isEqualToString:@"PREV"]) {
        self.btnPrev = button;
        [buttonView addSubview:self.btnPrev];
    }
    
    // CREATE LABEL
    UILabel *label;
    if ([pPosition isEqualToString:@"NEXT"])
        label = [[UILabel alloc]initWithFrame:CGRectMake(7.5, 2.25, 25, 40)];
    if ([pPosition isEqualToString:@"PREV"])
        label = [[UILabel alloc]initWithFrame:CGRectMake(32.5, 2.25, 25, 40)];
    
    [label setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
    
    // PAGE NUMBER DISPLAY
    if ([pPosition isEqualToString:@"NEXT"])
        [label setText:@(self.pageNumber + 2).description];
    if ([pPosition isEqualToString:@"PREV"])
        [label setText:@(self.pageNumber - 1).description];
    
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    
    // ADD VIEW ON THE NAVI BAR
    self.lblNext.hidden = YES;
    self.lblPrev.hidden = YES;
    if ([pPosition isEqualToString:@"NEXT"]) {
        self.lblNext = label;
        [buttonView addSubview:label];
    }
    if ([pPosition isEqualToString:@"PREV"]) {
        self.lblPrev = label;
        [buttonView addSubview:label];
    }
    
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc]initWithCustomView:buttonView];
    if ([pPosition isEqualToString:@"NEXT"])
        self.navigationItem.rightBarButtonItem = barButton;
    if ([pPosition isEqualToString:@"PREV"])
        self.navigationItem.leftBarButtonItem = barButton;
}

- (void)loadPage:(NSInteger)pPageNum {
    
    // START LOADING
    [[VCLoading shared] showupOnParent:self];
    
    // PAGE NUMBER SETTING ON LABEL
    self.lblNext.text = @(pPageNum + 1).description;
    self.lblPrev.text = @(pPageNum - 1).description;
    
    self.lblPrev.hidden = (pPageNum == 1);
    self.btnPrev.hidden = (pPageNum == 1);
    
    NSString* urlOfVOA = [NSString stringWithFormat:
                          @"http://learningenglish.voanews.com/z/959/pc3.html?tab=None"];
    
    [TblContVOAHelper shared].needHelp = self;
    [[TblContVOAHelper shared] analizeHtml:urlOfVOA
                         handlerOnComplete:^(NSDictionary* pMovieInfo)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             
             // 로딩뷰 닫기
             [[VCLoading shared] close];
             
             /*----------------------------------
              THERE IS NO RESULTS FROM SEARCHING
              -----------------------------------*/
             if (pMovieInfo.count == 0) {
                 [UIAlertController
                  showAlertInViewController:self
                  withTitle:[[Config shared] trans:@"검색결과"].uppercaseString
                  message:[[Config shared] trans:@"검색결과가 존재하지 않습니다"]
                  cancelButtonTitle:nil
                  destructiveButtonTitle:[[Config shared] trans:@"확인"]
                  otherButtonTitles:nil
                  tapBlock:^(UIAlertController *controller,
                             UIAlertAction *action, NSInteger buttonIndex) {
                  }];
                 self.txtSearch.text = @"";
                 
             } else {
                
                 [self.dictMovie removeAllObjects];

                 // 현재 페이지를 기준으로 15개씩만 짤라낼 것
                 NSInteger startIdx = (pPageNum - 1) * 15;
                 for (NSInteger i = startIdx; i < startIdx + 15; i++) {
                     MovieInfo* movie = [pMovieInfo objectForKey:@(i).stringValue];
                     if (movie == nil)
                         break;
                     
                     [self.dictMovie setValue:movie forKey:@(self.dictMovie.count).stringValue];
                 }
                 
                 self.lblNext.hidden = (self.dictMovie.count != 15);
                 self.btnNext.hidden = (self.dictMovie.count != 15);
                 
                 [self.tableView reloadData];
             }
         });
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
    return self.dictMovie.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TblCellVOA *cell = [tableView dequeueReusableCellWithIdentifier:
                            @"cellOfMovieFromVOA" forIndexPath:indexPath];
    if(!cell){
        cell = [[TblCellVOA alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:@"cellOfMovieFromVOA"];
    }
    
    MovieInfo* info = [self.dictMovie valueForKey:@(indexPath.row).stringValue];
    [cell dataSet:info];

    return cell;
}

/*--------------------------
 MESSAGE FOR DOWNLOAD ERROR
 ---------------------------*/
- (void)waitAlertOfdownloading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertController
         showAlertInViewController:self
         withTitle:[[Config shared] trans:@"다운로드 진행중"]
         message:[[Config shared] trans:@"이미 다운로드 중인 파일이 있습니다"]
         cancelButtonTitle:nil
         destructiveButtonTitle:[[Config shared] trans:@"확인"]
         otherButtonTitles:nil
         tapBlock:^(UIAlertController *controller,
                    UIAlertAction *action, NSInteger buttonIndex) {
         }];
    });
}

/*---------------------
 USER SECLECTED A CELL
 ----------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ALREADY ON DOWNLOADING..?
    if (self.isOnDownloading) {
        [self waitAlertOfdownloading];
        return;
    }
    
    TblCellVOA *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // NAMING PROMPT
    // MAKE DEFAULT NAME
    NSString* defaultName = cell.movieInfo.movieTitle;
    NSInteger idxFrom = [defaultName rangeOfString:@"eport:"].location;
    if (idxFrom != NSNotFound)
        defaultName = [defaultName substringFromIndex:idxFrom + 7];
        
    NSCharacterSet* notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"]
                                       invertedSet];
    defaultName = [[defaultName componentsSeparatedByCharactersInSet:notAllowedChars]
                   componentsJoinedByString:@" "];
    
    NSArray* arrWord = [defaultName componentsSeparatedByString:@" "];
    NSMutableString* newName = [NSMutableString string];
    if (arrWord.count < 5)
        [newName appendString:cell.movieInfo.movieTitle];
    else
        for (int i = 0; i < 5; i++) {
            if (newName.length > 20)
                break;
            [newName appendString:@" "];
            [newName appendString:[arrWord objectAtIndex:i]];
        }
    defaultName = [NSString stringWithFormat:@"[VOA]%@", newName];
    
    // SHOW PROMPT FOR NEW FOLER
    TblContVOAHelper* helper = [TblContVOAHelper shared];
    [helper newNamePrompt:defaultName
                    title:@"다운로드"
                  message:cell.movieInfo.movieTitle
        handlerOnComplete:^(NSString* pNewName)
     {
         // CHECK SAME NAME EXIST
         NSString* pathToFile = [NSString stringWithFormat:@"%@/%@.mp3",
                                 [TblContFileHelper shared].needHelp.currDir, pNewName];
         if ([[KSPath shared] isExistPath:pathToFile])
             pathToFile = [[KSPath shared] newPathIfAlreadyExist:pathToFile];
         
         // EXPAND CELL
         cell.prsDownload.progress = 0.0f;
         
         // SAVE THE ROW NUMBER
         self.selectedIndex = indexPath.row;
         self.pageNumOfDown = self.pageNumber;
         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
         
         // RELOAD THE ROW FOR REDRAW
         [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                               withRowAnimation:UITableViewRowAnimationFade];
         
         self.nameTobeDownload = pathToFile;
         [self downloadLinkFrom:cell.movieInfo];
     }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndex == indexPath.row && self.pageNumOfDown == self.pageNumber)
        return 75;
    return 70;
}

/*------------------------------------
 FIND DOWNLOAD LINK FROM DETAIL PAGE
 -------------------------------------*/
- (void)downloadLinkFrom:(MovieInfo*)pMovieInfo
{
    [self downloadFrom:pMovieInfo.linkToDownload];
}

/*--------------
 DOWNLOAD MOVIE
 ---------------*/
- (void)downloadFrom:(NSString*)pDownloadLink
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL *url = [NSURL URLWithString:pDownloadLink];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithURL: url];
    
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
 
    // NSLog(@"다운로드 시작");
    self.isOnDownloading = YES;
    self.pageNumOfDown = self.pageNumber;
    
    _downloadSize = [response expectedContentLength];
    _dataToDownload = [[NSMutableData alloc]init];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_dataToDownload appendData:data];
    
    // PROGRESS INCREASES
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    TblCellVOA* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.prsDownload.progress = (_dataToDownload.length / _downloadSize);
}

/*--------------------------
 MESSAGE FOR DOWNLOAD ERROR
 ---------------------------*/
- (void)errorAlertOfdownloading {
    
    NSString* msg = [NSString stringWithFormat:@"%@\n%@",
                     [[Config shared] trans:@"아직 준비되지 않은 파일일 수 있습니다"],
                     [[Config shared] trans:@"다른 파일 이용을 권장합니다"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertController
         showAlertInViewController:self
         withTitle:[[Config shared] trans:@"다운로드 오류"].uppercaseString
         message:msg
         cancelButtonTitle:nil
         destructiveButtonTitle:[[Config shared] trans:@"확인"]
         otherButtonTitles:nil
         tapBlock:^(UIAlertController *controller,
                    UIAlertAction *action, NSInteger buttonIndex) {
         }];
    });
}

/*-----------------
 DOWNLOAD COMPLETE
 ------------------*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    self.isOnDownloading = NO;
    self.pageNumOfDown = -1;
    
    // COLLAPSE TABLE CELL
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    TblCellVOA* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.prsDownload.progress = 0.0;
    
    self.selectedIndex = -1;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    // DOWNLOAD COMPLETE
    // NSLog(@"didCompleteWithError: %@", error);
    
    if (_dataToDownload.length < 10) {
        NSLog(@"다운로드 파일 오류 발생");
        [self errorAlertOfdownloading];
        return;
    }
    
    // SAVE IT TO DOCUMENT
    [_dataToDownload writeToFile:self.nameTobeDownload atomically:YES];
    
    // SAVE SCRIPT
    // GET SCRIPT
    NSString* script = [[TblContVOAHelper shared] findScript:cell.movieInfo.htmlOfDetailPage];
    NSString* path4Scrpt = [[KSPath shared] changeFileNameByNewExt:self.nameTobeDownload
                                                            newExt:@".txt"];
    BOOL success = [script writeToFile:path4Scrpt atomically:YES
                              encoding:NSUTF8StringEncoding error:&error];
    if(success == NO)
        NSLog(@"Error saving to %@ - %@", path4Scrpt, [error localizedDescription]);
    
    // SET BADGE VALUE +1
    NSString* badgeValue = [self.tabBarController.tabBar.items objectAtIndex:0].badgeValue;
    int badege = 0;
    if (badgeValue)
        badege = badgeValue.intValue;
    badgeValue = [NSString stringWithFormat:@"%i", badege+1];
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:badgeValue];
    
    // SAVE THUMB IMAGE
    NSString* pathToThumb = [[KSPath shared] tempDirFrom:self.nameTobeDownload makeOption:YES];
    pathToThumb = [pathToThumb stringByAppendingFormat:@"/%@.thb",
                   [self.nameTobeDownload lastPathComponent]];
    [UIImagePNGRepresentation(cell.imgMovie.image) writeToFile:pathToThumb atomically:YES];
    //NSLog(@"이미지섬: %@", pathToThumb);
    
    // REFRESH FILE LIST
    [[TblContFileHelper shared] refreshTable];
}

/*-------------------------------
 ERROR OCCUR WHEN DOWNLOAD START
 --------------------------------*/
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"didBecomeInvalidWithError: %@", error);
    self.isOnDownloading = NO;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tchBtnPrev:(id)sender {
    //NSLog(@"VOA-이전페이지");
    self.pageNumber--;
    [self loadPage:self.pageNumber];
}

- (void)tchBtnNext:(id)sender {
    //NSLog(@"VOA-다음페이지");
    self.pageNumber++;
    [self loadPage:self.pageNumber];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //NSLog(@"Will begin dragging");
    [self.txtSearch resignFirstResponder];
    self.imgSearch.hidden = ![[[KSPath shared] encoded:self.txtSearch.text] isEqualToString:@""];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    /*-------------------------------
     WAIT UNTIL DOWNLOADING COMPLETE
     --------------------------------*/
    if (self.isOnDownloading) {
        [self waitAlertOfdownloading];
        return NO;
    }
    
    //NSLog(@"tchCancle");
    self.txtSearch.text = @"";
    
    self.imgSearch.hidden = ![[[KSPath shared] encoded:self.txtSearch.text] isEqualToString:@""];
    [self loadPage:self.pageNumber];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // DISMISS KEYBOARD
    [self.txtSearch resignFirstResponder];
    
    // SEARCH AND CREATE NEW DICTIONARY
    NSMutableDictionary* dictFound = [NSMutableDictionary dictionary];
    NSArray* arrTemp = [self.txtSearch.text componentsSeparatedByString:@" "];
    
    for (NSInteger i = 0; i < self.dictMovie.count; i++) {
        MovieInfo* info = [self.dictMovie valueForKey:@(i).description];
        
        BOOL isContained = NO;
        for (NSInteger j = 0; j < arrTemp.count; j++) {
             isContained = [info.movieTitle.uppercaseString containsString:
                            [[arrTemp objectAtIndex:j] uppercaseString]];
            if (isContained == YES) {
                [dictFound setValue:info forKey:@(dictFound.count).stringValue];
                break;
            }
        }
    }
    
    // NOT FOUND..?
    if (dictFound.count == 0) {
        [UIAlertController
         showAlertInViewController:self
         withTitle:[[Config shared] trans:@"검색결과"].uppercaseString
         message:[[Config shared] trans:@"검색결과가 존재하지 않습니다"]
         cancelButtonTitle:nil
         destructiveButtonTitle:[[Config shared] trans:@"확인"]
         otherButtonTitles:nil
         tapBlock:^(UIAlertController *controller,
                    UIAlertAction *action, NSInteger buttonIndex) {
         }];
        self.txtSearch.text = @"";
    } else {
        self.dictMovie = dictFound;
        [self.tableView reloadData];
    }
    
    //[self loadPage:self.pageNumber search:[[KSPath shared] encoded:self.txtSearch.text]];
    self.imgSearch.hidden = ![[[KSPath shared] encoded:self.txtSearch.text] isEqualToString:@""];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField {
    
    /*-------------------------------
     WAIT UNTIL DOWNLOADING COMPLETE
     --------------------------------*/
    if (self.isOnDownloading) {
        [self waitAlertOfdownloading];
        return NO;
    }
    
    self.imgSearch.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    self.imgSearch.hidden = ![[[KSPath shared] encoded:self.txtSearch.text] isEqualToString:@""];
    return YES;
}

@end
