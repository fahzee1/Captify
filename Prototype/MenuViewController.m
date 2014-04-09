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

#define HomeTag 1000
#define HistoryTag 1001
#define FriendsTag 1002
#define SettingsTag 1003

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"skulls"]];

    if (!self.currentScreen){
        self.currentScreen = [NSNumber numberWithInt:HomeTag];
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
    [self.menuCamera setTitle:NSLocalizedString(@"Home", @"Home button in menu") forState:UIControlStateNormal];
    [self.menuHistory setTitle:NSLocalizedString(@"History", @"History button in menu") forState:UIControlStateNormal];
    [self.menuFriends setTitle:NSLocalizedString(@"Friends", @"Friends button in menu") forState:UIControlStateNormal];
    [self.menuSettings setTitle:NSLocalizedString(@"Settings", @"Settings button in menu") forState:UIControlStateNormal];
    
    [self.menuCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuHistory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuFriends setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuSettings setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.menuCamera.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    self.menuHistory.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    self.menuFriends.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    self.menuSettings.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:20];
    
    self.menuCamera.layer.cornerRadius = 6.0f;
    self.menuHistory.layer.cornerRadius = 6.0f;
    self.menuFriends.layer.cornerRadius = 6.0f;
    self.menuSettings.layer.cornerRadius = 6.0f;

    
}

- (void)setupColors
{
    self.menuCamera.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:HomeTag]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    self.menuHistory.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:HistoryTag]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    
    self.menuFriends.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:FriendsTag]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];
    self.menuSettings.layer.backgroundColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:SettingsTag]])? [[UIColor colorWithHexString:@"#4698aa"] CGColor]:[[UIColor colorWithHexString:@"#69c9d0"] CGColor];

}

- (IBAction)tappedMenuButton:(UIButton *)sender {
    switch (sender.tag) {
        case HomeTag:
        {
            UIViewController *camera = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHomeNavigation"];
            if ([self isAlreadyMainVC:camera.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen = [NSNumber numberWithInt:HomeTag];
                [self.sideMenuViewController setMainViewController:camera animated:YES closeMenu:YES];
               
            }

            break;
        }
        case HistoryTag:
        {
            UIViewController *history = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHistoryNew"];
            if ([self isAlreadyMainVC:history.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen = [NSNumber numberWithInt:HistoryTag];
                [self.sideMenuViewController setMainViewController:history animated:YES closeMenu:YES];
            }
            
            break;
        }
            
        case FriendsTag:
        {
            UIViewController *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"friendContainerRoot"];
            if ([self isAlreadyMainVC:friends.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen =[NSNumber numberWithInt:FriendsTag];
                ((FriendsContainerController *)friends.childViewControllers[0]).facebookFriendsArray = self.facebookFriendsArray;
                [self.sideMenuViewController setMainViewController:friends animated:YES closeMenu:YES];
            }
            break;
        }
            
        case SettingsTag:
        {
            UIViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsRoot"];
            if([self isAlreadyMainVC:settings.childViewControllers[0]]){
                [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
            }
            else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
                    [self.delegate menuShowingAnotherScreen];
                }
                self.currentScreen = [NSNumber numberWithInt:SettingsTag];
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
