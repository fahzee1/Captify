//
//  KeyboardView.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/31/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardView : UIView <UIInputViewAudioFeedback>

- (instancetype)init;
@property(nonatomic, assign) UITextField* target;
@property(nonatomic, assign)int my;
@end
