//
//  Caption.h
//  repeater
//
//  Created by admin on 2016. 3. 4..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubTitleCaption : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) float secToSta;
@property (nonatomic, assign) float secToEnd;
@property (nonatomic, copy) NSString* text;
@end
