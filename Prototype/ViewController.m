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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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


- (IBAction)facebookLogin:(UIButton *)sender {
    // if the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
        //close the session and remove the access token from the cache.
        //the session state handler in the app delegate will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
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
                                                  [User registerFacebookWithParams:parms callback:^(BOOL wasSuccessful, id data, User *user, BOOL failure) {
                                                      if (wasSuccessful){
                                                          AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                                                          HomeViewController *vc = (HomeViewController *)delegate.window.rootViewController;
                                                          if (user){
                                                              if ([vc respondsToSelector:@selector(setMyUser:)]){
                                                              vc.myUser = user;
                                                              }
                                                          }
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }
                                                  }];
                                                }
                                            }];
                                      }];
    }
    
}

@end
