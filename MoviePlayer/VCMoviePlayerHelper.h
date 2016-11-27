//
//  VCMoviePlayerHelper.h
//  repeater
//
//  Created by admin on 2016. 2. 7..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "VCMoviePlayer.h"
#import "Config.h"

@interface VCMoviePlayerHelper : NSObject

+ (VCMoviePlayerHelper*)shared;

/*---------------------------
 REPOSITIONING SUBTITLE-VIEW
 ----------------------------*/
- (void)repositionSubtitle;

@property (nonatomic, weak) VCMoviePlayer* needHelp;

@end
