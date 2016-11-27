//
//  TblContForRepeatCount.m
//  repeater
//
//  Created by admin on 2016. 1. 1..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContForRepeatCount.h"
#import "TblCellConfigCommon.h"
#import "Config.h"

@interface TblContForRepeatCount ()

@end

@implementation TblContForRepeatCount

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // SET LIST-DATA
    _arrData = [NSMutableArray arrayWithArray:[Config shared].arrRepeatCount];
    
    // SET TITLE
    NSString* naviTitle = [[Config shared] trans:@"문장 재생 횟수"];
    self.navigationItem.title = naviTitle.uppercaseString;
    
    [self createBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*------------------------------------
 CREATE BAR BUTTON PROGRAMMATICALLY
 -------------------------------------*/
- (void)createBackButton
{
    // CREATE CONTAINER VIEW
    UIView* buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    
    // CREATE BUTTON
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(0, 0, 25, 25);
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

/*----------------------------------
 ON NAVIGATION BACK BUTTON TOUCHED
 -----------------------------------*/
- (void)tchBtnBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 18;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    /*------------------
     SETTING LABLE TEXT
     -------------------*/
    NSString* valueFromDataSet = [_arrData objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", valueFromDataSet,
                           [[Config shared] trans:@"회"]];
    if (indexPath.row == 0) {
        NSString* labelText = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text,
                               [[Config shared] trans:@"반복없음"]];
        cell.textLabel.text = [labelText stringByReplacingOccurrencesOfString:@"Times"
                                                                   withString:@"Time"];
        
    }
    if (indexPath.row == _arrData.count - 1)
        cell.textLabel.text = [[Config shared] trans:@"무한반복"];
    
    
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    
    /*-----------------------
     SETTING CELL CHECK_MARK
     ------------------------*/
    float repeatCount = [[Config shared] getRepeatCount];
    if (repeatCount == valueFromDataSet.floatValue)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = [[Config shared] trans:@"문장 재생 횟수"];
    return header;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Update config file
    NSString* valueFromDataSet = [_arrData objectAtIndex:indexPath.row];
    [[Config shared] setRepeatCount:valueFromDataSet.intValue];
    [[Config shared] writeToFile];
    
    // Parent table row update
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    TblCellConfigCommon* parentCell = (TblCellConfigCommon*)self.parentCell;
    parentCell.lblValue.text = [NSString stringWithFormat:@"%@ %@", valueFromDataSet,
                                [[Config shared] trans:@"회"]];
    if (indexPath.row == 0) {
        parentCell.lblValue.text = [parentCell.lblValue.text
                                    stringByReplacingOccurrencesOfString:@"Times"
                                    withString:@"Time"];
        
    }
    
    // Table reload and back
    [tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
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

@end
