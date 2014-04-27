//
//  HistoryContainerViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/7/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryContainerViewController.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "TWTSideMenuViewController.h"
#import "Notifications.h"
#import "UIColor+HexValue.h"
#import "MenuViewController.h"
#import "HistoryRecievedViewController.h"
#import "HistorySentViewController.h"
#import "FUISegmentedControl.h"
#import "UIFont+FlatUI.h"
#import "UIColor+FlatUI.h"

@interface HistoryContainerViewController ()<TWTSideMenuViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentControl;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (strong,nonatomic)UIViewController *currentController;
@property (strong, nonatomic)UIButton *refreshButton;
@property (strong, nonatomic)UIBarButtonItem *rightRefreshButton;
@property (strong, nonatomic)UIActivityIndicatorView *spinner;

@end

@implementation HistoryContainerViewController

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
  
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadHistory)];
    [rightButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                          NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    /*
  
    // custom view here so we can use frame of button to place activity indicator when tapped
    self.refreshButton = [[UIButton alloc] init];
    self.refreshButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    [self.refreshButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"] forState:UIControlStateNormal];
    [self.refreshButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    self.refreshButton.frame = CGRectMake(0, 0, 80, 80);
    [self.refreshButton addTarget:self action:@selector(reloadHistory) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *right =  [[UIBarButtonItem alloc] initWithCustomView:self.refreshButton];
    CGRect frame = self.refreshButton.frame;
    frame.origin.x += 100;
    self.refreshButton.frame = frame;
     */
    
    self.rightRefreshButton = rightButton;
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.title = NSLocalizedString(@"History", nil);
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    
    [self.mySegmentControl setTitle:NSLocalizedString(@"Received", nil) forSegmentAtIndex:0];
    [self.mySegmentControl setTitle:NSLocalizedString(@"Sent", nil) forSegmentAtIndex:1];
    
    FUISegmentedControl *control = (FUISegmentedControl *)self.mySegmentControl;
    if ([control isKindOfClass:[FUISegmentedControl class]]){
        control.selectedFont = [UIFont fontWithName:@"ProximaNova-Bold" size:16];
        control.selectedFontColor = [UIColor cloudsColor];
        control.deselectedFont = [UIFont fontWithName:@"ProximaNova-Bold" size:16];
        control.deselectedFontColor = [UIColor cloudsColor];
        control.selectedColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
        control.deselectedColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        control.dividerColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        control.cornerRadius = 5.0;

    }
    

    // we're comming from senderpreview screen right
    // after creating challenge so show sent screen
    // home sets this
    if (self.showSentScreen){
        self.mySegmentControl.selectedSegmentIndex = 1;
        self.showSentScreen = NO;
    }
    
    UIViewController *vc = [self viewControllerForSegmentIndex:self.mySegmentControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.myContainerView.bounds;
    [self.myContainerView addSubview:vc.view];
    self.currentController = vc;
    
    
    self.sideMenuViewController.delegate = self;
   
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
}

- (void)dealloc
{
    self.currentController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)segementChanged:(UISegmentedControl *)sender {
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    
    [self addChildViewController:vc];
    [self transitionFromViewController:self.currentController
                      toViewController:vc
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                [self.currentController.view removeFromSuperview];
                                vc.view.frame = self.myContainerView.bounds;
                                [self.myContainerView addSubview:vc.view];
                            } completion:^(BOOL finished) {
                                [vc didMoveToParentViewController:self];
                                [self.currentController removeFromParentViewController];
                                self.currentController = vc;
                            }];


}




- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    UIViewController *vc;
    switch (index) {
        case 0:
        {
           vc = [self.storyboard instantiateViewControllerWithIdentifier:@"recievedHistory"];
        }
            
            break;
        case 1:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"sentHistory"];
        }
            break;
        default:
            break;
    }
    return vc;
}

- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
    
}


- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    UIViewController *menu = self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) setupColors];
    }
}


- (void)reloadHistory
{
    self.navigationItem.rightBarButtonItem = nil;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(275, 0, 50, 50);
    self.spinner.color = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    [self.navigationController.navigationBar addSubview:self.spinner];
    [self.spinner startAnimating];

   UIViewController *vcR = [self.storyboard instantiateViewControllerWithIdentifier:@"recievedHistory"];
    UIViewController *vcS = [self.storyboard instantiateViewControllerWithIdentifier:@"sentHistory"];
    if ([vcR isKindOfClass:[HistoryRecievedViewController class]] && [vcS isKindOfClass:[HistorySentViewController class]]){
        [((HistoryRecievedViewController *)vcR) fetchUpdatesWithBlock:^{
              [((HistorySentViewController *)vcS) fetchUpdatesWithBlock:^{
                  [self.spinner stopAnimating];
                  [self.spinner removeFromSuperview];
                  self.spinner = nil;
                  self.navigationItem.rightBarButtonItem = self.rightRefreshButton;
              }];
            
        }];
    }
}


- (UIViewController *)currentController
{
    if (!_currentController){
        UIViewController *vc = [self viewControllerForSegmentIndex:self.mySegmentControl.selectedSegmentIndex];
        _currentController = vc;
    }
    
    return _currentController;
}



@end
