//
//  SettingsEditViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 6/9/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SettingsEditViewController.h"
#import "UIColor+HexValue.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"


#define SETTINGS_PHONE_DEFAULT @"No # provided"
#define SETTINGS_EMAIL_DEFAULT @"No email provided"

@interface SettingsEditViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;

@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UITextField *phoneField;


@end

@implementation SettingsEditViewController

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
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] style:UIBarButtonItemStylePlain target:self action:@selector(closeEditScreen)];
    
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] style:UIBarButtonItemStylePlain target:self action:@selector(submitEditScreen)];
    
    [rightButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;

    self.navigationItem.rightBarButtonItem = rightButton;
    
    

    
    self.view.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupData];
    [self setupStyles];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
    if (!IS_IPHONE5){
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupStyles
{
    self.usernameField.textColor = [UIColor whiteColor];
    self.emailField.textColor = [UIColor whiteColor];
    self.phoneField.textColor = [UIColor whiteColor];
    
    self.usernameField.borderStyle = UITextBorderStyleNone;
    self.emailField.borderStyle = UITextBorderStyleNone;
    self.phoneField.borderStyle = UITextBorderStyleNone;
    
    self.usernameLabel.textColor = [UIColor whiteColor];
    self.phoneLabel.textColor = [UIColor whiteColor];
    self.emailLabel.textColor = [UIColor whiteColor];
    
    self.usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    self.emailLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    self.phoneLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
}

- (void)setupData
{
    self.usernameField.delegate = self;
    self.phoneField.delegate = self;
    self.emailField.delegate = self;
    
    self.usernameField.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.phoneField.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.emailField.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.usernameField.layer.cornerRadius = 4;
    self.phoneField.layer.cornerRadius = 4;
    self.emailField.layer.cornerRadius = 4;
    
    self.usernameField.text = self.myUser.username;
    self.phoneField.text = self.myUser.phone_number ? self.myUser.phone_number:SETTINGS_PHONE_DEFAULT;
    self.emailField.text = self.myUser.email ? self.myUser.email:SETTINGS_EMAIL_DEFAULT;
    

    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"facebook_user"]){
        self.usernameField.userInteractionEnabled = NO;
        self.usernameField.text = NSLocalizedString(@"Not allowed (Facebook)", nil);
    }
    
    if (!IS_IPHONE5){
        self.scrollView.contentSize = CGSizeMake(280, 420);
        
    }

    

}

- (void)closeEditScreen
{
    //MZFormSheetController *controller = self.formSheetController;
    [self.controller dismissAnimated:YES completionHandler:nil];
    
}

- (void)submitEditScreen
{
    UITextField *field;
    
    if (self.usernameField.isFirstResponder){
        field = self.usernameField;
    }
    else if (self.emailField.isFirstResponder){
        field = self.emailField;
    }
    
    else if (self.phoneField.isFirstResponder){
        field = self.phoneField;
    }
    
    [self textFieldShouldReturn:field];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Updating", nil);
    hud.dimBackground = YES;
    hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    hud.color = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.8];
    
    NSString *name = self.usernameField.text;
    NSString *phone = self.phoneField.text;
    NSString *email = self.emailField.text;
    
    
    BOOL change = NO;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"facebook_user"]){
        if (![name isEqualToString:self.myUser.username]){
            change = YES;
        }
    }
    
    if (![phone isEqualToString:self.myUser.phone_number] && ![phone isEqualToString:SETTINGS_PHONE_DEFAULT]){
        change = YES;
    }
    
    if (![email isEqualToString:self.myUser.email]){
        change = YES;
    }
    
    
    if (change){
        NSDictionary *params = @{@"username": self.myUser.username,
                                 @"new_username": name,
                                 @"phone": phone,
                                 @"email": email};
        
        [User sendProfileUpdatewithParams:params
                                    block:^(BOOL wasSuccessful, id data, NSString *message) {
                                        [hud hide:YES];
                                        if (wasSuccessful){
                                            int changes = [[data valueForKey:@"changes"] intValue];
                                            if (changes){
                                                self.myUser.username = data[@"username"];
                                                self.myUser.email = data[@"email"];
                                                self.myUser.phone_number = data[@"phone"];
                                                
                                                
                                                NSString *apiString = [NSString stringWithFormat:@"ApiKey %@:%@",data[@"username"],[[NSUserDefaults standardUserDefaults] valueForKey:@"api_key" ]];
                                                [[NSUserDefaults standardUserDefaults] setValue:apiString forKey:@"apiString"];
                                                [[NSUserDefaults standardUserDefaults] setValue:data[@"username"] forKey:@"username"];
                                                
                                                dispatch_queue_t settingsQueue = dispatch_queue_create("com.Captify.Settings", NULL);
                                                dispatch_async(settingsQueue, ^{
                                                    NSError *e;
                                                    if (![self.myUser.managedObjectContext save:&e]){
                                                        DLog(@"%@",e);
                                                    }
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self.myTable reloadData];
                                                        [self closeEditScreen];
                                                    });
                                                    
                                                });
                                                
                                                
                                            }
                                            // no changes
                                            else{
                                                [self closeEditScreen];
                                            }
                                        }
                                        // not successful
                                        else{
                                            
                                            [self closeEditScreen];
                                            [self showAlertWithTitle:@"Error" message:message];
                                        }
                                    }];
    }
    // no changes
    else{
        [hud hide:YES];
        [self closeEditScreen];
    }
    
    return YES;
}


- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    UIAlertView *a = [[UIAlertView alloc]
                      initWithTitle:title
                      message:message
                      delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    [a show];
}



- (User *)myUser
{
    if (!_myUser){
        NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
        NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
        if (uri){
            NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
            NSError *error;
            _myUser = (id) [context existingObjectWithID:superuserID error:&error];
        }
        
    }
    return _myUser;
}


@end
