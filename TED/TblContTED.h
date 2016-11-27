//
//  TBLContVOA.h
//  repeater
//
//  Created by admin on 2016. 2. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TblContTED : UITableViewController <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, UITextFieldDelegate>
{
    UIRefreshControl *refreshControl;
}

@property (nonatomic, copy) NSDictionary* dictMovie;
@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic, copy) NSString* nameTobeDownload;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearch;

@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) NSInteger pageNumber;

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@property (weak, nonatomic) UILabel *lblNext;
@property (weak, nonatomic) UILabel *lblPrev;

@property (weak, nonatomic) UIButton *btnNext;
@property (weak, nonatomic) UIButton *btnPrev;

- (void)tchBtnPrev:(id)sender;
- (void)tchBtnNext:(id)sender;

@property (nonatomic, assign) BOOL isOnDownloading;
@property (nonatomic, assign) NSInteger pageNumOfDown;

@end
