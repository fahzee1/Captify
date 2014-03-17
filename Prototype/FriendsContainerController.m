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
#import "SocialFriends.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "SearchFriendsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Contacts.h"

@interface FriendsContainerController ()<FBViewControllerDelegate,FBFriendPickerDelegate, TWTSideMenuViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (strong,nonatomic)UIViewController *currentController;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) FBFriendPickerViewController *appFriendPickerController;
@property (strong, nonatomic) SocialFriends *friend;
@property (strong, nonatomic) FBCacheDescriptor *cacheDescriptor;
@property (strong, nonatomic) FBCacheDescriptor *appCacheDescriptor;

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
    self.sideMenuViewController.delegate = self;
    
    UIViewController *vc = [self viewControllerForSegmentIndex:self.mySegmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.myContainerView.bounds;
    [self.myContainerView addSubview:vc.view];
    self.currentController = vc;
    
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25]} forState:UIControlStateNormal];
    
   
    self.navigationItem.leftBarButtonItem = button;
    self.navigationItem.title = NSLocalizedString(@"Friends", nil);
    
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Facebook", nil) forSegmentAtIndex:0];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Contacts", nil) forSegmentAtIndex:1];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Invite", nil) forSegmentAtIndex:2];
    [self.mySegmentedControl setTitle:NSLocalizedString(@"Search", nil) forSegmentAtIndex:3];
    
    self.cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
    [self.cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
    
    self.appCacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
    [self.appCacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
    
    Contacts *c = [[Contacts alloc] init];
    [c fetchContactsWithBlock:^(BOOL done, id data) {
        if (done){
               NSLog(@"%@",data);
        }
    }];
   

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
            vc = self.appFriendPickerController;
            
            [self.appFriendPickerController loadData];
            [self.appFriendPickerController clearSelection];
        }

            break;
        case 1:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"contactFriends"];
        }
            break;
        case 2:
        {
            vc = self.friendPickerController;
            
            [self.friendPickerController loadData];
            [self.friendPickerController clearSelection];
        }
            break;
            
        case 3:
        {
    
            vc =  vc = [self.storyboard instantiateViewControllerWithIdentifier:@"searchFriends"];
        }
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
                                              [self alertErrorWithTitle:nil
                                                             andMessage:error.localizedDescription];
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

/*
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
 */


- (void)alertErrorWithTitle:(NSString *)title
                 andMessage:(NSString *)message
{
    if (!title){
        title = @"Error";
    }
    
    if (!message){
        message = @"There was an error with your connection";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    
    
}


- (FBFriendPickerViewController *)friendPickerController
{

    if (!_friendPickerController){
        _friendPickerController = [[FBFriendPickerViewController alloc] init];
        _friendPickerController.title = @"Invite Friend";
        _friendPickerController.delegate = self;
        _friendPickerController.allowsMultipleSelection = NO;
        [_friendPickerController configureUsingCachedDescriptor:self.cacheDescriptor];

        
    }
    
    return  _friendPickerController;
}

- (FBFriendPickerViewController *)appFriendPickerController{
    if (!_appFriendPickerController){
        NSSet *fields = [NSSet setWithObjects:@"installed", nil];
        _appFriendPickerController = [[FBFriendPickerViewController alloc] init];
        _appFriendPickerController.title = @"Facebook Friends";
        _appFriendPickerController.delegate = self;
        _appFriendPickerController.allowsMultipleSelection = NO;
        _appFriendPickerController.fieldsForRequest = fields;
        //[_appFriendPickerController configureUsingCachedDescriptor:self.appCacheDescriptor];
        
        
    }
    
    return  _appFriendPickerController;
}

- (SocialFriends *)friend
{
    if (!_friend){
        _friend = [[SocialFriends alloc] init];
    }
    
    return _friend;
}



#pragma -mark side menu delegate

- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    if ([self.currentController isKindOfClass:[SearchFriendsViewController class]]){
        [((SearchFriendsViewController *)self.currentController) slideDownKeyboard];
    }
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

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user
{
    if (friendPicker == self.appFriendPickerController){
        BOOL installed = [user objectForKey:@"installed"] != nil;
        return installed;
    }
    else{
        return YES;
    }
}

- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker handleError:(NSError *)error
{
    [self alertErrorWithTitle:nil andMessage:error.localizedDescription];
    
}

- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker
{
    // check to see if the rows in each section are empty
    // to show correct message
    
    if (friendPicker == self.appFriendPickerController){
        BOOL empty = YES;
        NSInteger sectionCount = [friendPicker.tableView numberOfSections];
        for (NSInteger i = 0; i < sectionCount; i++){
            if (![friendPicker.tableView numberOfRowsInSection:i] == 0){
                empty = NO;
            }
        }
        
        if (empty){
            // add subview with error message 
            UILabel *faceLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 150, 150)];
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
            
            faceLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:60];
            faceLabel.textColor = [UIColor redColor];
            faceLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-frown-o"];
            faceLabel.center = CGPointMake(200 , 100);
            
            textLabel.text = @"None of your facebook friends are using the app, you should invite them!";
            textLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:14];
            textLabel.center = CGPointMake(170, 230);
            textLabel.numberOfLines = 0;
            [textLabel sizeToFit];
            
            [friendPicker.tableView addSubview:faceLabel];
            [friendPicker.tableView addSubview:textLabel];
            
        }
    }
    
    
}

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
    // send friend invite request when tapped
    if (![friendPicker.selection count] == 0){
        NSString *friendID = [friendPicker.selection[0] objectForKey:@"id"];
        NSString *name = [friendPicker.selection[0] objectForKey:@"name"];
       [self.friend inviteFriendWithID:friendID
                                 title:@"Invite"
                               message:[NSString stringWithFormat:@"Hey %@ you should try this app",name]
                                 block:^(BOOL wasSuccessful, FBWebDialogResult result) {
                                     if (wasSuccessful){
                                         NSLog(@"success");
                                     }
                                 }];
    }
}






@end
