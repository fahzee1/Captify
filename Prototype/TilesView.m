//
//  TilesView.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "TilesView.h"

@interface TilesView()
@property int xOffset;
@property int yOffset;
@end

@implementation TilesView

- (id)init
{
    NSAssert(NO, @"Use initWithLetter");
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"Use initWithLetter");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(NO, @"Use initWithLetter");
    return nil;

}

- (id)initWithImage:(UIImage *)image
{
    NSAssert(NO, @"Use initWithLetter");
    return nil;

}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    NSAssert(NO, @"Use initWithLetter");
    return nil;

}

- (instancetype) initWithLetter:(NSString *)letter andSideLength:(float)sideLength
{
    // set background
    UIImage *img = [UIImage imageNamed:@"profile-placeholder"];
    
    self = [super initWithImage:img];
    if (self != nil){
        // resize the tile
        _letter = letter;
        self.userInteractionEnabled = YES;
        self.isMatched = NO;
        float scale = sideLength/img.size.width;
        self.frame = CGRectMake(0, 0, img.size.width*scale, img.size.height*scale);
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = [self.letter uppercaseString];
        label.font = [UIFont fontWithName:@"Verdana-Bold" size:60.0*scale];
        [self addSubview:label];

    }
    return self;
}

-(void)randomize
{
    //1
    //set random rotation of the tile
    //anywhere between -0.2 and 0.3 radians
    float rotation = arc4random() % 50 / (float)100 - 0.2;
    self.transform = CGAffineTransformMakeRotation( rotation );
    
    //2
    //move randomly upwards
    int yOffset = (arc4random() % 10) - 10;
    self.center = CGPointMake(self.center.x, self.center.y + yOffset);
}


#pragma mark - dragging the tile
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.superview];
    _xOffset = pt.x - self.center.x;
    _yOffset = pt.y - self.center.y;
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.superview];
    self.center = CGPointMake(pt.x - _xOffset, pt.y - _yOffset);
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
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
