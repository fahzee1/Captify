//
//  OverlayView.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ODelegate <NSObject>

- (void)showMenuButtonClicked;

@end


@interface OverlayView : UIView

- (instancetype)init;

@property (weak,nonatomic) id <ODelegate> delegate;
@end
