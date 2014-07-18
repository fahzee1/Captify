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
#import "AppDelegate.h"
#import "FeedViewController.h"


@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *menuCamera;
@property (weak, nonatomic) IBOutlet UIButton *menuHistory;
@property (weak, nonatomic) IBOutlet UIButton *menuFriends;
@property (weak, nonatomic) IBOutlet UIButton *menuSettings;
@property (weak, nonatomic) IBOutlet UIButton *menuFeed;

@property (weak, nonatomic) IBOutlet UIImageView *menuHomeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *menuHistoryIcon;
@property (weak, nonatomic) IBOutlet UIImageView *menuFeedIcon;
@property (weak, nonatomic) IBOutlet UIImageView *menuSettingsIcon;
@property (weak, nonatomic) IBOutlet UIImageView *menuInviteIcon;



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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:CAPTIFY_BG]];

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
    
    self.menuHomeIcon.image = nil;
    self.menuHistoryIcon.image = nil;
    self.menuFeedIcon.image = nil;
    self.menuSettingsIcon.image = nil;
    self.menuInviteIcon.image = nil;
    
    [AppDelegate clearImageCaches];
    
    
    
    

    
}



- (void)setupStyles
{
    
    self.menuCamera.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:19];
    self.menuHistory.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:19];
    self.menuFriends.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:19];
    self.menuSettings.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:19];
    self.menuFeed.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:19];
    
    
    [self.menuCamera setTitle:[NSString stringWithFormat:NSLocalizedString(@"Capture", @"Capture button in menu")] forState:UIControlStateNormal];
    
    [self.menuFriends setTitle:[NSString stringWithFormat:NSLocalizedString(@"Invite", @"Friends button in menu")] forState:UIControlStateNormal];

    [self.menuHistory setTitle:[NSString stringWithFormat:NSLocalizedString(@"History", @"History button in menu")] forState:UIControlStateNormal];

    [self.menuSettings setTitle:[NSString stringWithFormat:NSLocalizedString(@"Settings", @"Settings button in menu")] forState:UIControlStateNormal];
    
    [self.menuFeed setTitle:[NSString stringWithFormat:NSLocalizedString(@"Explore", @"Feed button in menu")] forState:UIControlStateNormal];
    
    
 
    
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
    
    
   

    
    if (!IS_IPHONE5){
        for (UIView *view in self.view.subviews){
            if ([view isKindOfClass:[UIButton class]]){
                UIButton *button = (UIButton *)view;
                CGRect buttonFrame = button.frame;
                buttonFrame.origin.y -= 40;
                buttonFrame.size.width -= 10;
                button.frame = buttonFrame;
                
                button.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:17];
                
                for (UIView *view2 in button.subviews){
                    if ([view2 isKindOfClass:[UILabel class]]){
                        UILabel *label = (UILabel *)view2;
                        if (label.frame.origin.x == 5){
                            label.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
                        }
                    }
                }
            }
            
            if ([view isKindOfClass:[UIImageView class]]){
                UIImageView *iv = (UIImageView *)view;
                CGRect ivFrame = iv.frame;
                ivFrame.origin.y -= 40;
                iv.frame = ivFrame;
            }
        }
    }
    

    

    
}

- (void)setupColors
{
    for (UIView *view in self.view.subviews){
        if ([view isKindOfClass:[UIButton class]]){
            view.backgroundColor = [UIColor clearColor];
        }
    }
    
    UIColor *homeColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHomeScreen]])? [UIColor colorWithHexString:CAPTIFY_DARK_BLUE]:[UIColor whiteColor];
    UIColor *historyColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHistoryScreen]])? [UIColor colorWithHexString:CAPTIFY_DARK_BLUE]:[UIColor whiteColor];
    //UIColor *inviteColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuFriendsScreen]])? [UIColor colorWithHexString:CAPTIFY_DARK_BLUE]:[UIColor whiteColor];
    UIColor *feedColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuFeedScreen]])? [UIColor colorWithHexString:CAPTIFY_DARK_BLUE]:[UIColor whiteColor];
    UIColor *settingsColor = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuSettingsScreen]])? [UIColor colorWithHexString:CAPTIFY_DARK_BLUE]:[UIColor whiteColor];
    
    
    UIImage *homeIcon = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHomeScreen]])? [UIImage imageNamed:MENU_HOME_ACTIVE]:[UIImage imageNamed:MENU_HOME_INACTIVE];
    UIImage *historyIcon = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuHistoryScreen]])? [UIImage imageNamed:MENU_HISTORY_ACTIVE]:[UIImage imageNamed:MENU_HISTORY_INACTIVE];
    UIImage *feedIcon = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuFeedScreen]])? [UIImage imageNamed:MENU_EXPLORE_ACTIVE]:[UIImage imageNamed:MENU_EXPLORE_INACTIVE];
    UIImage *settingsIcon = ([self.currentScreen isEqualToNumber:[NSNumber numberWithInt:MenuSettingsScreen]])? [UIImage imageNamed:MENU_SETTINGS_ACTIVE]:[UIImage imageNamed:MENU_SETTINGS_INACTIVE];

    
    [self.menuCamera setTitleColor:homeColor forState:UIControlStateNormal];
    [self.menuHistory setTitleColor:historyColor forState:UIControlStateNormal];
    [self.menuFeed setTitleColor:feedColor forState:UIControlStateNormal];
    [self.menuSettings setTitleColor:settingsColor forState:UIControlStateNormal];
    
    self.menuHomeIcon.image = homeIcon;
    self.menuHistoryIcon.image = historyIcon;
    self.menuFeedIcon.image = feedIcon;
    self.menuSettingsIcon.image = settingsIcon;
    // invite doesnt change colors
    self.menuInviteIcon.image = [UIImage imageNamed:MENU_INVITE_INACTIVE];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedIcon:)];
    tap1.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedIcon:)];
    tap2.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedIcon:)];
    tap3.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedIcon:)];
    tap4.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedIcon:)];
    tap5.numberOfTapsRequired = 1;
    
    self.menuHomeIcon.userInteractionEnabled = YES;
    self.menuHistoryIcon.userInteractionEnabled = YES;
    self.menuFeedIcon.userInteractionEnabled = YES;
    self.menuSettingsIcon.userInteractionEnabled = YES;
    self.menuInviteIcon.userInteractionEnabled = YES;
    
    [self.menuHomeIcon addGestureRecognizer:tap1];
    [self.menuHistoryIcon addGestureRecognizer:tap2];
    [self.menuFeedIcon addGestureRecognizer:tap3];
    [self.menuSettingsIcon addGestureRecognizer:tap4];
    [self.menuInviteIcon addGestureRecognizer:tap5];

}

- (void)tappedIcon:(UITapGestureRecognizer *)sender
{
    switch (sender.view.tag) {
        case MenuHomeIcon:
        {
            [self tappedMenuButton:self.menuCamera];
        }
            break;
            
        case MenuHistoryIcon:
        {
            [self tappedMenuButton:self.menuHistory];
        }
            break;
            
        case MenuFriendsIcon:
        {
            [self tappedMenuButton:self.menuFriends];
        }
            break;
            
        case MenuSettingIcon:
        {
            [self tappedMenuButton:self.menuSettings];
        }
            break;
            
        case MenuFeedIcon:
        {
            [self tappedMenuButton:self.menuFeed];
        }
            break;
            
        default:
            break;
    }

}

- (void)updateCurrentScreen:(MenuScreenConstants)screen
{
    self.currentScreen = [NSNumber numberWithInt:screen];
    [self setupColors];
    
    
}

- (void)showScreen:(MenuScreenConstants)screen
{
    switch (screen) {
        case MenuHomeScreen:
        {
            [self tappedMenuButton:self.menuCamera];
        }
            break;
            
        case MenuHistoryScreen:
        {
            [self tappedMenuButton:self.menuHistory];
        }
            break;
            
        case MenuFriendsScreen:
        {
            [self tappedMenuButton:self.menuFriends];
        }
            break;
            
        case MenuSettingsScreen:
        {
            [self tappedMenuButton:self.menuSettings];
        }
            break;
            
        case MenuFeedScreen:
        {
            [self tappedMenuButton:self.menuFeed];
        }
            break;
            
        default:
            break;
    }

}

- (void)showExplorePageWithLatestJson:(NSString *)json
                             andImage:(UIImage *)image
{
    self.menuFeedIcon.image = [UIImage imageNamed:MENU_EXPLORE_ACTIVE];
    UIViewController *feed = [self.storyboard instantiateViewControllerWithIdentifier:@"feedRoot"];
    if([self isAlreadyMainVC:feed.childViewControllers[0]]){
        [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
    }
    else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(menuShowingAnotherScreen)]){
            [self.delegate menuShowingAnotherScreen];
        }
        self.currentScreen = [NSNumber numberWithInt:MenuFeedScreen];
        
        if ([feed isKindOfClass:[UINavigationController class]]){
            UIViewController *feed2 = ((UINavigationController *)feed).topViewController;
            if ([feed2 isKindOfClass:[FeedViewController class]]){
                ((FeedViewController *)feed2).lastestJson = json;
                ((FeedViewController *)feed2).latestImage = image;
            }
        }
        
        [self.sideMenuViewController setMainViewController:feed animated:YES closeMenu:YES];
    }

}



- (IBAction)tappedMenuButton:(UIButton *)sender {
    
    if (sender.tag != MenuFriendsScreen){
        [sender setTitleColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] forState:UIControlStateNormal];
    }
    
    switch (sender.tag) {
        case MenuHomeScreen:
        {
            self.menuHomeIcon.image = [UIImage imageNamed:MENU_HOME_ACTIVE];
            
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
               self.menuHistoryIcon.image = [UIImage imageNamed:MENU_HISTORY_ACTIVE];
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
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[INVITE_TEXT] applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
            [self presentViewController:activityVC animated:YES completion:nil];
            break;
        }
            
        case MenuSettingsScreen:
        {
            self.menuSettingsIcon.image = [UIImage imageNamed:MENU_SETTINGS_ACTIVE];
            
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
            self.menuFeedIcon.image = [UIImage imageNamed:MENU_EXPLORE_ACTIVE];
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
