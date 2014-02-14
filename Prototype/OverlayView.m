//
//  OverlayView.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "OverlayView.h"

@interface OverlayView()


@end
@implementation OverlayView


- (instancetype)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil] lastObject];
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

- (IBAction)clickedMenu:(UIButton *)sender {
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(showMenuButtonClicked)]){
            [self.delegate showMenuButtonClicked];
        }
    }
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
