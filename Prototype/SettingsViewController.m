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
//#import "MBProgressHUD.h"
#import "CJPopup.h"
#import "UIColor+HexValue.h"
#import "MenuViewController.h"


#ifdef USE_GOOGLE_ANALYTICS
    #import "GAI.h"
    #import "GAIFields.h"
    #import "GAIDictionaryBuilder.h"
#endif


#define SETTINGS_PHONE_DEFAULT @"No # provided"
#define SETTINGS_INVITE 2000
#define SETTINGS_PHOTO 3000
#define SETTINGS_PHOTO_LABEL 4000
#define SETTINGS_EDIT_BUTTON 5000
#define SETTINGS_LOGOUT 6000

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



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.myTable.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.myTable.separatorStyle = UITableViewCellSelectionStyleNone;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (USE_GOOGLE_ANALYTICS){
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Settings Screen"];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
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
    [self destoryEditScreen];
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
    self.editPhoneField.text = self.myUser.phone_number ? self.myUser.phone_number:SETTINGS_PHONE_DEFAULT;
    self.editEmailField.text = self.myUser.email;
    
    self.editDoneButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.editDoneButton.layer.cornerRadius = 10;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"facebook_user"]){
        self.editUsernameField.userInteractionEnabled = NO;
        self.editUsernameField.text = NSLocalizedString(@"Not allowed (Facebook)", nil);
    }

    
    [self.view.window addSubview:self.editScreen];


}

- (void)showEditScreen
{
    self.editScreen.frame = CGRectMake(7, 66, self.editScreen.frame.size.width, self.editScreen.frame.size.height);
    [self setupEditScreen];
    if (self.editUsernameField.isUserInteractionEnabled){
        [self.editUsernameField becomeFirstResponder];
    }
    else{
        [self.editEmailField becomeFirstResponder];
    }
    
}


- (void)destoryEditScreen
{
    [UIView animateWithDuration:0.8
                     animations:^{
                         self.editScreen.alpha = 0;
                     } completion:^(BOOL finished) {
                         
                        [self.editScreen removeFromSuperview];
                         self.editScreen.alpha = 1;

                     }];

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
    
    CJPopup *hud = [[CJPopup alloc] init];
    [hud showBlackActivityWithMessage:@"Updating"];
    
    NSString *name = self.editUsernameField.text;
    NSString *phone = self.editPhoneField.text;
    NSString *email = self.editEmailField.text;
    
    
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
                                          [hud hide];
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
                                            // no changes
                                            else{
                                                [self destoryEditScreen];
                                            }
                                        }
                                        // not successful
                                        else{
                                            
                                            [self destoryEditScreen];
                                            [self showAlertWithTitle:@"Error" message:message];
                                        }
                                    }];
    }
    // no changes
    else{
        [hud hide];
         [self destoryEditScreen];
    }
    
    return YES;
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1){
        return NSLocalizedString(@"Profile", nil);
    }
    
    else if (section == 2){
        return NSLocalizedString(@"Support", @"If a user needs help");
    }
    
    else if (section == 3){
        return  NSLocalizedString(@"Actions", nil);
    }
    
    else{
        return @"";
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2){
        // support
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self setCellColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forCell:cell];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forCell:cell];
    
}

- (void)setCellColor:(UIColor *)color forCell:(UITableViewCell *)cell
{
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0){
                // invite friends
                
                UITableViewCell *cell = [self.myTable cellForRowAtIndexPath:indexPath];
                if (cell){
                    UIView *inviteButton = [cell viewWithTag:SETTINGS_INVITE];
                    if ([inviteButton isKindOfClass:[UILabel class]]){
                        UILabel *inviteB = (UILabel *)inviteButton;
                        inviteB.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
                        inviteB.textColor = [UIColor whiteColor];
                        
                    }
                }
                
                // update the highlighted menu button to the screen we're about to show
                UIViewController *menu = self.sideMenuViewController.menuViewController;
                if ([menu isKindOfClass:[MenuViewController class]]){
                    [((MenuViewController *)menu) updateCurrentScreen:MenuFriendsScreen];
                }
                
                UIViewController *inviteScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"friendContainerRoot"];
                [self.sideMenuViewController setMainViewController:inviteScreen animated:YES closeMenu:NO];
            }
        }
        case 1:
        {
            // Profile section
            if (indexPath.row == 4){
                
                UITableViewCell *cell = [self.myTable cellForRowAtIndexPath:indexPath];
                if (cell){
                    UIView *editButton = [cell viewWithTag:SETTINGS_EDIT_BUTTON];
                    if ([editButton isKindOfClass:[UILabel class]]){
                        UILabel *editB = (UILabel *)editButton;
                        editB.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] CGColor];
                        
                        
                        
                        [self showEditScreen];
                        
                        
                        editB.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE];
                    }
                }

                
                
            }
        }
            break;
        case 2:
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
            
        case 3:
        {
            // Actions
            if (indexPath.row == 0){
               // logout
                
                
                UITableViewCell *cell = [self.myTable cellForRowAtIndexPath:indexPath];
                if (cell){
                    UIView *logoutButton = [cell viewWithTag:SETTINGS_LOGOUT];
                    if ([logoutButton isKindOfClass:[UILabel class]]){
                        UILabel *logoutB = (UILabel *)logoutButton;
                        logoutB.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] CGColor];
                        
                    }
                }

                
                if (FBSession.activeSession.state == FBSessionStateOpen
                    || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
                    //close the session and remove the access token from the cache.
                    //the session state handler in the app delegate will be called automatically
                    [FBSession.activeSession closeAndClearTokenInformation];
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:NO forKey:@"logged"];
                [defaults setBool:NO forKey:@"facebook_user"];
                [defaults setBool:NO forKey:@"phone_never"];
                [defaults setValue:[NSNumber numberWithInt:0] forKey:@"challengeToolTip"];
                [defaults setValue:[NSNumber numberWithInt:0] forKey:@"homeToolTip"];
                [defaults removeObjectForKey:@"superuser"];
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


- (void)setupTableStylesWithCell:(UITableViewCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 1;
    cell.layer.cornerRadius = 10;
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    
    UIView *photoLabel = [cell viewWithTag:SETTINGS_PHOTO_LABEL];
    if ([photoLabel isKindOfClass:[UILabel class]]){
        UILabel *photoL = (UILabel *)photoLabel;
        photoL.textColor = [UIColor whiteColor];
        photoL.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    }
    
    UIView *editButton = [cell viewWithTag:SETTINGS_EDIT_BUTTON];
    if ([editButton isKindOfClass:[UILabel class]]){
        UILabel* editB = (UILabel *)editButton;
        editB.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor] ;
        editB.textColor = [UIColor whiteColor];
        editB.layer.cornerRadius = 5;
        editB.text = NSLocalizedString(@"Edit Profile", nil);
        editB.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    }
    
    UIView *logoutButton = [cell viewWithTag:SETTINGS_LOGOUT];
    if ([logoutButton isKindOfClass:[UILabel class]]){
        UILabel* logoutB = (UILabel *)logoutButton;
        logoutB.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor] ;
        logoutB.textColor = [UIColor whiteColor];
        logoutB.layer.cornerRadius = 5;
        logoutB.text = NSLocalizedString(@"Log Out", nil);
        logoutB.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    }
    
    UIView *inviteButton = [cell viewWithTag:SETTINGS_INVITE];
    if ([inviteButton isKindOfClass:[UILabel class]]){
        UILabel *inviteB = (UILabel *)inviteButton;
        inviteB.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
        inviteB.textColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
        inviteB.text = NSLocalizedString(@"Invite Friends!", nil);
        inviteB.layer.cornerRadius = 20;
        inviteB.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        
    }


}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setupTableStylesWithCell:cell];
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0){
                // invite friends
                 cell.layer.borderWidth = 0;
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0){
                // username
                cell.detailTextLabel.text = self.myUser.username;
            }
            
            if (indexPath.row == 1){
                // pic
                UIView *image = [cell viewWithTag:SETTINGS_PHOTO];
                if (image){
                    if ([image isKindOfClass:[UIImageView class]]){
                        [self.myUser getCorrectProfilePicWithImageView:(UIImageView *)image];
                        ((UIImageView *)image).layer.masksToBounds = YES;
                        ((UIImageView *)image).layer.cornerRadius = 20;

                    }
                }
                
            }
            
            if (indexPath.row == 2){
                // email
                if (self.myUser.email){
                    cell.detailTextLabel.text = self.myUser.email;
                }
                else{
                    cell.detailTextLabel.text = NSLocalizedString(@"No email provided", nil);
                }
            }
            
            if (indexPath.row == 3){
                // phone
                if (self.myUser.phone_number){
                    cell.detailTextLabel.text = self.myUser.phone_number;
                }
                else{
                    cell.detailTextLabel.text = NSLocalizedString(@"No # provided", nil);;
                }
            }
            
            if (indexPath.row == 4){
                // Edit profile button
                cell.layer.borderWidth = 0;
            }
        }
            break;
            
        case 2:
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
            
        case 3:
        {
            // logout
            if (indexPath.row == 0){
                //cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.layer.borderWidth = 0;
            }
        }
            
        default:
            break;
    }
    

    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        // invite friends
        return 80.0;
    }
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
