//
//  HomeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "User+Utils.h"
#import <FacebookSDK/FacebookSDK.h>

@interface HomeViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property BOOL fullScreen;
@property CGRect firstFrame;
@property UITapGestureRecognizer *tap;
@end

@implementation HomeViewController

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
    self.fullScreen = NO;
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeFullScreen)];
    self.tap.delegate = self;
    [self.tap setNumberOfTapsRequired:1];
    [self.profileImage addGestureRecognizer:self.tap];
    self.profileImage.userInteractionEnabled =YES;
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    //if user not logged in segue to login screen
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"logged"]){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"logged"]){
        self.username.text = self.myUser.username;
        self.score.text = [self.myUser.score stringValue];
        [User getFacebookPicWithUser:self.myUser
                           imageview:self.profileImage];
    }
    
    if (self.showResults){
        if ([self isKindOfClass:[UINavigationController class]]){
            [self performSegueWithIdentifier:@"segueToResults" sender:self];
        }
        else{
            NSLog(@"not a navigation controller");
        }
    }
}


- (void)makeFullScreen
{
    if (!self.fullScreen){
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             self.firstFrame = self.profileImage.frame;
                             [self.profileImage setFrame:[[UIScreen mainScreen] bounds]];
                            
                         } completion:^(BOOL finished) {
                             self.fullScreen = YES;
                         }];
        return;
    }
    else{
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             [self.profileImage setFrame:self.firstFrame];
                         } completion:^(BOOL finished) {
                             self.fullScreen = NO;
                         }];
        return;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL should = YES;
    if (gestureRecognizer == self.tap){
        should = (touch.view == self.profileImage);
        
    }
    return should;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logout:(UIButton *)sender {
    self.myUser = nil;
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
        //close the session and remove the access token from the cache.
        //the session state handler in the app delegate will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }

    [self performSegueWithIdentifier:@"segueToLogin" sender:self];
}


#pragma -mark Segues
- (IBAction)unwindToHomeController:(UIStoryboardSegue *)segue
{    
}

@end
