//
//  TblContForGesture.m
//  repeater
//
//  Created by admin on 2016. 1. 3..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "TblContForGesture.h"
#import "TblCellGesture.h"
#import "Config.h"

@interface TblContForGesture ()

@end

@implementation TblContForGesture

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // SET TITLE
    NSString* naviTitle = [[Config shared] trans:@"제스쳐"];
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
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellForSelectGestureAction"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"CellForSelectGestureAction"];
    }
    
    Config* dataMgr = [Config shared];
    
    // SETTING CAPTION
    NSString* keyPath = [NSString stringWithFormat:
                         @"SECTION_GESTURE_ACTION.ROWS.ROW_%li", indexPath.row];
    NSDictionary* row = [dataMgr.dictToConf valueForKeyPath:keyPath];
    cell.textLabel.text = [row objectForKey:[NSString stringWithFormat:@"CAPTION_%@",
                                             dataMgr.language]];
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    
    // SETTING SELECTED ICON
    TblCellGesture* parentCell = (TblCellGesture*)self.parentCell;
    if ([parentCell.lblValue.text isEqualToString:cell.textLabel.text])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Config* dataMgr = [Config shared];
    NSString* keyPath = [NSString stringWithFormat:
                         @"SECTION_GESTURE_ACTION.HEADERS.HEADER_%@",
                         dataMgr.language];
    NSString* header = [dataMgr.dictToConf valueForKeyPath:keyPath];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    TblCellGesture* parentCell = (TblCellGesture*)self.parentCell;
    
    // Update config file
    NSString* selected = [NSString stringWithFormat:@"ROW_%li", indexPath.row];
    Config* dataMgr = [Config shared];
    //SECTION_GESTURE.ROWS.ROW_%@.SUB_SELECTED_ROW
    NSString* keyPath = [NSString stringWithFormat:@"%@.SUB_SELECTED_ROW", parentCell.configKeyPath];
    //NSLog(@"저장위치:%@", keyPath);
    //NSLog(@"저장값:%@", selected);
    [dataMgr.dictToConf setValue:selected forKeyPath:keyPath];
    [dataMgr writeToFile];
    
    // Parent table row update
    parentCell.lblValue.text = cell.textLabel.text;
    
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
