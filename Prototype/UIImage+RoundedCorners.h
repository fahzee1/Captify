//
//  UIImage+RoundedCorners.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/17/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (RoundedCorners)

+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original;
@end
