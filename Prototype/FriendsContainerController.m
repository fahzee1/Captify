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
#import "AppDelegate.h"
#import "UIColor+HexValue.h"
#import "User+Utils.h"
#import "MenuViewController.h"

@interface FriendsContainerController ()<FBViewControllerDelegate,FBFriendPickerDelegate, TWTSideMenuViewControllerDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (strong,nonatomic)UIViewController *currentController;
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) FBFriendPickerViewController *appFriendPickerController;
@property (strong, nonatomic) SocialFriends *friend;
@property (strong, nonatomic) FBCacheDescriptor *cacheDescriptor;
@property (strong, nonatomic) FBCacheDescriptor *appCacheDescriptor;
@property (strong, nonatomic) NSArray *selectedFriends;
@property (strong, nonatomic) NSMutableArray *selectedIDS;



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
    
    self.cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
    [self.cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];

    
    UIViewController *vc = self.friendPickerController;
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    [self addChildViewController:vc];
    vc.view.frame = self.myContainerView.frame;
    [self.myContainerView addSubview:vc.view];
    self.currentController = vc;

    
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    UIBarButtonItem *invite = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(inviteFriendsFromList)];
    [invite setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:17],
                                     NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
   
    self.navigationItem.leftBarButtonItem = button;
    self.navigationItem.rightBarButtonItem = invite;
    self.navigationItem.title = NSLocalizedString(@"Invite", nil);
    [self.navigationController setToolbarHidden:YES];
    
    
    
       
    
}

- (void)dealloc
{
    self.friend = nil;
    self.myUser = nil;
    self.friendPickerController = nil;
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

- (void)inviteFriendsFromList
{
    
    if ([self.selectedFriends count] > 0){
        for (NSDictionary *dict in self.selectedFriends){
            [self.selectedIDS addObject:dict[@"id"]];
        }
        
        
        NSString *friends = [self.selectedIDS componentsJoinedByString:@","];
        [self.friend inviteFriendWithID:friends
                                  title:@"Invite"
                                message:[NSString stringWithFormat:@"Hey send me a caption on Captify!"]
                                  block:^(BOOL wasSuccessful, FBWebDialogResult result) {
                                      if (wasSuccessful){
                                          DLog(@"success");
                                      }
                                      [self.friendPickerController clearSelection];
                                  }];

        // reset
        [self.friendPickerController clearSelection];
        self.selectedFriends = nil;
        self.selectedIDS = nil;
    }
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



#pragma -mark side menu delegate

- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    if ([self.currentController isKindOfClass:[SearchFriendsViewController class]]){
        [((SearchFriendsViewController *)self.currentController) slideDownKeyboard];
        
    }
    
    UIViewController *menu = self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) setupColors];
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
                                          DLog(@"good invite");
                                      }
                                  }];
    }
    
    [self.friendPickerController clearSelection];
    //[self.friendPickerController updateView];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)facebookViewControllerCancelWasPressed:(id)sender{
    
    [self.friendPickerController clearSelection];
    //[self.friendPickerController updateView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user
{
    if (friendPicker == self.appFriendPickerController){
        BOOL installed = [user objectForKey:@"installed"] == nil;
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
        self.selectedFriends = friendPicker.selection;

    
}
 
 


- (FBFriendPickerViewController *)friendPickerController
{
    
    if (!_friendPickerController){
        _friendPickerController = [[FBFriendPickerViewController alloc] init];
        _friendPickerController.title = @"Invite Friend";
        _friendPickerController.delegate = self;
        _friendPickerController.allowsMultipleSelection = YES;
        [_friendPickerController configureUsingCachedDescriptor:self.cacheDescriptor];
        
        CGRect frame =  _friendPickerController.tableView.frame;
        frame.origin.y -= 7;
        _friendPickerController.tableView.frame = frame;

        
    }
    //_friendPickerController.tableView.delegate = self;
    _friendPickerController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([_friendPickerController.tableView respondsToSelector:@selector(setSectionIndexColor:)]){
        //_friendPickerController.tableView.sectionIndexBackgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        //_friendPickerController.tableView.sectionIndexColor = [UIColor whiteColor];
        //_friendPickerController.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    }
    return  _friendPickerController;
}



- (SocialFriends *)friend
{
    if (!_friend){
        _friend = [[SocialFriends alloc] init];
    }
    
    return _friend;
}


#pragma -mark Lazy inst
- (User *)myUser
{
    if (!_myUser){
        NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
        NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
        if (uri){
            NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
            NSError *error;
            _myUser = (id) [context existingObjectWithID:superuserID error:&error];
        }
        
    }
    return _myUser;
}

- (NSArray *)selectedFriends
{
    if (!_selectedFriends){
        _selectedFriends = [NSArray array];
    }
    
    return _selectedFriends;
}

- (NSMutableArray *)selectedIDS
{
    if (!_selectedIDS){
        _selectedIDS = [NSMutableArray array];
    }
    
    return _selectedIDS;
}



@end
