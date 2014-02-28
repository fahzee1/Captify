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
#import "FacebookFriendsViewController.h"
#import "TMCache.h"
#import "FacebookFriends.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FriendsContainerController ()<FBViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (strong,nonatomic)UIViewController *currentController;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) FacebookFriends *friend;
@property (strong, nonatomic) FBCacheDescriptor *cacheDescriptor;


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
   
    self.navigationController.toolbarHidden = NO;
    
    UIViewController *vc = [self viewControllerForSegmentIndex:self.mySegmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.myContainerView.bounds;
    [self.myContainerView addSubview:vc.view];
    self.currentController = vc;
    
    
    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-users"] style:UIBarButtonItemStyleBordered target:self action:@selector(showFacebookInvite)];
    
    [inviteButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25]} forState:UIControlStateNormal];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    
    self.toolbarItems = @[flexibleSpace, inviteButton,flexibleSpace2];

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25]} forState:UIControlStateNormal];
    
   
    self.navigationItem.leftBarButtonItem = button;
    self.navigationItem.title = NSLocalizedString(@"Friends", nil);
    
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Facebook", nil) forSegmentAtIndex:0];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Contacts", nil) forSegmentAtIndex:1];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Search", nil) forSegmentAtIndex:2];
    
    self.cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
    [self.cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
   
    
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
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"facebookFriends"];
            if ([vc isKindOfClass:[FacebookFriendsViewController class]]){
                ((FacebookFriendsViewController *)vc).facebookFriendsArray = self.facebookFriendsArray;
            }

            break;
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"contactFriends"];
            break;
        case 2:
            vc =  vc = [self.storyboard instantiateViewControllerWithIdentifier:@"searchFriends"];
            break;
            
        default:
            break;
    }
    return vc;
}



- (void)showFacebookInvite{
 
    if (!FBSession.activeSession.isOpen){
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          if (error){
                                              UIAlertView *alert = [[UIAlertView alloc]
                                                                    initWithTitle:@"Error"
                                                                    message:error.localizedDescription
                                                                    delegate:nil
                                                                    cancelButtonTitle:@"Ok"
                                                                    otherButtonTitles: nil];
                                              [alert show];
                                          }
                                          else if (session.isOpen){
                                              [self viewDidLoad];
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil){
        
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Invite Friend";
        self.friendPickerController.delegate = self;
        self.friendPickerController.allowsMultipleSelection = NO;
        [self.friendPickerController configureUsingCachedDescriptor:self.cacheDescriptor];
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];

}


- (void)loadFriends
{
    NSArray *friends = [[TMCache sharedCache] objectForKey:@"facebookFriends"];
    if (friends){
        self.facebookFriendsArray = friends;
    }
    else{
        [self.friend onlyFriendsUsingApp:^(BOOL wasSuccessful, NSArray *data) {
            if (wasSuccessful){
                 self.facebookFriendsArray = data;
            }
        }];
    }
    
}

- (FacebookFriends *)friend
{
    if (!_friend){
        _friend = [[FacebookFriends alloc] init];
    }
    
    return _friend;
}

#pragma -mark FBFRIENDS delegate


- (void)facebookViewControllerDoneWasPressed:(id)sender
{
 
    if (![self.friendPickerController.selection count] == 0){
        id<FBGraphUser> user = self.friendPickerController.selection[0];
        [self.friend inviteFriendWithID:user.id
                                  title:@"Cool Title"
                                message:@"Cool Message"
                                  block:^(BOOL wasSuccessful, FBWebDialogResult result) {
                                      if (wasSuccessful){
                                          NSLog(@"good invite");
                                      }
                                  }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)facebookViewControllerCancelWasPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
