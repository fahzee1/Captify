//
//  SignUpViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/19/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *myRegisterButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@end

@implementation SignUpViewController

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
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerButton:(UIButton *)sender {
    // if both username and password are blank ask for username
    if ([self.usernameField.text length] == 0 && [self.passwordField.text length] == 0){
        [self alertErrorWithType:SignUpAttempt
                        andField:@"username"
                      andMessage:nil];
        return;
    }
    
    // if username is present and not password, ask for password
    if (![self.usernameField.text length] == 0 && [self.passwordField.text length] == 0){
        [self alertErrorWithType:SignUpAttempt
                        andField:@"password"
                      andMessage:nil];
        return;
    }
    
    // if password is present and not username, ask for username
    if (![self.passwordField.text length] == 0 && [self.usernameField.text length] == 0){
        [self alertErrorWithType:SignUpAttempt
                        andField:@"username"
                      andMessage:nil];
        return;
    }
    
    // if we got a username and a password but no email, ask for email
    if ([self.emailField.text length] == 0){
        [self alertErrorWithType:SignUpAttempt
                        andField:@"email"
                      andMessage:nil];
        return;
    }
    
    [self.emailField resignFirstResponder];
    

    
}



- (void)alertErrorWithType:(NSUInteger)type
                  andField:(NSString *)field
                andMessage:(NSString *)message
{
    if (type == SignUpAttempt){
        NSString * message = @"Please enter your";
        if ([field  isEqual: @"username"]){
            message = [message stringByAppendingString:@" username"];
        }
        if ([field  isEqual: @"password"]){
            message = [message stringByAppendingString:@" password"];
        }
        if ([field  isEqual: @"email"]){
            message = [message stringByAppendingString:@" email"];
        }

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (type == SignUpError) {
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
    if ([textField.placeholder isEqualToString:@"Create a username"]){
        [self.passwordField becomeFirstResponder];
    }
    if ([textField.placeholder isEqualToString:@"Create a password"]){
        [self.emailField becomeFirstResponder];
    }
    if ([textField.placeholder isEqualToString:@"Enter email"]){
        [textField resignFirstResponder];
        [self registerButton:self.myRegisterButton];
    }
    
    
    
    return YES;
}



@end
