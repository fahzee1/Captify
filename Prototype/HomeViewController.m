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

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

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
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    //if user not logged in segue to login screen
       if (![[NSUserDefaults standardUserDefaults] valueForKey:@"logged"]){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
       }else{
           self.username.text = self.myUser.username;
           self.score.text = [self.myUser.score stringValue];
           [User getFacebookPicWithUser:self.myUser
                              imageview:self.profileImage];
    
       }
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
