/*
 UIImage+AverageColor.m
 
 Copyright (c) 2010, Mircea "Bobby" Georgescu
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the Mircea "Bobby" Georgescu nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL Mircea "Bobby" Georgescu BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIImage+Category.h"

@implementation UIImage (AverageColor)

- (UIImage*)mergeToRight:(UIImage*)pImageToMerge {
    
    CGSize newSize = CGSizeMake(self.size.width + pImageToMerge.size.width, self.size.height);
    
    UIGraphicsBeginImageContext( newSize );
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [pImageToMerge drawInRect:CGRectMake(self.size.width, 0,
                                         pImageToMerge.size.width,
                                         self.size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

- (UIImage*)mergeToLeft:(UIImage*)pImageToMerge {
    CGSize newSize = CGSizeMake(self.size.width + pImageToMerge.size.width, self.size.height);
    
    UIGraphicsBeginImageContext( newSize );
    
    //[self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    //[pImageToMerge drawInRect:CGRectMake(self.size.width, 0,
    //                                     pImageToMerge.size.width,
    //                                     pImageToMerge.size.width)];
    [pImageToMerge drawInRect:CGRectMake(0, 0, pImageToMerge.size.width, newSize.height)];
    [self drawInRect:CGRectMake(pImageToMerge.size.width, 0, self.size.width, self.size.height)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

- (UIColor*)averageColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

- (UIColor*)colorAtPoint:(CGPoint)pixelPoint
{
    if (pixelPoint.x > self.size.width ||
        pixelPoint.y > self.size.height) {
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(self.CGImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int numberOfColorComponents = 4; // R,G,B, and A
    float x = pixelPoint.x;
    float y = pixelPoint.y;
    float w = self.size.width;
    int pixelInfo = ((w * y) + x) * numberOfColorComponents;
    
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    // RGBA values range from 0 to 255
    return [UIColor colorWithRed:red/255.0
                           green:green/255.0
                            blue:blue/255.0
                           alpha:alpha/255.0];
}

- (UIImage*)crop:(CGRect)pRect
{
    UIImage* cropped_image = nil;
    @try {
        UIGraphicsBeginImageContextWithOptions(pRect.size, NO, self.scale);
        [self drawAtPoint:CGPointMake(-pRect.origin.x, -pRect.origin.y)];
        cropped_image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    @finally {
        return cropped_image;
    }
}

- (UIImage*)convertToGrayscale
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw a white background
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(ctx, imageRect);
    
    // Draw the luminosity on top of the white background to get grayscale
    [self drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
    
    // Apply the source image's alpha
    [self drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage* grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return grayscaleImage;
}

- (float)amountOfColor:(CGRect)pRect
{
    float sum = 0;
    for (NSInteger i = 0; i < pRect.size.height; i++)
    {
        for (NSInteger j = 0; j < pRect.size.width; j++)
        {
            UIColor* color = [self colorAtPoint:CGPointMake(i, j)];
            CGFloat r, g, b, alpha;
            [color getRed: &r green: &g blue: &b alpha: &alpha];
            sum += (r + g + b);
        }
    }
    
    //return sum;
    float percent = (sum * 100) / (pRect.size.height * pRect.size.width);
    return percent;
}

- (UIImage*)imageByDrawingCircle:(CGRect)pRect radius:(float)pRadius;
{
    UIGraphicsBeginImageContextWithOptions(pRect.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(pRect.size.width * 0.5 - pRadius,
                             pRect.size.height* 0.5 - pRadius,
                             pRadius * 2.0,
                             pRadius * 2.0);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    CGContextRestoreGState(ctx);
    UIImage* circle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return circle;
}

@end
