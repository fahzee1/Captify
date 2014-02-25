//
//  UIImage+AddText.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/25/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UIImage+AddText.h"

@implementation UIImage (AddText)

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    if([text respondsToSelector:@selector(drawInRect:withAttributes:)])
    {
        //iOS 7
        NSDictionary *att = @{NSFontAttributeName:font};
        [text drawInRect:rect withAttributes:att];
    }
    else
    {
        //legacy support
        [text drawInRect:CGRectIntegral(rect) withFont:font];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)drawWatermarkText:(NSString*)text {
    UIColor *textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    UIFont *font = [UIFont systemFontOfSize:50];
    CGFloat paddingX = 20.f;
    CGFloat paddingY = 20.f;
    
    // Compute rect to draw the text inside
    CGSize imageSize = self.size;
    NSDictionary *attr = @{NSForegroundColorAttributeName: textColor, NSFontAttributeName: font};
    CGSize textSize = [text sizeWithAttributes:attr];
    CGRect textRect = CGRectMake(imageSize.width - textSize.width - paddingX, imageSize.height - textSize.height - paddingY, textSize.width, textSize.height);
    
    // Create the image
    UIGraphicsBeginImageContext(imageSize);
    [self drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    [text drawInRect:CGRectIntegral(textRect) withAttributes:attr];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
