//
//  UIImage+AddText.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/25/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AddText)

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point;

-(UIImage*)drawWatermarkText:(NSString*)text;
@end
