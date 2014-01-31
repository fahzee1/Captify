//
//  KeyboardView.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/31/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "KeyboardView.h"

@implementation KeyboardView

- (instancetype)init
{
     self = [[[NSBundle mainBundle] loadNibNamed:@"Keyboard" owner:self options:nil] lastObject];
    if (self){
        //custom here
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"Use init, its using xib");
    return nil;

}

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
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
