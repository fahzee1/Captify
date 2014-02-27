//
//  FriendsContainerController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "FriendsContainerController.h"
#import "TWTSideMenuViewController.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "AddFriendsViewController.h"
#import "TMCache.h"
#import "FacebookFriends.h"

@interface FriendsContainerController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (strong,nonatomic)UIViewController *currentController;


@end

@implementation FriendsContainerController

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
    
    UIViewController *vc = [self viewControllerForSegmentIndex:self.mySegmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.myContainerView.bounds;
    [self.myContainerView addSubview:vc.view];
    self.currentController = vc;
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25]} forState:UIControlStateNormal];
   
    self.navigationItem.leftBarButtonItem = button;
    self.navigationItem.title = NSLocalizedString(@"Friends", nil);
    
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Contacts", nil) forSegmentAtIndex:0];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Facebook", nil) forSegmentAtIndex:1];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Invite", nil) forSegmentAtIndex:2];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Search", nil) forSegmentAtIndex:3];
    
    [self loadFriends];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showMenu
{
     [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    
    [self addChildViewController:vc];
    [self transitionFromViewController:self.currentController
                      toViewController:vc
                              duration:0.5
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
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"friends"];
            break;
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addFriends"];
            if ([vc isKindOfClass:[AddFriendsViewController class]]){
                ((AddFriendsViewController *)vc).facebookFriendsArray = self.facebookFriendsArray;
            }
            break;
        case 2:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addFriends"];
            break;
            
        case 3:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"searchFriends"];
            break;
            
        default:
            break;
    }
    return vc;
}


- (void)loadFriends
{
    NSArray *friends = [[TMCache sharedCache] objectForKey:@"facebookFriends"];
    if (friends){
        self.facebookFriendsArray = friends;
    }
    else{
        FacebookFriends *f = [[FacebookFriends alloc] init];
        [f allFriends:^(BOOL wasSuccessful, NSArray *data) {
            if (wasSuccessful){
                self.facebookFriendsArray = data;
            }
        }];
    }
    
}

@end
