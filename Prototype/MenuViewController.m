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
}



- (void)setupStyles
{
    self.menuCamera.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19];
    self.menuHistory.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19];
    self.menuFriends.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19];
    self.menuSettings.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:19];
    
    
    [self.menuCamera setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Home", @"Home button in menu"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-home"]] forState:UIControlStateNormal];
    
    [self.menuFriends setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Invite", @"Friends button in menu"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"]] forState:UIControlStateNormal];

    [self.menuHistory setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ History", @"History button in menu"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-folder-o"]] forState:UIControlStateNormal];

    [self.menuSettings setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Settings", @"Settings button in menu"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cogs"]] forState:UIControlStateNormal];
 
    
    [self.menuCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuHistory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuFriends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuSettings setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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

    
}

- (void)setupColors
{
    self.menuCamera.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHomeScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    self.menuHistory.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHistoryScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    
    self.menuFriends.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuFriendsScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    self.menuSettings.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuSettingsScreen]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];

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
