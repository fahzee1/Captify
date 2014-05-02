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
#import "CJPopup.h"
#import "MBProgressHUD.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   // DLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    [self setupButtonStyles];
    
    
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    
    /*
    for (NSString* family in [UIFont familyNames])
    {
        DLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            DLog(@"  %@", name);
        }
    }
     */
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
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.loginButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.loginButton.layer.cornerRadius = 5;
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.registerButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    self.registerButton.layer.cornerRadius = 5;
    [self.registerButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
    
    if (!IS_IPHONE5){
        CGRect facebookFrame = self.facebookButton.frame;
        CGRect loginFrame = self.loginButton.frame;
        CGRect registerFrame = self.registerButton.frame;
        
        facebookFrame.origin.y -= IPHONE4_PAD;
        loginFrame.origin.y -= IPHONE4_PAD;
        registerFrame.origin.y -= IPHONE4_PAD;
        
        self.facebookButton.frame = facebookFrame;
        self.loginButton.frame = loginFrame;
        self.registerButton.frame = registerFrame;
    }

    
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
        
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"Logging In", nil);
        hud.dimBackground = YES;
        hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];

        
        //open a sessiom showing user the login UI
        //must ALWAYS ask for basic_info when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info",@"user_friends",@"user_photos",@"email"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          //get app delegate
                                          AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                                          //call the app delegates session changed method
                                          [appDelegate sessionStateChanged:session state:status error:error];
                                          
                                          //get username
                                          [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                              [hud hide:YES];
                                              if (!error){
                                                  DLog(@"%@",result);
                                                  NSNumber *fbookId;
                                                  //NSString *fbookName = [result valueForKey:@"username"];
                                                  NSString *fbookEmail;
                                                  NSString *password;
                                                  NSString *fbookFirstName;
                                                  NSString *fbookLastName;
                                                  NSString *fbookUsername;
                                                  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
                                                  @try {
                                                      fbookId = [result valueForKey:@"id"];
                                                      //fbookName = [result valueForKey:@"username"];
                                                      password = [[NSUUID UUID] UUIDString];
                                                      fbookFirstName = [result valueForKey:@"first_name"];
                                                      fbookLastName = [result valueForKey:@"last_name"];
                                                      fbookUsername = [NSString stringWithFormat:@"%@-%@",fbookFirstName,fbookLastName];
                                                       fbookEmail = [result valueForKey:@"email"];

                                                  }
                                                  @catch (NSException *exception) {
                                                      DLog(@"%@",exception);
                                                      if (!fbookEmail){
                                                          fbookEmail = [NSString stringWithFormat:@"%@@facebook.com",fbookUsername];
                                                      }
                                                  }
                                                  @finally {
                                                      if (fbookUsername){
                                                          params[@"username"] = fbookUsername;
                                                      }
                                                      if (fbookEmail){
                                                          params[@"email"] = fbookEmail;
                                                      }
                                                      
                                                      if (password){
                                                          params[@"password"] = password;
                                                      }
                                                      
                                                      if (fbookId){
                                                          params[@"fbook_id"] = fbookId;
                                                      }
                                                      
                                                      if (fbookFirstName){
                                                          params[@"first_name"] = fbookFirstName;
                                                      }
                                                      
                                                      if (fbookLastName){
                                                          params[@"last_name"] = fbookLastName;
                                                      }
                                                      
                                                      params[@"fbook_user"] = [NSNumber numberWithBool:YES];
                                                  }
                                                  
                                                  DLog(@"%@",params);
                                                  DLog(@"%lu",(unsigned long)[params count]);
        
                                                  
                                                // show homescreen call back handled in delegate
                                                NSURLSessionDataTask *task = [User registerFacebookWithParams:params callback:^(BOOL wasSuccessful, id data, User *user, BOOL failure) {
                                                    
                                                    [hud hide:YES];
                                                    if (wasSuccessful){
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
        //self.navigationController.navigationBarHidden = NO;
        [self.navigationController popToViewController:home animated:YES];
        
    }
    else{
        DLog(@"no navigation");
    }
}


-(void)fbResync
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) ){
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0])){
            
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    
                }
            }];
        }
    }
}

@end
