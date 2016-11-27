//
//  TBLContVOA.h
//  repeater
//
//  Created by admin on 2016. 2. 9..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TblContVOA : UITableViewController <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, UITextFieldDelegate> {
    
    UIRefreshControl *refreshControl;
}

@property (nonatomic, retain) NSMutableDictionary* dictMovie;
@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic, copy) NSString* nameTobeDownload;

@property (assign, nonatomic) NSInteger selectedIndex;
@property (assign, nonatomic) NSInteger pageNumber;

@property (weak, nonatomic) UILabel *lblNext;
@property (weak, nonatomic) UILabel *lblPrev;

@property (weak, nonatomic) UIButton *btnNext;
@property (weak, nonatomic) UIButton *btnPrev;

@property (weak, nonatomic) IBOutlet UIImageView *imgSearch;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

- (void)tchBtnPrev:(id)sender;
- (void)tchBtnNext:(id)sender;

@property (nonatomic, assign) BOOL isOnDownloading;
@property (nonatomic, assign) NSInteger pageNumOfDown;

@end
