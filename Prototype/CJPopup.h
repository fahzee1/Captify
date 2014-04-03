//
//  CJPopup.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/10/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJPopupDelegate <NSObject>

- (void) userDidClickDoneButtonFromPopup:(UIView *)pop;

@end

@interface CJPopup : UIView

@property (weak) id <CJPopupDelegate> delegate;

- (void) showClear;
- (void) showErrorRed;
- (void) showSuccessBlurWithImage:(UIImage *)image;
- (void) showSuccessBlur2WithImage:(UIImage *)image sender:(NSString *)sender;
- (void) showFailBlurWithImage:(UIImage *)image;
- (void) hide;

@end
