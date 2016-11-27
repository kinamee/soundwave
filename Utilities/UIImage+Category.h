//
//  UIImage+AverageColor.h
//  repeater
//
//  Created by admin on 2016. 1. 25..
//  Copyright © 2016년 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (AverageColor)

- (UIColor*)averageColor;
- (UIColor*)colorAtPoint:(CGPoint)pixelPoint;
- (UIImage*)crop:(CGRect)pRect;
- (UIImage*)mergeToRight:(UIImage*)pImageToMerge;
- (UIImage*)mergeToLeft:(UIImage*)pImageToMerge;
- (UIImage*)convertToGrayscale;
- (float)amountOfColor:(CGRect)pRect;
- (UIImage*)imageByDrawingCircle:(CGRect)pRect radius:(float)pRadius;
@end
