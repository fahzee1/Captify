//
//  UserProfileViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 5/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexValue.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"


@interface UserProfileViewController ()


@end

@implementation UserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.myUsername.text = @"";
    self.myScore.text = @"";
    
    if (self.delaySetupWithTime){
        double delayInSeconds = self.delaySetupWithTime;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self setupScreen];
        });
    }
    else{
        [self setupScreen];
    }
    
   
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.navigationItem.title = NSLocalizedString(@"Profile", nil);
    //self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popScreen)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    self.navigationController.navigationBarHidden = NO;

    
    

    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
     self.view.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupScreen
{
    if ([self.facebook_user intValue] == 1){
        [self.myProfileImage setImageWithURL:self.profileURLString
                            placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                       if (!image){
                                           DLog(@"%@",error);
                                       }
                                   }];
    }
    else{
        self.myProfileImage.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC_BIG];
    }
    
    self.myProfileImage.layer.masksToBounds = YES;
    self.myProfileImage.layer.cornerRadius = self.myProfileImage.frame.size.height/2;

    // move image up to bring down
    CGRect imageOriginal = self.myProfileImage.frame;
    CGRect newImageFrame = imageOriginal;
    newImageFrame.origin.y -= 200;
    self.myProfileImage.frame = newImageFrame;
    
    // move username down to bring up
    CGRect usernameOriginal = self.myUsername.frame;
    CGRect newUsernameFrame = usernameOriginal;
    newUsernameFrame.origin.y += 200;
    self.myUsername.frame = newUsernameFrame;
    
    // move score down to bring up
    CGRect scoreOriginal = self.myScore.frame;
    CGRect newScoreFrame = scoreOriginal;
    newScoreFrame.origin.y += 200;
    self.myScore.frame = newScoreFrame;
    
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         self.myProfileImage.frame = imageOriginal;
                     } completion:^(BOOL finished) {
                         // move up username
                         [UIView animateWithDuration:.5
                                               delay:0
                              usingSpringWithDamping:0.7
                               initialSpringVelocity:0.4
                                             options:0
                                          animations:^{
                                              self.myUsername.frame = usernameOriginal;
                                          } completion:^(BOOL finished) {
                                              // move up score
                                              [UIView animateWithDuration:.5
                                                                    delay:0
                                                   usingSpringWithDamping:0.7
                                                    initialSpringVelocity:0.4
                                                                  options:0
                                                               animations:^{
                                                                   self.myScore.frame = scoreOriginal;
                                                               } completion:nil];
                                          }];
                         
                     }];
    
    
    self.myScore.text = self.scoreString;
    self.myUsername.text = [[self.usernameString stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    self.myScore.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.myScore.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:18];
    self.myUsername.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.myUsername.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:18];
    
    

}

@end
