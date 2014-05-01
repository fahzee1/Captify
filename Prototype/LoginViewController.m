//
//  LoginViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "LoginViewController.h"
#import "User+Utils.h"
#import "AwesomeAPICLient.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "UIAlertView+AFNetworking.h"
#import "SSKeychain.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "UIColor+HexValue.h"
#import "MBProgressHUD.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (weak, nonatomic) IBOutlet UIButton *myLoginButton;
@property CGRect keyboardFrame;

@end


@implementation LoginViewController

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
	// Do any additional setup after loading the view
    
    //[self registerKeyboardNotif];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popToRoot)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;

    [self setupButtonAndFieldStyles];
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *password = [SSKeychain passwordForService:@"login" account:username];
    if (username){
        self.usernameField.text = username;
        [self.passwordField becomeFirstResponder];
    }
    if (password){
        self.passwordField.text = password;
        [self.passwordField becomeFirstResponder];
    }
    if (!username){
        [self.usernameField becomeFirstResponder];
    }
}

- (void)dealloc
{
    //[self unregisterKeyboardNotif];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerKeyboardNotif
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)unregisterKeyboardNotif
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    DLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    
    self.keyboardFrame = keyboardFrame;
}

- (void)popToRoot
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupButtonAndFieldStyles
{
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.usernameField.borderStyle = UITextBorderStyleNone;
    self.usernameField.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    self.usernameField.layer.opacity = 0.6f;
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Username" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.passwordField.borderStyle = UITextBorderStyleNone;
    self.passwordField.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    self.passwordField.layer.opacity = 0.6f;
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    

    self.myLoginButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.myLoginButton.layer.cornerRadius = 5;
    [self.myLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (!IS_IPHONE5){
        CGRect usernameFrame = self.usernameField.frame;
        CGRect passwordFrame = self.passwordField.frame;
        CGRect loginButtonFrame = self.myLoginButton.frame;
        
        usernameFrame.origin.y -= IPHONE4_PAD;
        passwordFrame.origin.y -= IPHONE4_PAD;
        loginButtonFrame.origin.y -= IPHONE4_PAD;
        
        self.usernameField.frame = usernameFrame;
        self.passwordField.frame = passwordFrame;
        self.myLoginButton.frame = loginButtonFrame;
    }
}



#pragma -mark Login Methods

- (IBAction)loginButton:(UIButton *)sender {
 
    // if both username and password are blank ask for username
    if ([self.usernameField.text length] == 0 && [self.passwordField.text length] == 0){
        [self alertErrorWithType:LoginAttempt
                        andField:@"username"
                      andMessage:nil];
        return;
    }
    
    // if username is present and not password, ask for password
    if (![self.usernameField.text length] == 0 && [self.passwordField.text length] == 0){
        [self alertErrorWithType:LoginAttempt
                        andField:@"password"
                      andMessage:nil];
        return;
    }
    
    // if password is present and not username, ask for username
    if (![self.passwordField.text length] == 0 && [self.usernameField.text length] == 0){
        [self alertErrorWithType:LoginAttempt
                        andField:@"username"
                      andMessage:nil];
        return;
    }
    
    [self.passwordField resignFirstResponder];
    [self loginUserIsFacebook:NO button:sender];
    
   
}


- (void)loginUserIsFacebook:(BOOL)fb
                        button:(UIButton *)sender
{
    // if we're connected to the internet, login
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Logging In", nil);
    hud.dimBackground = YES;
    hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];

    
    NSDictionary *params = @{@"username": self.usernameField.text,
                             @"password": self.passwordField.text};
    NSURLSessionDataTask *task = [User loginWithUsernameAndPassword:params
                                                           callback:^(BOOL wasSuccessful, id data, User *user, BOOL failure) {
                                                               [hud hide:YES];
                                                               if (wasSuccessful) {
                                                                   // data here will be the managed object context to pass to homeview controller
                                                                   // if needed
                                                                   // save password in keychain
                                                                   [SSKeychain setPassword:self.passwordField.text
                                                                                forService:@"login"
                                                                                   account:self.usernameField.text];
                                                                   
                                                                   
                                                                   // show home screen
                                                                   AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                                                                   UIViewController *rootVc = delegate.window.rootViewController;
                                                                   UIViewController *home;
                                                                   if ([rootVc isKindOfClass:[TWTSideMenuViewController class]]){
                                                                       home = ((TWTSideMenuViewController *)rootVc).mainViewController;
                                                                       if ([home isKindOfClass:[UINavigationController class]]){
                                                                           home = ((UINavigationController *)home).viewControllers[0];
                                                                       }
                                                                   }
                                                                   else{
                                                                       home = ((UINavigationController *)rootVc).topViewController;
                                                                   }
                                                                   if (user){
                                                                       if ([home respondsToSelector:@selector(setMyUser:)]){
                                                                           ((HomeViewController *)home).myUser = user;
                                                                       }
                                                                   }
                                                                   if ([home respondsToSelector:@selector(setGoToLogin:)]){
                                                                       ((HomeViewController *)home).goToLogin = NO;
                                                                   }
                                                                   [self.navigationController popToViewController:home animated:YES];

                                                                   
                                                                   
                                                               }
                                                               else if (!wasSuccessful && !failure){
                                                                   // user error, show alert and reshow button
                                                                   [self alertErrorWithType:LoginError
                                                                                   andField:nil
                                                                                 andMessage:[data valueForKey:@"message"]];
                                                                   sender.hidden = NO;
                                                               }
                                                               else{
                                                                   // failure alert handled by "show alertviewfortaskwitherror..
                                                                   sender.hidden = NO;
                                                               }
                                                               
                                                           }];
    // If FAILURE, show alert
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    
    // Show and start spinning activity indicator
    UIActivityIndicatorView *spinner = self.activitySpinner;
    spinner.hidden = NO;
    [spinner setAnimatingWithStateOfTask:task];
    // Hide login button
    sender.hidden = YES;
    
}



- (void)alertErrorWithType:(NSUInteger)type
                  andField:(NSString *)field
                andMessage:(NSString *)message
{
    if (type == LoginAttempt){
    NSString * message = @"Please enter your";
    if ([field  isEqual: @"username"]){
        message = [message stringByAppendingString:@" username"];
    }
    if ([field  isEqual: @"password"]){
        message = [message stringByAppendingString:@" password"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (type == LoginError) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}


#pragma -mark Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.placeholder isEqualToString:@"Enter Username"]){
        [self.passwordField becomeFirstResponder];
    }
    if ([textField.placeholder isEqualToString:@"Enter Password"]){
        [textField resignFirstResponder];
        [self loginButton:self.myLoginButton];
    }

    
    return YES;
}
@end
