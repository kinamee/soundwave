//
//  VCMoviePlayerHelper.m
//  repeater
//
//  Created by admin on 2016. 2. 7..
//  Copyright © 2016년 admin. All rights reserved.
//

#import "VCMoviePlayerHelper.h"
#import "VCMoviePlayer.h"
#import "KSPath.h"
#import "VCMovieConfig.h"

static VCMoviePlayerHelper* instance = nil;

@implementation VCMoviePlayerHelper

+ (VCMoviePlayerHelper*)shared
{
    if (instance == nil) {
        instance = [[VCMoviePlayerHelper alloc] init];
    }
    
    return instance;
}

/*----------------------------------
 REMOVE CONSTRAINTS FROM SUVER VIEW
 -----------------------------------*/
- (void)removeAllConstraintsFrom:(UIView*)pSuperView view:(UIView*)pMe
{
    for (NSLayoutConstraint *c in pSuperView.constraints) {
        if (c.firstItem == pMe || c.secondItem == pMe) {
            [pSuperView removeConstraint:c];
        }
    }
    
    //[pMe removeConstraints:pMe.constraints];
    pMe.translatesAutoresizingMaskIntoConstraints = NO;
}

/*------------------------------
 REPOSITIONING PLAY SCREEN-VIEW
 -------------------------------*/
- (void)repositionPlayScreen:(UIView*)parentView pScreenLayer:(UIView*)pLayer
{
    // SET THE WIDTH
    [parentView addConstraint:[NSLayoutConstraint
                              constraintWithItem:pLayer
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:parentView
                              attribute:NSLayoutAttributeWidth
                              multiplier:1.0
                              constant:0.0]];
    
    // SET THE HEIGHT
    [parentView addConstraint:[NSLayoutConstraint
                              constraintWithItem:pLayer
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:parentView
                              attribute:NSLayoutAttributeHeight
                              multiplier:1.0
                              constant:0.0]];
    
}

/*---------------------------
 REPOSITIONING SUBTITLE-VIEW
 ----------------------------*/
- (void)repositionSubtitle
{
    
    VCMoviePlayer* parent = (VCMoviePlayer*)self.needHelp;
    UIView* parentView = parent.view;
    UIView* subView = parent.viwSubtitle;
 
    //BOOL isBeingLandscape = (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation));
    
    float hafHei = parentView.frame.size.height/ 2.0;
    float yDistanceFromCen = hafHei;
    //if (parent.viwMenu.hidden)
    //    yDistanceFromCen = yDistanceFromCen - subView.frame.size.height;
    //else
        yDistanceFromCen = yDistanceFromCen - (subView.frame.size.height * 2.25);
    
    [self removeAllConstraintsFrom:parentView view:subView];
    
    // SET Y
    [parentView addConstraint:[NSLayoutConstraint
                            constraintWithItem:parentView
                            attribute:NSLayoutAttributeCenterY
                            relatedBy:NSLayoutRelationEqual
                            toItem:subView
                            attribute:NSLayoutAttributeCenterY
                            multiplier:1.0
                            constant:yDistanceFromCen * (-1)]];
    
    // SET X
    [parentView addConstraint:[NSLayoutConstraint
                            constraintWithItem:parentView
                            attribute:NSLayoutAttributeCenterX
                            relatedBy:NSLayoutRelationEqual
                            toItem:subView
                            attribute:NSLayoutAttributeCenterX
                            multiplier:1.0
                            constant:0.0]];
    
    // SET HEIGT
    [parentView addConstraint:[NSLayoutConstraint
                            constraintWithItem:subView
                            attribute:NSLayoutAttributeHeight
                            relatedBy:NSLayoutRelationEqual
                            toItem:parentView
                            attribute:NSLayoutAttributeHeight
                            multiplier:(1.0) / 10.00
                            constant:0.0]];
    
    // SET WIDTH
    [parentView addConstraint:[NSLayoutConstraint
                            constraintWithItem:subView
                            attribute:NSLayoutAttributeWidth
                            relatedBy:NSLayoutRelationEqual
                            toItem:parentView
                            attribute:NSLayoutAttributeWidth
                            multiplier:1.0
                            constant:0.0]];
    
    //[parentView bringSubviewToFront:parent.viwSubtitle];
    dispatch_async(dispatch_get_main_queue(), ^{
        parent.imgSpectrum.hidden = NO;
    });
}

@end
