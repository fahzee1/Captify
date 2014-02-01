//
//  AnswerFieldView.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/31/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AnswerFieldView.h"
#import "KeyboardView.h"

@implementation AnswerFieldView

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"use initwithframe and placeholder");
        return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
                  placeholder:(NSString *)holder
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // cgrectmake (10,200,300,40) is default textfield size
        
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.font = [UIFont systemFontOfSize:15];
        self.placeholder = holder;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        
    }
    return self;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
