//
//  SentInfo.m
//  repeater
//
//  Created by admin on 2016. 5. 19..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "SentInfo.h"
#import "SentGroup.h"
#import "Config.h"

@implementation SentInfo

- (BOOL)isBeingInSec:(float)pSec {
    return ((pSec >= self.staSec) && (pSec <= self.endSec));
}

- (BOOL)isLastSen {
    return (self.index == [SentGroup shared].dictOfSent.count -1);
}

- (BOOL)isFirstSen {
    return (self.index == 0);
}

- (float)duration {
    return (self.endSec - self.staSec);
}

- (float)prevBlankDuration {
    if ([self isFirstSen]) {
        return self.staSec;
    }
    
    SentInfo* prevSen = [self getPrevSent];
    return (self.staSec - prevSen.endSec);
}

- (float)nextBlankDuration {
    if ([self isLastSen]) {
        return 0.0;
    }
    
    SentInfo* nextSen = [self getNextSent];
    return (nextSen.staSec - self.endSec);
}

- (SentInfo*)getPrevSent {
    if ([self isFirstSen]) {
        return nil;
    }
    
    return [[SentGroup shared] getByIndex:self.index - 1];
}

- (SentInfo*)getNextSent {
    if ([self isLastSen]) {
        return nil;
    }
    
    return [[SentGroup shared] getByIndex:self.index + 1];
}

- (void)printLog {
    /*
    NSLog(@"문장 정보 인덱스(%li)", self.index);
    NSLog(@"시작 시간 (%@) (%.2f)", [[Config shared] timeFormatted:self.staSec], self.staSec);
    NSLog(@"시작 프렘 (%li)", self.staFrame);
    NSLog(@"끝난 프렘 (%li)", self.endFrame);
    NSLog(@"문장 길이 (%.2f)", self.duration);
    NSLog(@"끝난 시간 (%@) (%.2f)", [[Config shared] timeFormatted:self.endSec], self.endSec);*/
}

@end
