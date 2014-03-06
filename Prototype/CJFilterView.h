//
//  CJFilterView.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJFilterViewDelegate <NSObject>

- (void)filterView:(UIView *)view returnFilteredImage:(UIImage *)image;

@end


@interface CJFilterView : UIView


@property (strong,nonatomic)UIImage *targetImage;
@property (weak)id <CJFilterViewDelegate>delegate;

@end
