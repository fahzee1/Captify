//
//  DraggablePhraseLabel.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/26/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "DraggableCaption.h"

@implementation DraggableCaption

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(CaptionStartedDragging)]){
            [self.delegate CaptionStartedDragging];
        }
    }
    
    UITouch *aTouch = [touches anyObject];
    CGPoint location = [aTouch locationInView:self.superview];
    [UIView beginAnimations:@"Dragging A DraggableView" context:nil];
    self.center = location;
    [UIView commitAnimations];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(CaptionStoppedDragging)]){
            [self.delegate CaptionStoppedDragging];
        }
    }
}

@end
