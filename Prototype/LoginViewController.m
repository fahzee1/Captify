//
//  LoginViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "LoginViewController.h"
#import "AwesomeAPICLient.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

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
    self.passwordField.secureTextEntry = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark Login Methods

- (IBAction)loginButton:(UIButton *)sender {
 
    // if both username and password are blank ask for username
    if ([self.usernameField.text length] == 0 && ([self.passwordField.text length] == 0)){
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
    
    [[AwesomeAPICLient sharedClient] loginWithUsername:self.usernameField.text
                                              password:self.passwordField.text
                                          withCallback:^(BOOL wasSuccessful, id data) {
                                              if (wasSuccessful){
                                                  NSLog(@"success %@", data);
                                                  // open to show home screen
            
                                              }else{
                                                  NSLog(@"error %@", data);
                                                  [self alertErrorWithType:LoginError
                                                                  andField:nil andMessage:[data valueForKey:@"message"]];
                                                }
                                          }];
    

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


@end
