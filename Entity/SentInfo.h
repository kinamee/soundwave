//
//  SentInfo.h
//  repeater
//
//  Created by admin on 2016. 5. 19..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SentInfo : NSObject

- (BOOL)isBeingInSec:(float)pSec;
- (BOOL)isLastSen;
- (BOOL)isFirstSen;
- (float)duration;
- (float)prevBlankDuration;
- (float)nextBlankDuration;
- (SentInfo*)getPrevSent;
- (SentInfo*)getNextSent;

- (void)printLog;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) float staSec;
@property (nonatomic, assign) float endSec;
@property (nonatomic, assign) NSInteger staFrame;
@property (nonatomic, assign) NSInteger endFrame;

@end
