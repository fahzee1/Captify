//
//  SettingsViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/13/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SettingsViewController.h"
#import "TWTSideMenuViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "HomeViewController.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import <MessageUI/MessageUI.h>
#import "User+Utils.h"
#import "AppDelegate.h"
#import "AwesomeAPICLient.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "MenuViewController.h"

@interface SettingsViewController ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,UITextFieldDelegate,TWTSideMenuViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) User *myUser;

@property (weak, nonatomic) IBOutlet UITextField *editUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *editEmailField;

@property (weak, nonatomic) IBOutlet UIButton *editDoneButton;
@property (weak, nonatomic) IBOutlet UITextField *editPhoneField;
@property (strong, nonatomic) IBOutlet UIView *editView;

@property (strong, nonatomic) UIView *editScreen;

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myTable.delegate = self;
    self.myTable.dataSource = self;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = button;
    
    self.sideMenuViewController.delegate = self;
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);
  }


- (void)viewDidAppear:(BOOL)animated
{
    [self.editUsernameField resignFirstResponder];
    [self.editEmailField resignFirstResponder];
    [self.editPhoneField resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}


- (void)slideDownKeyboard
{
    [self.editUsernameField resignFirstResponder];
    [self.editEmailField resignFirstResponder];
    [self.editPhoneField resignFirstResponder];
    
}


- (void)setupEditScreen
{
    self.editView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    
    self.editUsernameField.delegate = self;
    self.editPhoneField.delegate = self;
    self.editEmailField.delegate = self;
    
    self.editUsernameField.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.editPhoneField.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.editEmailField.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.editUsernameField.layer.cornerRadius = 4;
    self.editPhoneField.layer.cornerRadius = 4;
    self.editEmailField.layer.cornerRadius = 4;
    
    self.editUsernameField.text = self.myUser.username;
    self.editPhoneField.text = self.myUser.phone_number ? self.myUser.phone_number:@"No # provided";
    self.editEmailField.text = self.myUser.email;
    
    self.editDoneButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.editDoneButton.layer.cornerRadius = 10;

    
    [self.view addSubview:self.editScreen];


}

- (void)showEditScreen
{
    self.editScreen.frame = CGRectMake(7, 0, self.editScreen.frame.size.width, self.editScreen.frame.size.height);
    [self setupEditScreen];
    [self.editUsernameField becomeFirstResponder];
    
}


- (void)destoryEditScreen
{
    [self.editScreen removeFromSuperview];
}


- (IBAction)tappedEditDone:(UIButton *)sender {
    
    UITextField *field;
    
    if (self.editUsernameField.isFirstResponder){
        field = self.editUsernameField;
    }
    else if (self.editEmailField.isFirstResponder){
        field = self.editEmailField;
    }
    
    else if (self.editPhoneField.isFirstResponder){
        field = self.editPhoneField;
    }
    
    [self textFieldShouldReturn:field];

}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.editScreen animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Updating";
    
    NSString *name = self.editUsernameField.text;
    NSString *phone = self.editPhoneField.text;
    NSString *email = self.editEmailField.text;
    
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
                                                    NSLog(@"%@",e);
                                                }
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.myTable reloadData];
                                                    [self destoryEditScreen];
                                                });

                                            });
                                            
                                            
                                        }
                                        else{
                                            [self destoryEditScreen];
                                        }
                                    }
                                    else{
                                        [self showAlertWithTitle:@"Error" message:message];
                                    }
                                }];
    
    return YES;
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return NSLocalizedString(@"Profile", nil);
    }
    
    else if (section == 1){
        return NSLocalizedString(@"Support", @"If a user needs help");
    }
    
    else if (section == 2){
        return  NSLocalizedString(@"Actions", nil);
    }
    
    else{
        return @"";
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            // Profile section
            if (indexPath.row == 4){
                [self showEditScreen];
            }
        }
            break;
        case 1:
        {
            // Support section
            if (indexPath.row == 0){
                // Terms of service
                
            }
            
            if (indexPath.row == 1){
                // contact
                MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
                if ([MFMailComposeViewController canSendMail]){
#warning set correct email for live app
                    tempMailCompose.mailComposeDelegate = self;
                    [tempMailCompose setToRecipients:@[@"cj_ogbuehi@yahoo.com"]];
                    [tempMailCompose setSubject:@"I have a question"];
                    [self presentViewController:tempMailCompose animated:YES completion:^{
                    }];
                }

            }
        }
            break;
            
        case 2:
        {
            // Actions
            if (indexPath.row == 0){
               // logout
                if (FBSession.activeSession.state == FBSessionStateOpen
                    || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
                    //close the session and remove the access token from the cache.
                    //the session state handler in the app delegate will be called automatically
                    [FBSession.activeSession closeAndClearTokenInformation];
                }
                
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"logged"];
                
                HomeViewController *home = [self.storyboard instantiateViewControllerWithIdentifier:@"homeScreen"];
                home.goToLogin = YES;
                UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:home];
                rootNav.navigationBarHidden = YES;
                [self.sideMenuViewController setMainViewController:rootNav animated:YES closeMenu:YES];

            }
        }
            
        default:
            break;
    }
}



- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0){
                // username
                cell.detailTextLabel.text = self.myUser.username;
            }
            
            if (indexPath.row == 1){
                // pic
                UIView *image = [cell viewWithTag:3000];
                if (image){
                    if ([image isKindOfClass:[UIImageView class]]){
                        [self.myUser getCorrectProfilePicWithImageView:(UIImageView *)image];

                    }
                }
                
            }
            
            if (indexPath.row == 2){
                // email
                cell.detailTextLabel.text = self.myUser.email;
            }
            
            if (indexPath.row == 3){
                // phone
                if (self.myUser.phone_number){
                    cell.detailTextLabel.text = self.myUser.phone_number;
                }
                else{
                    cell.detailTextLabel.text = @"No # provided";
                }
            }
            
            if (indexPath.row == 4){
                // Edit profile button
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.textLabel.text = NSLocalizedString(@"Edit Profile", nil);
            }
        }
            break;
            
        case 1:
        {
            if (indexPath.row == 0){
                // TOS
                cell.textLabel.text = NSLocalizedString(@"Terms of Service", nil);
            }
            
            else if (indexPath.row == 1){
                // Contact
                cell.textLabel.text = NSLocalizedString(@"Contact", nil);
            }
        }
            break;
            
        case 2:
        {
            if (indexPath.row == 0){
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.textLabel.text = NSLocalizedString(@"Log Out",nil);
            }
        }
            
        default:
            break;
    }
    

    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50.0;
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 5;
}

 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma -mark Mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
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


- (UIView *)editScreen
{
    if (!_editScreen){
        _editScreen = [[[NSBundle mainBundle] loadNibNamed:@"settingsEdit" owner:self options:nil]lastObject];
    }
    
    return _editScreen;
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


- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    [self slideDownKeyboard];
    UIViewController *menu = self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) setupColors];
    }
}

@end
