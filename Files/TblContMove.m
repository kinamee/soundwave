//
//  TblContForMove.m
//  repeater
//
//  Created by admin on 2016. 1. 10..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContMove.h"
#import "TblCellMoveTo.h"
#import "TblContFile.h"
#import "TblContFileHelper.h"
#import "Config.h"
#import "KSPath.h"
#import "FileInfo.h"

@interface TblContMove ()

@end

@implementation TblContMove

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dictDirectory = [NSMutableDictionary dictionaryWithDictionary:
                      [[KSPath shared] listOfDirectoryFromDocumentByRecusive]];
    //NSLog(@"%@", _dictDirectory);
     /*DICT SAMPE
     0 = "abc";
     1 = "abc/aaa";
     2 = "Dummy1";
     3 = "Dummy1/Dummy2";*/
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
    return _dictDirectory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TblCellMoveTo *cell = [tableView dequeueReusableCellWithIdentifier:@"CellForMoveto"];
    if (cell == nil) {
        cell = [[TblCellMoveTo alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"CellForMoveto"];
    }
    
    // COUNT OF SLASH
    NSString* rowIndex = [NSString stringWithFormat:@"%li", indexPath.row];
    [cell dataSetWith:[_dictDirectory valueForKey:rowIndex]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self clearCheckmark];
    TblCellMoveTo *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    NSString* keyName = [NSString stringWithFormat:@"%li", indexPath.row];
    NSString* value = [_dictDirectory objectForKey:keyName];

    _selectedDirectory = [NSString stringWithFormat:@"%@", value];
    //NSLog(@"선택된 폴더: %@", _selectedDirectory);
}

- (void)clearCheckmark {
    NSInteger rowCount = [self.TblForMove numberOfRowsInSection:0];
    for (int i = 0; i < rowCount; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        TblCellMoveTo* cell = [self.TblForMove cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (IBAction)btnCancelTouch:(id)sender {
    /* GET PARENT VIEWCONTROLLER */
    //TblContForFile* parent = (TblContForFile*)self.vwcParent;
    //NSLog(@"=%@=", parent.currDirectoryPath);
    
    [[self presentingViewController]
     dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnDoneTouch:(id)sender {
    
    // 이전뷰에서 선택된 파일을 목적폴더로 이동시키자
    NSArray* arrKey = [self.fileTobeMoved allKeys];
    for (int i = 0; i < arrKey.count; i++) {
        NSString* key = [arrKey objectAtIndex:i];
        FileInfo* fifo = [self.fileTobeMoved valueForKey:key];
        NSString* targetPath = [NSString stringWithFormat:@"%@/%@", _selectedDirectory,
                                fifo.fileNameOnly];
        // MOVE
        [[KSPath shared] moveFile:fifo.fileNameFull targetPath:targetPath];
        
        // MOVE IT IF IT WAS IMPORTED
        NSDictionary* dictToUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"HISTORY"];
        dictToUser = [[KSPath shared] changeValue:dictToUser
                                         oldValue:fifo.fileNameFull
                                         newValue:targetPath];
        [[NSUserDefaults standardUserDefaults] setObject:dictToUser forKey:@"HISTORY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // MOVE SCRIPT
        if ([[KSPath shared] isExistPath:[fifo fileNamefullByNewExt:@".TXT"]]) {
            [[KSPath shared] moveFile:[fifo fileNamefullByNewExt:@".TXT"]
                           targetPath:[[KSPath shared]
                                       changeFileNameByNewExt:targetPath
                                       newExt:@".TXT"]];
        }
        
        // MOVE SUBTITLE
        if ([[KSPath shared] isExistPath:[fifo fileNamefullByNewExt:@".SRT"]]) {
            [[KSPath shared] moveFile:[fifo fileNamefullByNewExt:@".SRT"]
                           targetPath:[[KSPath shared]
                                       changeFileNameByNewExt:targetPath
                                       newExt:@".SRT"]];
        }
        
        if ([fifo.fileNameFull isEqualToString:[VCMoviePlayer shared].movieFilePath])
        {
            // 실행중인 파일 옮긴다..?
            [[VCMoviePlayer shared] pause];
            [[VCMoviePlayer shared] clearPlayer];
            [[Config shared] setRecentPlaying:@"" fileSize:@"" curreSec:0.0 totalSec:0.0];
            [[TblContFileHelper shared] showRecentPlaying:NO];
        }
        
        // MOVE FILES RELATEVED TO THE MOVIE FILE IN TEMP DIR
        NSString* wildExp = [NSString stringWithFormat:@"*%@*",
                             [fifo.fileNameOnly substringToIndex:fifo.fileNameOnly.length - 4]];
        NSString* tempDirS = [[KSPath shared] tempDirFrom:fifo.fileNameFull makeOption:NO];
        NSString* tempDirT = [[KSPath shared] tempDirFrom:_selectedDirectory makeOption:YES];
        NSArray* arrFileToMove = [[KSPath shared] findFileByWildCard:wildExp inDir:tempDirS];

        for (int j = 0; j < arrFileToMove.count; j++)
        {
            NSString* fileToMove = [NSString stringWithFormat:@"%@/%@",
                                      tempDirS, [arrFileToMove objectAtIndex:j]];
            targetPath = [NSString stringWithFormat:@"%@/%@", tempDirT, [fileToMove lastPathComponent]];
            [[KSPath shared] moveFile:fileToMove targetPath:targetPath];
        }
    }
    
    /* GET PARENT VIEWCONTROLLER */
    TblContFile* parent = (TblContFile*)self.vwcParent;
    [parent refreshDataInTable];
    [parent makeEditState:NO];    
 
    [[self presentingViewController]
     dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
