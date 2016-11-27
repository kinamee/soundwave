//
//  VCWebServ.h
//  repeater
//
//  Created by admin on 2016. 9. 27..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "HTTPServer.h"
#import "TblContAlbum.h"

@interface VCWebServ : UIViewController
{
}

+ (VCWebServ*)shared;

@property (weak, nonatomic) IBOutlet UILabel *lblAddr;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblPercent;
@property (weak, nonatomic) IBOutlet UIProgressView *prgUploading;
@property (nonatomic, retain) TblContAlbum* vcParent;

@property (nonatomic, retain) HTTPServer *httpServer;

- (void)startWebServ;
- (void)stopWebServ;

- (void)uploadingProcess:(NSString*)pFilename
                  totLen:(NSInteger)pTotLen
                  curLen:(NSInteger)pCurLen;

- (void)uploadingComplete:(NSString*)pFilename
                   totLen:(NSInteger)pTotLen;

@end
