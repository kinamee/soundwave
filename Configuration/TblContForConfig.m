//
//  KSTblCtrlForCfg.m
//  repeater
//
//  Created by admin on 2015. 12. 27..
//  Copyright © 2015년 admin. All rights reserved.
//

#import "TblContForConfig.h"
#import "Config.h"
#import "TblCellConfigCommon.h"
#import "TblCellGesture.h"
#import "TblCellSupportSubtitle.h"
#import "TblContForWaiting.h"
#import "TblContForSentenceLen.h"
#import "TblContForRepeatCount.h"
#import "TblContForGesture.h"

@interface TblContForConfig ()

@end

@implementation TblContForConfig

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString* naviTitle = [[Config shared] trans:@"환경설정"];
    self.navigationItem.title = naviTitle.uppercaseString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*-------------------------
 FOR PLAYING IN BACKGROUND
 --------------------------*/
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return 3;
        case 2: return 1;
        case 3: return 6;
        default: return 0;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // NSLog(@"ROW-INDEX:%li.%li", indexPath.section, indexPath.row);
    
    Config* dataMgr = [Config shared];
    
    NSString* keyPath;
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0: {
            TblCellConfigCommon* cell = (TblCellConfigCommon*)[super tableView:tableView
                                                       cellForRowAtIndexPath:indexPath];
            cell.lblCaption.text = [[Config shared] trans:@"프로그램 정보"];
            return cell;
        }
        case 1: {
            TblCellConfigCommon* cell = (TblCellConfigCommon*)[super tableView:tableView
                                                       cellForRowAtIndexPath:indexPath];
            if (indexPath.row == 0) {
                cell.lblCaption.text = [[Config shared] trans:@"재생 전 대기시간"];
                cell.lblValue.text = [NSString stringWithFormat:@"%.1f %@",
                                      [[Config shared] getWaitingSec],
                                      [[Config shared] trans:@"초"]];
            }
            if (indexPath.row == 1) {
                cell.lblCaption.text = [[Config shared] trans:@"한 문장의 최소 시간 길이"];
                cell.lblValue.text = [NSString stringWithFormat:@"%.1f %@",
                                      [[Config shared] getMinimumSenSec],
                                      [[Config shared] trans:@"초"]];
            }
            if (indexPath.row == 2) {
                cell.lblCaption.text = [[Config shared] trans:@"문장 재생 횟수"];
                int repeatCnt = [[Config shared] getRepeatCount];
                if (repeatCnt == 0)
                {
                    cell.lblValue.text = [NSString stringWithFormat:@"%@",
                                          [[Config shared] trans:@"무한반복"]];
                } else {
                    cell.lblValue.text = [NSString stringWithFormat:@"%d %@",
                                          [[Config shared] getRepeatCount],
                                          [[Config shared] trans:@"회"]];
                }
            }
            return cell; 
        }
        case 2: {
            TblCellSupportSubtitle* cell = (TblCellSupportSubtitle*)[super tableView:tableView
                                                             cellForRowAtIndexPath:indexPath];
            cell.lblCaption.text = [[Config shared] trans:@"자막 (SRT) 지원"];
            cell.swcSubtitle.on = [[Config shared] getCaptionOnOFF];
            [cell makeEventToChangeValue];
            return cell;
        }
        case 3: {
            TblCellGesture* cell = (TblCellGesture*)[super tableView:tableView
                                               cellForRowAtIndexPath:indexPath];
            keyPath = [NSString stringWithFormat:
                       @"SECTION_GESTURE.ROWS.ROW_%li", (long)indexPath.row];
            NSDictionary* row = [dataMgr.dictToConf valueForKeyPath:keyPath];
            [cell dataSetWith:row];
            cell.configKeyPath = keyPath;
            return cell;
        }
        default: {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    NSString* header;
    if (section == 0)
        header = [[Config shared] trans:@"정보"];
    if (section == 1)
        header = [[Config shared] trans:@"자동반복"];
    if (section == 2)
        header = [[Config shared] trans:@"자막지원"];
    if (section == 3)
        header = [[Config shared] trans:@"제스쳐"];
    
    return header;
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"SequeToWaitingTime"]) {
        TblContForWaiting* cont = (TblContForWaiting*)segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        cont.parentCell = [self.tableView cellForRowAtIndexPath:path];
    }
    
    if([segue.identifier isEqualToString:@"SequeToSentenceLen"]) {
        TblContForSentenceLen* cont = (TblContForSentenceLen*)segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        cont.parentCell = [self.tableView cellForRowAtIndexPath:path];
    }
    
    if([segue.identifier isEqualToString:@"SequeToRepeatCount"]) {
        TblContForRepeatCount* cont = (TblContForRepeatCount*)segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        cont.parentCell = [self.tableView cellForRowAtIndexPath:path];
    }
    
    if([segue.identifier isEqualToString:@"SequeToGuestureAct"]) {
        TblContForGesture* cont = (TblContForGesture*)segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        cont.parentCell = [self.tableView cellForRowAtIndexPath:path];
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
