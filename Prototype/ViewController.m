//
//  ViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/2/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "User+Utils.h"
#import "HomeViewController.h"
#import "AwesomeAPICLient.h"
#import "UIAlertView+AFNetworking.h"
#import "UIColor+HexValue.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtonStyles];
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupButtonStyles
{
    //self.challengeNameLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    
    self.loginButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#1abc9c"] CGColor];
    self.loginButton.layer.cornerRadius = 5;
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.registerButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#f1c40f"] CGColor];
    self.registerButton.layer.cornerRadius = 5;
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    
}

- (IBAction)facebookLogin:(UIButton *)sender {
    // if the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
        //close the session and remove the access token from the cache.
        //the session state handler in the app delegate will be called automatically
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:@"fbServerSuccess"]){
            [defaults setBool:NO forKey:@"fbServerSuccess"];
            [self showHomeScreen:nil];
        }
        else{
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self alertErrorWithTitle:nil message:nil];
        }
        
        
        //if the session state is not any of the two "open" states when the button is clicked
    }else{
        //open a sessiom showing user the login UI
        //must ALWAYS ask for basic_info when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_friends",@"user_photos"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          //get app delegate
                                          AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                                          //call the app delegates session changed method
                                          [appDelegate sessionStateChanged:session state:status error:error];
                                          
                                          //get username
                                          [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                              if (!error){
                                                  NSLog(@"%@",result);
                                                  NSNumber *fbookId = [result valueForKey:@"id"];
                                                  NSString *fbookName = [result valueForKey:@"username"];
                                                  NSString *fbookEmail = [result valueForKey:@"email"];
                                                  NSString *password = [[NSUUID UUID] UUIDString];
                                                  NSString *fbookFirstName = [result valueForKey:@"first_name"];
                                                  NSString *fbookLastName = [result valueForKey:@"last_name"];
                                                  NSDictionary *parms = @{@"username": fbookName,
                                                                          @"email":fbookEmail,
                                                                          @"password":password,
                                                                          @"fbook_id":fbookId,
                                                                          @"first_name":fbookFirstName,
                                                                          @"last_name":fbookLastName,
                                                                          @"fbook_user":[NSNumber numberWithBool:YES]};
                                                  
                                                  
                                                // show homescreen call back handled in delegate
                                                NSURLSessionDataTask *task = [User registerFacebookWithParams:parms callback:^(BOOL wasSuccessful, id data, User *user, BOOL failure) {
                                                          
                                                          if (wasSuccessful){
                                                              NSLog(@"hit22");
                                                              [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged"];
                                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                                              [self showHomeScreen:user];
                                                          }
                                                          else{
                                                              [self alertErrorWithTitle:nil message:nil];
                                                          }
                                                          
                                                      }];

                                                // If FAILURE, show alert
                                                [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
            
                                                }
                                            }];
                                      }];
    }
    
}

- (void)alertErrorWithTitle:(NSString *)title
                    message:(NSString *)message
{
    if (!title){
        title = @"Oops!";
    }
    
    if (!message){
        message = @"Can't connect to the server. Try again.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];

}

- (void)showHomeScreen:(User *)user
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UIViewController *rootVc = (UINavigationController *)delegate.window.rootViewController;
    UIViewController *home;
    
    if ([rootVc isKindOfClass:[TWTSideMenuViewController class]]){
        home = ((TWTSideMenuViewController *)rootVc).mainViewController;
        if ([home isKindOfClass:[UINavigationController class]]){
            home.navigationController.navigationBarHidden = NO;
            home = ((UINavigationController *)home).viewControllers[0];
            }
        
    }
    else{
        home = ((UINavigationController *)rootVc).topViewController;
    }
    if (user){
        if ([home respondsToSelector:@selector(setMyUser:)]){
            ((HomeViewController *)home).myUser = user;
            ((HomeViewController *)home).goToLogin = NO;
        }
    }
    if (self.navigationController){
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popToViewController:home animated:YES];
    }
    else{
        NSLog(@"no navigation");
    }
}

@end
