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


@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (weak, nonatomic) IBOutlet UIButton *myLoginButton;

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
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *password = [SSKeychain passwordForService:@"login" account:username];
    if (username){
        self.usernameField.text = username;
    }
    if (password){
        self.passwordField.text = password;
    }
    if (!username){
        [self.usernameField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // if we're connected to the internet, login
    if ([[AwesomeAPICLient sharedClient] connected]){
        NSDictionary *params = @{@"username": self.usernameField.text,
                                 @"password": self.passwordField.text};
        NSURLSessionDataTask *task = [User loginWithUsernameAndPassword:params
                                                           callback:^(BOOL wasSuccessful, id data, BOOL failure) {
                                                               if (wasSuccessful) {
                                                                   // save password in keychain
                                                                [SSKeychain setPassword:self.passwordField.text
                                                                             forService:@"login"
                                                                                account:self.usernameField.text];
                                                                
                                                                   // show home screen
                                                                   [self performSegueWithIdentifier:@"unWindToHomeID" sender:self];
                                                            
                                                                   
                                                               }
                                                               else if (!wasSuccessful && !failure){
                                                                   // user error, show alert and reshow button
                                                                   [self alertErrorWithType:LoginError
                                                                                   andField:nil
                                                                                 andMessage:[data valueForKey:@"message"]];
                                                                   sender.hidden = NO;
                                                               }
                                                               else{
                                                                   // failure, reshow button
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
    
    // if no internet connection, alert no connection
    }else{
        [self alertErrorWithType:LoginError andField:nil andMessage:@"No internet connection!"];
    }

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
    if ([textField.placeholder isEqualToString:@"Username"]){
        [self.passwordField becomeFirstResponder];
    }
    if ([textField.placeholder isEqualToString:@"Password"]){
        [textField resignFirstResponder];
        [self loginButton:self.myLoginButton];
    }
    

    
    return YES;
}
@end
