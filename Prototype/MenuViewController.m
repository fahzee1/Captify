//
//  MenuViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/13/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "MenuViewController.h"
#import "UIColor+HexValue.h"
#import "TWTSideMenuViewController.h"
#import "TMCache.h"
#import "SocialFriends.h"
#import "FriendsContainerController.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"


@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *menuCamera;
@property (weak, nonatomic) IBOutlet UIButton *menuHistory;
@property (weak, nonatomic) IBOutlet UIButton *menuFriends;
@property (weak, nonatomic) IBOutlet UIButton *menuSettings;
@property (weak, nonatomic) IBOutlet UIButton *menuFeed;

@property (strong, nonatomic)NSArray *facebookFriendsArray;
@property (strong, nonatomic)NSNumber *currentScreen;

@end

@implementation MenuViewController

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
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];

    if (!self.currentScreen){
        self.currentScreen = [NSNumber numberWithInt:MenuHomeScreen];
    }
    
    
    [self setupStyles];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupColors];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog(@"received memory warning here");
}



- (void)setupStyles
{
    
    self.menuCamera.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:19];
    self.menuHistory.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:19];
    self.menuFriends.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:19];
    self.menuSettings.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:19];
    self.menuFeed.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:19];
    
    
    [self.menuCamera setTitle:[NSString stringWithFormat:NSLocalizedString(@"Home", @"Home button in menu")] forState:UIControlStateNormal];
    
    [self.menuFriends setTitle:[NSString stringWithFormat:NSLocalizedString(@"Invite", @"Friends button in menu")] forState:UIControlStateNormal];

    [self.menuHistory setTitle:[NSString stringWithFormat:NSLocalizedString(@"History", @"History button in menu")] forState:UIControlStateNormal];

    [self.menuSettings setTitle:[NSString stringWithFormat:NSLocalizedString(@"Settings", @"Settings button in menu")] forState:UIControlStateNormal];
    
    [self.menuFeed setTitle:[NSString stringWithFormat:NSLocalizedString(@"Action", @"Feed button in menu")] forState:UIControlStateNormal];
    
    
 
    
    [self.menuCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuHistory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuFriends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuSettings setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuFeed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    /*
    self.menuCamera.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    self.menuHistory.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    self.menuFriends.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    self.menuSettings.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
     */
    
    self.menuCamera.layer.cornerRadius = 6.0f;
    self.menuHistory.layer.cornerRadius = 6.0f;
    self.menuFriends.layer.cornerRadius = 6.0f;
    self.menuSettings.layer.cornerRadius = 6.0f;
    self.menuFeed.layer.cornerRadius = 6.0f;
    
    UILabel *cameraIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, -15, 80, 80)];
    cameraIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    cameraIcon.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-home"];
    cameraIcon.userInteractionEnabled = NO;
    cameraIcon.textColor = [UIColor whiteColor];
    
    UILabel *historyIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, -15, 80, 80)];
    historyIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    historyIcon.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-folder-o"];
    historyIcon.userInteractionEnabled = NO;
    historyIcon.textColor = [UIColor whiteColor];
    
    UILabel *actionIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, -15, 80, 80)];
    actionIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    actionIcon.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-globe"];
    actionIcon.userInteractionEnabled = NO;
    actionIcon.textColor = [UIColor whiteColor];
    

    UILabel *settingsIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, -15, 80, 80)];
    settingsIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    settingsIcon.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-cogs"];
    settingsIcon.userInteractionEnabled = NO;
    settingsIcon.textColor = [UIColor whiteColor];
    
    UILabel *inviteIcon = [[UILabel alloc] initWithFrame:CGRectMake(5, -15, 80, 80)];
    inviteIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    inviteIcon.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"];
    inviteIcon.userInteractionEnabled = NO;
    inviteIcon.textColor = [UIColor whiteColor];
    



    
    
    
    [self.menuCamera addSubview:cameraIcon];
    [self.menuHistory addSubview:historyIcon];
    [self.menuFeed addSubview:actionIcon];
    [self.menuFriends addSubview:inviteIcon];
    [self.menuSettings addSubview:settingsIcon];
    

    

    
}

- (void)setupColors
{
    self.menuCamera.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHomeScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    self.menuHistory.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHistoryScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    
    self.menuFriends.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuFriendsScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    self.menuSettings.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuSettingsScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    
    self.menuFeed.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuFeedScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];

}

- (void)updateCurrentScreen:(MenuScreenConstants)screen
{
    self.currentScreen = [NSNumber numberWithInt:screen];
    [self setupColors];
    
    
}

- (IBAction)tappedMenuButton:(UIButton *)sender {
    switch (sender.tag) {
        case MenuHomeScreen:
        {
            UIViewController *camera = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHomeNavigation"];
            if ([self isAlreadyMainVC:camera.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen = [NSNumber numberWithInt:MenuHomeScreen];
                [self.sideMenuViewController setMainViewController:camera animated:YES closeMenu:YES];
               
            }

            break;
        }
        case MenuHistoryScreen:
        {
            UIViewController *history = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHistoryNew"];
            if ([self isAlreadyMainVC:history.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen = [NSNumber numberWithInt:MenuHistoryScreen];
                [self.sideMenuViewController setMainViewController:history animated:YES closeMenu:YES];
            }
            
            break;
        }
            
        case MenuFriendsScreen:
        {
            /*
            UIViewController *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"friendContainerRoot"];
            if ([self isAlreadyMainVC:friends.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen =[NSNumber numberWithInt:MenuFriendsScreen];
                ((FriendsContainerController *)friends.childViewControllers[0]).facebookFriendsArray = self.facebookFriendsArray;
                [self.sideMenuViewController setMainViewController:friends animated:YES closeMenu:YES];
            }
             */
            
            NSString *inviteText = @"Check out Captify.. Memes and captivating captions with friends! http://gocaptify.com/download";
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[inviteText] applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
            [self presentViewController:activityVC animated:YES completion:nil];
            break;
        }
            
        case MenuSettingsScreen:
        {
            UIViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsRoot"];
            if([self isAlreadyMainVC:settings.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen = [NSNumber numberWithInt:MenuSettingsScreen];
                [self.sideMenuViewController setMainViewController:settings animated:YES closeMenu:YES];
            }
            break;

        }
            
        case MenuFeedScreen:
        {
            UIViewController *feed = [self.storyboard instantiateViewControllerWithIdentifier:@"feedRoot"];
            if([self isAlreadyMainVC:feed.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen = [NSNumber numberWithInt:MenuFeedScreen];
                [self.sideMenuViewController setMainViewController:feed animated:YES closeMenu:YES];
            }

             break;
        }
           
        default:
            break;
    }
}



- (BOOL)isAlreadyMainVC:(UIViewController *)controller
{
    NSArray *main = self.sideMenuViewController.mainViewController.childViewControllers[0];
    if ([main isKindOfClass:[controller class]]){
        return YES;
    }
    else{
        return NO;
    }
}




@end
