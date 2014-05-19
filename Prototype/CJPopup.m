//
//  CJPopup.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/10/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "CJPopup.h"
#import "GPUImage.h"
#import "UIColor+HexValue.h"
#import "MBProgressHUD.h"

@interface CJPopup()

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, strong) NSArray *errorWords;
@property(nonatomic, strong) NSArray *successWords;
@property(nonatomic, strong) NSArray *failWords;
@property GPUImageiOSBlurFilter *blurFilter;

@end
/*
 Fonts i like
 
 label.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:35];
 label.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:35];
 label.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:35];
 label.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:35];
 
 */

@implementation CJPopup


- (void)showClear
{
    // Most basic pop over. Use to show UI element without background

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor clearColor];
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
}

- (void)showBlackActivityWithMessage:(NSString *)message
{
    // Most basic pop over. Use to show UI element without background
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(message, nil);

    
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
}


- (void)showErrorRed
{
    // Error pop over used when user chooses incorrect answer.
    // Shows full screen with random error text for 1 second then disappears
    
    self.errorWords = [NSArray arrayWithObjects:@"Almost!",@"Wrong!",@"C'MON!",@"Nope!",@"Try Again!", nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor redColor];
    self.window.alpha = 0.7;
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    // dynamic positioning based on text length
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
    label.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:35];
    [self addSubview:label];
    
    
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
    // wait 1 second to hide the window
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(hide)
                                   userInfo:nil
                                    repeats:NO];
    
}


- (void) showSuccessBlurWithImage:(UIImage *)image
{
    // Blurred image pop over that shows when user correctly answers challenge
    // Shows random success text and adds button to click home
    
    self.successWords = [NSArray arrayWithObjects:@"You Got It!",@"Work Son!",@"Bang! Bang!", @"Ohh Kill Em!",@"Make It Rain!",nil];
    self.blurFilter = [GPUImageiOSBlurFilter new];
    self.blurFilter.blurRadiusInPixels = 1.0f;
    UIImage *blurredImage = [self.blurFilter imageByFilteringImage:image];
    UIImageView *bIV = [[UIImageView alloc] initWithImage:blurredImage];
    bIV.frame = [UIScreen mainScreen].bounds;
    bIV.userInteractionEnabled = YES;
    
    // dynamic positioning based on text length and spaces
    CGPoint labelLocation = CGPointZero;
    int random = arc4random() % [self.successWords count];
    NSString *randomText = self.successWords[random];
    NSRange whiteSpace = [randomText rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([randomText length] <= 7){
        if (whiteSpace.location != NSNotFound) {
            labelLocation = CGPointMake(75, -100);
        }
        else{
            labelLocation = CGPointMake(70, -100);
        }
    }
    
    if ([randomText length] > 7 && [randomText length] < 10){
        if (whiteSpace.location != NSNotFound) {
            labelLocation = CGPointMake(65, -100);
        }
        else{
            labelLocation = CGPointMake(85, -100);
        }
        
    }
    
    if ([randomText length] >= 10){
        if (whiteSpace.location != NSNotFound) {
            labelLocation = CGPointMake(30, -100);
        }
        else{
            labelLocation = CGPointMake(35, -100);
        }
        
    }

    // place label and homebutton offscreen
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelLocation.x,labelLocation.y, 500, 100)];
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    homeButton.frame = CGRectMake(60, [UIScreen mainScreen].bounds.size.height, 200, 200);
    
    // animate the buttons onscreen with bounce
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                          label.frame = CGRectMake(labelLocation.x, 100, 500, 100);
        
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

    label.text = randomText;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHexString:@"#ecf0f1"];
    label.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:35];
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

- (void) showSuccessBlur2WithImage:(UIImage *)image sender:(NSString *)sender
{
    sender = [[sender stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    self.blurFilter = [GPUImageiOSBlurFilter new];
    self.blurFilter.blurRadiusInPixels = 1.0f;
    UIImage *blurredImage = [self.blurFilter imageByFilteringImage:image];
    UIImageView *bIV = [[UIImageView alloc] initWithImage:blurredImage];
    bIV.frame = [UIScreen mainScreen].bounds;
    bIV.userInteractionEnabled = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelAlert;
    self.window.backgroundColor = [UIColor clearColor];
    
    self.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    
    UILabel *title = [[UILabel alloc] init];
    title.text = NSLocalizedString(@"Success", nil);
    title.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:50];
    title.frame = CGRectMake(60, 50, 300, 100);
    title.textColor = [UIColor whiteColor];
    
    
    UILabel *message = [[UILabel alloc] init];
    message.text = [NSString stringWithFormat:@"%@ %@",sender,NSLocalizedString(@"selected your caption!", nil)];
    message.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:35];
    message.frame = CGRectMake(30, 200, 300, 300);
    message.numberOfLines = 0;
    [message sizeToFit];
    message.textColor = [UIColor whiteColor];

    [bIV addSubview:message];
    [bIV addSubview:title];
    [self addSubview:bIV];
    
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
    [self vibrate];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hide];
    });


}



- (void)showFailBlurWithImage:(UIImage *)image
{
    // Blurred image pop over that shows when user failed to answer challenge
    // and exhausted 3 attempts.
    // Shows random fail text and adds button to click home

    self.failWords = [NSArray arrayWithObjects:@"Boo Hoo!",@"That Stunk!",@"Bye Felicia!",@"So Close... Not!",@"Pitiful!",@"Or Nah!", @"How About No!", nil];

    self.blurFilter = [GPUImageiOSBlurFilter new];
    self.blurFilter.blurRadiusInPixels = 4.0f;
    UIImage *blurredImage = [self.blurFilter imageByFilteringImage:image];
    UIImageView *bIV = [[UIImageView alloc] initWithImage:blurredImage];
    bIV.frame = [UIScreen mainScreen].bounds;
    bIV.userInteractionEnabled = YES;
    
    // dynamic positioning based on text length and spaces
    CGPoint labelLocation = CGPointZero;
    int random = arc4random() % [self.failWords count];
    NSString *randomText = self.failWords[random];
    NSRange whiteSpace = [randomText rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([randomText length] <= 7){
        if (whiteSpace.location != NSNotFound) {
              labelLocation = CGPointMake(75, -100);
        }
        else{
             labelLocation = CGPointMake(70, -100);
        }
    }

    if ([randomText length] > 7 && [randomText length] < 10){
        if (whiteSpace.location != NSNotFound) {
            labelLocation = CGPointMake(65, -100);
        }
        else{
            labelLocation = CGPointMake(85, -100);
        }

    }
    
    if ([randomText length] >= 10){
        if (whiteSpace.location != NSNotFound) {
            labelLocation = CGPointMake(30, -100);
        }
        else{
            labelLocation = CGPointMake(35, -100);
        }

    }
    
    // place both buttons offscreen
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelLocation.x,labelLocation.y, 300, 100)];
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    homeButton.frame = CGRectMake(60, [UIScreen mainScreen].bounds.size.height, 200, 200);
    
    // animate them on screen with bounce
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         label.frame = CGRectMake(labelLocation.x, 100, 300, 100);
                         
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
  
    label.text = randomText;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHexString:@"#e74c3c"];
    label.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:35];
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

- (void) hideNoAnimation
{
    self.window.hidden =YES;
    self.window = nil;
}


- (void)buttonTapped:(UIButton *)sender
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(userDidClickDoneButtonFromPopup:)]){
            [self.delegate userDidClickDoneButtonFromPopup:self];
        }
    }
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
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
