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
    
    self.myScore.text = self.scoreString;
    self.myUsername.text = [[self.usernameString stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    self.myScore.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.myScore.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:18];
    self.myUsername.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.myUsername.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:18];
    
    
    self.view.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
    //self.view.backgroundColor = [UIColor whiteColor];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
