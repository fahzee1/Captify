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

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *menuCamera;
@property (weak, nonatomic) IBOutlet UIButton *menuHistory;
@property (weak, nonatomic) IBOutlet UIButton *menuFriends;
@property (weak, nonatomic) IBOutlet UIButton *menuSettings;

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
    
    for (id view in self.view.subviews){
        if ([view isKindOfClass:[UIButton class]]){
            UIButton *button = (UIButton *)view;
            button.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
            button.layer.cornerRadius = 6.0f;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showCamera:(UIButton *)sender {
    UIViewController *camera = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHomeNavigation"];
    if ([self isAlreadyMainVC:camera.childViewControllers[0]]){
        [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
    }
    else{
        [self.sideMenuViewController setMainViewController:camera animated:YES closeMenu:YES];
    }
}

- (IBAction)showHistory:(UIButton *)sender {
    UIViewController *history = [self.storyboard instantiateViewControllerWithIdentifier:@"historyRoot"];
    if ([self isAlreadyMainVC:history.childViewControllers[0]]){
        [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
    }
    else{
        [self.sideMenuViewController setMainViewController:history animated:YES closeMenu:YES];
    }
}

- (IBAction)showFriends:(UIButton *)sender {
    UIViewController *friends = [self.storyboard instantiateViewControllerWithIdentifier:@"friendContainerRoot"];
    if ([self isAlreadyMainVC:friends.childViewControllers[0]]){
        [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
    }
    else{
        [self.sideMenuViewController setMainViewController:friends animated:YES closeMenu:YES];
    }

}

- (IBAction)showSettings:(id)sender {
    UIViewController *settings = [self.storyboard instantiateViewControllerWithIdentifier:@"settingsRoot"];
    if([self isAlreadyMainVC:settings.childViewControllers[0]]){
        [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
    }
    else{
        [self.sideMenuViewController setMainViewController:settings animated:YES closeMenu:YES];
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
