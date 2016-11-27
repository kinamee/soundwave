//
//  KSTblCtrlForCfgWaiting.m
//  repeater
//
//  Created by admin on 2015. 12. 28..
//  Copyright © 2015년 admin. All rights reserved.
//

#import "TblContForWaiting.h"
#import "TblCellConfigCommon.h"
#import "Config.h"

@interface TblContForWaiting ()

@end

@implementation TblContForWaiting

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _arrData = [NSMutableArray array];
    [_arrData addObject:@"0"];
    [_arrData addObject:@"0.5"];
    [_arrData addObject:@"1.0"];
    [_arrData addObject:@"1.5"];
    [_arrData addObject:@"2.0"];
    [_arrData addObject:@"2.5"];
    [_arrData addObject:@"3.0"];
    [_arrData addObject:@"3.5"];
    [_arrData addObject:@"5.0"];
    [_arrData addObject:@"7.0"];
    [_arrData addObject:@"10.0"];
    
    // SET TITLE
    NSString* naviTitle = [[Config shared] trans:@"재생 전 대기시간"];
    self.navigationItem.title = naviTitle.uppercaseString;
    
    // CREATE BACK BUTTON
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
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    /*------------------
     SETTING LABLE TEXT
     -------------------*/
    NSString* valueFromDataSet = [_arrData objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", valueFromDataSet,
                           [[Config shared] trans:@"초"]];
    if (indexPath.row == 0)
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text,
                               [[Config shared] trans:@"대기없이 바로재생"]];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    
    /*-----------------------
     SETTING CELL CHECK_MARK
     ------------------------*/
    float waitingSec = [[Config shared] getWaitingSec];
    if (waitingSec == valueFromDataSet.floatValue)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* header = [[Config shared] trans:@"재생 전 대기시간"];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Update config file
    NSString* valueFromDataSet = [_arrData objectAtIndex:indexPath.row];
    [[Config shared] setWaitingSec:valueFromDataSet.floatValue];
    [[Config shared] writeToFile];
    
    // Parent table row update
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    TblCellConfigCommon* parentCell = (TblCellConfigCommon*)self.parentCell;
    parentCell.lblValue.text = [NSString stringWithFormat:@"%@ %@", valueFromDataSet,
                                [[Config shared] trans:@"초"]];
    
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
