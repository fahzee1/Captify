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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"starring"]];
    
    
    for (id view in self.view.subviews){
        if ([view isKindOfClass:[UIButton class]]){
            UIButton *button = (UIButton *)view;
            button.layer.backgroundColor = [[UIColor colorWithHexString:@"#f39c12"] CGColor];
            button.layer.cornerRadius = 6.0f;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    }
    
    [self.menuCamera setTitle:NSLocalizedString(@"Home", @"Home button in menu") forState:UIControlStateNormal];
     [self.menuHistory setTitle:NSLocalizedString(@"History", @"History button in menu") forState:UIControlStateNormal];
     [self.menuFriends setTitle:NSLocalizedString(@"Friends", @"Friends button in menu") forState:UIControlStateNormal];
     [self.menuSettings setTitle:NSLocalizedString(@"Settings", @"Settings button in menu") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
