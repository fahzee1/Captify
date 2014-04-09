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

@interface HistoryContainerViewController ()<TWTSideMenuViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentControl;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;


@property (strong,nonatomic)UIViewController *currentController;

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
  
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e46e1b"]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = button;
    self.navigationItem.title = NSLocalizedString(@"History", nil);
    
    [self.mySegmentControl setTitle:NSLocalizedString(@"Received", nil) forSegmentAtIndex:0];
    [self.mySegmentControl setTitle:NSLocalizedString(@"Sent", nil) forSegmentAtIndex:0];

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


@end
