//
//  SignUpViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/19/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SignUpViewController.h"
#import "AwesomeAPICLient.h"
#import "User+Utils.h"
#import "UIAlertView+AFNetworking.h"
#import "UIActivityIndicatorView+AFNetworking.h"
#import "SSKeychain.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "UIColor+HexValue.h"
#import "MBProgressHUD.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "PhoneNumberViewController.h"

#define usernamePlaceholder @"Create Username"
#define passwordPlaceholder @"Create Password"
#define emailPlaceholder @"Enter Email"

@interface SignUpViewController ()<UITextFieldDelegate,PhoneNumberDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
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
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popToRoot)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-right"] style:UIBarButtonItemStylePlain target:self action:@selector(checkB4Register)];
    [rightButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;

    
    [self setupButtonAndFieldStyles];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
    [self.usernameField becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:NO];
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;
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
       DLog(@"received memory warning here");
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
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:usernamePlaceholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.passwordField.borderStyle = UITextBorderStyleNone;
    self.passwordField.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    self.passwordField.layer.opacity = 0.6f;
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:passwordPlaceholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.emailField.borderStyle = UITextBorderStyleNone;
    self.emailField.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    self.emailField.layer.opacity = 0.6f;
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:emailPlaceholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    

    
    if (!IS_IPHONE5){
        CGRect usernameFrame = self.usernameField.frame;
        CGRect passwordFrame = self.passwordField.frame;
        CGRect emailFieldFrame = self.emailField.frame;
        
        usernameFrame.origin.y -= IPHONE4_PAD;
        passwordFrame.origin.y -= IPHONE4_PAD;
        emailFieldFrame.origin.y -= IPHONE4_PAD;
        
        self.usernameField.frame = usernameFrame;
        self.passwordField.frame = passwordFrame;
        self.emailField.frame = emailFieldFrame;
    }
     

}




- (void)showPhoneNumberScreen
{
    UIViewController *phoneRoot = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneNumberRoot"];
    if ([phoneRoot isKindOfClass:[UINavigationController class]]){
        UIViewController *phoneScreen = ((UINavigationController *)phoneRoot).topViewController;
        if ([phoneScreen isKindOfClass:[PhoneNumberViewController class]]){
            ((PhoneNumberViewController *) phoneScreen).delegate = self;
            [self presentViewController:phoneRoot animated:YES completion:nil];
        }
    }
}




- (void)checkB4Register
{
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
    [self showPhoneNumberScreen];


}


- (void)registerUserIsFacebook:(BOOL)fb
                   phoneNumber:(NSString *)number
{
    NSMutableDictionary *params = [@{@"username": self.usernameField.text,
                             @"password": self.passwordField.text,
                             @"email": self.emailField.text} mutableCopy];
    
    if (number){
        params[@"phone_number"] = number;
    }
    
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Signing In", nil);
    hud.dimBackground = YES;
    hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    
    NSURLSessionDataTask *task = [User registerWithParams:params
                                                 callback:^(BOOL wasSuccessful, id data, User *user, BOOL failure) {
                                                     [hud hide:YES];
                                                     if (wasSuccessful){
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
                                                         if(user){
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
                                                         [self alertErrorWithType:SignUpError
                                                                         andField:nil
                                                                       andMessage:[data valueForKey:@"message"]];
                                                         
                                                     }
                                                     
                                                 }];
    // If FAILURE, show alert
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    

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
    if ([textField.placeholder isEqualToString:usernamePlaceholder]){
        [self.passwordField becomeFirstResponder];
    }
    
    if ([textField.placeholder isEqualToString:passwordPlaceholder]){
        [self.emailField becomeFirstResponder];
    }
    
    if ([textField.placeholder isEqualToString:emailPlaceholder]){
        [textField resignFirstResponder];
        [self checkB4Register];
    }
    
    
    
    
    return YES;
}

#pragma -mark PhoneController Delegate

- (void)phoneNumberControllerDidTapCancel:(PhoneNumberViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self registerUserIsFacebook:NO
                         phoneNumber:nil];
    }];
}

- (void)phoneNumberControllerDidTapSave:(PhoneNumberViewController *)controller
{
    NSString *phoneNumber = controller.phoneNumber;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self registerUserIsFacebook:NO
                         phoneNumber:phoneNumber];
    }];
}

@end
