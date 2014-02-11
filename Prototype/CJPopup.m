//
//  CJPopup.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/10/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "CJPopup.h"
#import "GPUImage.h"

@interface CJPopup()

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) NSArray *errorWords;
@property(nonatomic, strong) NSArray *successWords;
@property(nonatomic, strong) NSArray *failWords;
@property GPUImageiOSBlurFilter *blurFilter;

@end

@implementation CJPopup


- (void)showClear
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor clearColor];
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
}

- (void)showErrorRed
{
    self.errorWords = [NSArray arrayWithObjects:@"Almost!",@"Wrong!",@"C'MON!",@"Nope!",@"Try Again!", nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor redColor];
    self.window.alpha = 0.7;
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    CGPoint labelLocation = CGPointZero;
    int random = arc4random() % [self.errorWords count];
    NSString *randomText = self.errorWords[random];
    if ([randomText length] >= 7){
        labelLocation = CGPointMake(85, 200);
    }
    if ([randomText length] <= 6){
        labelLocation = CGPointMake(100, 200);
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelLocation.x,labelLocation.y, 200, 100)];
    //label.center = self.center;
    label.text = randomText;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:35];

    
    
    [self addSubview:label];
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(hide)
                                   userInfo:nil
                                    repeats:NO];
    
}


- (void) showSuccessBlurWithImage:(UIImage *)image
{
    self.successWords = [NSArray arrayWithObjects:@"You Got It!",@"Work Son!",@"Bang! Bang!",nil];
    self.blurFilter = [GPUImageiOSBlurFilter new];
    self.blurFilter.blurRadiusInPixels = 4.0f;
    UIImage *blurredImage = [self.blurFilter imageByFilteringImage:image];
    UIImageView *bIV = [[UIImageView alloc] initWithImage:blurredImage];
    bIV.frame = [UIScreen mainScreen].bounds;
    bIV.userInteractionEnabled = YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60,-100, 200, 100)];
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    homeButton.frame = CGRectMake(60, [UIScreen mainScreen].bounds.size.height, 200, 200);
    
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                          label.frame = CGRectMake(60, 100, 200, 100);
        
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:0
                              usingSpringWithDamping:0.5
                               initialSpringVelocity:0.5
                                             options:0
                                          animations:^{
                                              homeButton.frame = CGRectMake(60, [UIScreen mainScreen].bounds.size.height -150, 200, 200);
                                          } completion:nil];
                     }];
    
    
    
    [homeButton setTitle:@"Go Home" forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    int random = arc4random() % [self.successWords count];
    NSString *randomText = self.successWords[random];
    label.text = randomText;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor yellowColor];
    label.font = [UIFont boldSystemFontOfSize:35];
    [bIV addSubview:label];
    [bIV addSubview:homeButton];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor clearColor];
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    [self addSubview:bIV];
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    



}


- (void)showFailBlurWithImage:(UIImage *)image
{
    self.failWords = [NSArray arrayWithObjects:@"Boo Hoo!",@"That Stunk!",@"Maybe Next Time!",@"So Close", nil];
    self.blurFilter = [GPUImageiOSBlurFilter new];
    self.blurFilter.blurRadiusInPixels = 4.0f;
    UIImage *blurredImage = [self.blurFilter imageByFilteringImage:image];
    UIImageView *bIV = [[UIImageView alloc] initWithImage:blurredImage];
    bIV.frame = [UIScreen mainScreen].bounds;
    bIV.userInteractionEnabled = YES;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60,-100, 300, 100)];
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    homeButton.frame = CGRectMake(60, [UIScreen mainScreen].bounds.size.height, 200, 200);
    
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         label.frame = CGRectMake(60, 100, 300, 100);
                         
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:0
                              usingSpringWithDamping:0.5
                               initialSpringVelocity:0.5
                                             options:0
                                          animations:^{
                                              homeButton.frame = CGRectMake(60, [UIScreen mainScreen].bounds.size.height -150, 200, 200);
                                          } completion:nil];
                     }];
    
    
    
    [homeButton setTitle:@"Go Home" forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    int random = arc4random() % [self.failWords count];
    NSString *randomText = self.failWords[random];
    label.text = randomText;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor redColor];
    label.font = [UIFont boldSystemFontOfSize:30];
    [bIV addSubview:label];
    [bIV addSubview:homeButton];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor clearColor];
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    [self addSubview:bIV];
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    


    
}

- (void)hide
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.window.alpha = 0;
                     } completion:^(BOOL finished) {
                         self.window.hidden =YES;
                         self.window = nil;
                     }];

}


- (void)buttonTapped:(UIButton *)sender
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(userDidClickDoneButtonFromPopup:)]){
            [self.delegate userDidClickDoneButtonFromPopup:self];
        }
    }
}
/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
