//
//  SenderPreviewViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AppDelegate.h"
#import "SenderPreviewViewController.h"
#import "UIColor+HexValue.h"
#import "UIImage+Utils.h"
#import "SenderFriendsCell.h"
#import "FAImageView.h"
#import "Challenge+Utils.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "ParseNotifications.h"
#import "SocialFriends.h"
#import "ContactsViewController.h"
#import "MBProgressHUD.h"
#import "TWTSideMenuViewController.h"
#import "MenuViewController.h"
#import <FacebookSDK/FacebookSDK.h>

#define SCROLLPICMULTIPLY_VALUE 100
#define SCROLLPICADD_VALUE 22

@interface SenderPreviewViewController ()<FBViewControllerDelegate,FBFriendPickerDelegate,ContactsControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIView *selectedContainerView;
@property (weak, nonatomic) IBOutlet UILabel *chooseFriendsLabel;

@property (weak, nonatomic) IBOutlet UIButton *contactsButton;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic)NSMutableArray *selectedFacebookFriends;
@property (strong, nonatomic)NSMutableArray *selectedContactFriends;
@property (strong, nonatomic)NSMutableArray *allFriends;

@property (strong, nonatomic) NSArray *facebookFriendsArray;
@property (strong, nonatomic)IBOutlet UIButton *bottomSendButton;
@property CGPoint scrollStart;
@property (strong, nonatomic)NSArray *sections;
@property NSString *localMediaName;
@property (strong,nonatomic) UIViewController *contactsScreen;
@property (strong,nonatomic) FBFriendPickerViewController *facebookScreen;
@property (strong,nonatomic) UIView *errorContainerView;


@end

@implementation SenderPreviewViewController

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
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popToPreview)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = NSLocalizedString(@"Preview", nil);
    
    [self setupStyles];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.name = @"Guess what im eating";
    //self.phrase = @"Nothing stupid";
    self.previewImage.image = [UIImage imageWithImage:self.image convertToSize:self.previewImage.frame.size];
    //self.friendsArray = @[@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM"];
    //self.facebookFriendsArray = @[@"dSanders21",@"theCantoon",@"darkness"];
 
    self.topLabel.text = self.name;
    self.sections = @[NSLocalizedString(@"Facebook", nil), NSLocalizedString(@"Contacts", nil)];
    if (!IS_IPHONE5){
        self.scrollView.contentSize = CGSizeMake(320, 675);
    }
    else{
        self.scrollView.contentSize = CGSizeMake(320, 620);
    }
    

    self.automaticallyAdjustsScrollViewInsets = NO;
    
   
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Sender Preview Screen";
    }
    

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];


    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]){
        if (self.delegate){
            if ([self.delegate respondsToSelector:@selector(previewscreenDidMoveBack)]){
                [self.delegate previewscreenDidMoveBack];
            }
        }
    }
}

- (void)dealloc
{


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog(@"received memory warning here");
    
    self.myUser = nil;
}

- (void)popToPreview
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupStyles
{
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.topLabel.textColor = [UIColor whiteColor];
    self.topLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] CGColor];
    self.topLabel.layer.borderWidth = 2;
    self.topLabel.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    self.topLabel.layer.cornerRadius = 5;
    if ([self.name length] > 30){
        self.topLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:15];
    }
    else{
        self.topLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:17];
    }
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.numberOfLines = 0;
    [self.topLabel sizeToFit];
    self.topLabel.frame = CGRectMake(self.topLabel.frame.origin.x,
                                     self.topLabel.frame.origin.y,
                                     [UIScreen mainScreen].bounds.size.width,
                                     self.topLabel.frame.size.height);
    
    CGRect labelFrame = self.topLabel.frame;
    labelFrame.size.height += 10;
    self.topLabel.frame = labelFrame;
    

    self.selectedContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    self.selectedContainerView.layer.cornerRadius = 5;
    self.chooseFriendsLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:15];
    
    
 

    self.contactsButton.backgroundColor = [UIColor clearColor];
    [self.contactsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contactsButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] forState:UIControlStateHighlighted];
    self.contactsButton.layer.cornerRadius = 5;
    self.contactsButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:17];
    self.contactsButton.titleLabel.text = NSLocalizedString(@"Contacts", nil);
    self.contactsButton.layer.borderWidth = 3;
    self.contactsButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] CGColor];



    [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.facebookButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] forState:UIControlStateHighlighted];
    self.facebookButton.layer.cornerRadius = 5;
    self.facebookButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:17];
    self.facebookButton.titleLabel.text = NSLocalizedString(@"Facebook", nil);
    self.facebookButton.backgroundColor = [UIColor clearColor];
    self.facebookButton.layer.borderWidth = 3;
    self.facebookButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] CGColor];

    


    
    if ([self.myUser.facebook_user intValue] == 1){
        self.facebookButton.userInteractionEnabled = YES;
    }
    else{
        self.facebookButton.layer.opacity = 0.6f;
        self.facebookButton.userInteractionEnabled = NO;
    }
    
    
    
    // the bottom send button
    [self.bottomSendButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
    self.bottomSendButton.layer.opacity = 0.6f;
    self.bottomSendButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
    self.bottomSendButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    self.bottomSendButton.layer.cornerRadius = 5;
    self.bottomSendButton.userInteractionEnabled = NO;
    [self.bottomSendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];



}

- (IBAction)tappedContacts:(UIButton *)sender
{
    [self presentViewController:self.contactsScreen animated:YES completion:nil];

}


- (IBAction)tappedFacebook:(UIButton *)sender
{
    [self presentViewController:self.facebookScreen animated:YES completion:nil];
}




- (UIImage *)createThumbnailWithSize:(CGSize)size
{
    UIImage *thumbnail = [UIImage imageWithImage:self.image convertToSize:size];
    return thumbnail;
    
}

- (void)saveImage:(UIImage *)image
           filename:(NSString *)name
{
    // filename can be /test/another/test.jpg
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
        NSData* data = UIImageJPEGRepresentation(image, 0.9);
        [data writeToFile:path atomically:YES];
    }
}


- (UIImage *)loadImagewithFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}


- (void)sendButtonTapped:(UIButton *)sender
{
 
    UIActionSheet *popUp = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Send", nil), nil];
    
    [popUp showFromRect:self.bottomSendButton.frame inView:self.view animated:YES];
}



- (void)sendChallenge
{
    // create challenge in backend
    // then in core data
    // then show history screen
    
    
    NSString *challenge_id = [Challenge createChallengeIDWithUser:[self.myUser.username stringByReplacingOccurrencesOfString:@"." withString:@"-"]];
    /*
    [Challenge saveImage:thumbnail filename:thumbnail_path];
    [Challenge saveImage:self.image filename:image_path];
     */
    
    
    
        // create challenge in backend
    float compression;
    if (!IS_IPHONE5){
        compression = 0.5;
    }
    else{
        compression = 0.3;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(self.image, compression);
    NSData *mediaData = [imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSMutableDictionary *apiParams;
    NSString *mediaName;
    @try {
        apiParams = [@{@"username": self.myUser.username,
                        @"is_picture":[NSNumber numberWithBool:YES],
                        @"name":self.name,
                        @"recipients":self.allFriends,
                        @"challenge_id":challenge_id,
                        } mutableCopy];
        
        mediaName = [NSString stringWithFormat:@"%@.jpg",challenge_id];
        if (mediaData){
            mediaName = [NSString stringWithFormat:@"%@.jpg",challenge_id];
            NSString *media = [NSString stringWithUTF8String:mediaData.bytes];
            apiParams[@"media"] = media;
            apiParams[@"media_name"] = mediaName;
        }
        


    }
    @catch (NSException *exception) {
        DLog(@"%@",exception);
    }
    
 

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Sending", nil);
    hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    hud.detailsLabelText = NSLocalizedString(@"Challenges are active for 24 hours", nil);
    hud.detailsLabelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    hud.color = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.8];
    hud.dimBackground = YES;
 

    
    if ([apiParams count] > 0 && mediaName){

        [Challenge sendCreateChallengeRequestWithParams:apiParams
                                                  block:^(BOOL wasSuccessful, BOOL fail, NSString *message, id data) {
                                                      if (wasSuccessful){
                                                          NSUInteger count = [self.allFriends count];
                                                          NSString *media_url = [data valueForKey:@"media"];
                                                          
                                                          // save image locally in documents directory
                                                          NSString *localMediaName = [Challenge saveImage:imageData filename:mediaName];
        
                                                          Challenge *challenge;
                                                          NSDictionary *params;
                                                          @try {
                                                              params = @{@"sender":self.myUser.username,
                                                                           @"context":self.myUser.managedObjectContext,
                                                                           @"recipients":self.allFriends,
                                                                           @"recipients_count":[NSNumber numberWithInteger:count],
                                                                           @"challenge_name":self.name,
                                                                           @"challenge_id":challenge_id,
                                                                           @"media_url":media_url,
                                                                           @"local_media_url":localMediaName,
                                                                          @"active":[NSNumber numberWithBool:YES]};
                                                              
                                                              challenge = [Challenge createChallengeWithRecipientsWithParams:params];

                                                          }
                                                          @catch (NSException *exception) {
                                                              DLog(@"%@",exception);
                                                          }
                                                          @finally {
                                                              if (challenge){
                                                                  
                                                                  [self.myUser addSent_challengesObject:challenge];
                                                                  NSError *e;
                                                                  [self.myUser.managedObjectContext save:&e];
                                                                  
                                                                  [hud hide:YES];
                                                                  
                                                                  // send notification
                                                                  [self notifyFriendsWithParams:params];
                                                                  
                                                                  // leave screen
                                                                  [self notifyDelegateAndGoHome];
                                                              }

                                                          }
                                                          
                                                          
                                                      }
                                                      else{
                                                          [hud hide:YES];
                                                          if (fail){
                                                              // 500
                                                              if (message){
                                                                  [self showAlertWithMessage:message];
                                                              }
                                                              else{
                                                                  [self showAlertWithMessage:@"There was an error sending your request"];
                                                              }
                                                          }
                                                          else{
                                                              // 200 but error
                                                              [self showAlertWithMessage:@"There was an error sending your request"];
                                                          }
                                                          

                                                      }
                                                  }];
        
    
    }
    
}

- (void)editSendButton
{
    if ([self.allFriends count] > 0){
        self.bottomSendButton.layer.opacity = 1.f;
        self.bottomSendButton.userInteractionEnabled = YES;
        NSInteger count = [self.allFriends count];
        if (count == 1){
            [self.bottomSendButton setTitle:[NSString stringWithFormat:@"Send to %@ Friend",[NSNumber numberWithInteger:count]] forState:UIControlStateNormal];
        }
        else{
            [self.bottomSendButton setTitle:[NSString stringWithFormat:@"Send to %@ Friends",[NSNumber numberWithInteger:count ]] forState:UIControlStateNormal];
        }
        
    }
    else{
        [self.bottomSendButton setTitle:[NSString stringWithFormat:@"Send"] forState:UIControlStateNormal];
        self.bottomSendButton.layer.opacity = 0.6f;
        self.bottomSendButton.userInteractionEnabled = NO;
    }

    
}

- (void)notifyFriendsWithParams:(NSDictionary *)params
{
    ParseNotifications *p = [[ParseNotifications alloc] init];
    
    [p sendNotification:[NSString stringWithFormat:@"Caption challenge from %@",[self.myUser.username stringByReplacingOccurrencesOfString:@"-" withString:@" "]]
              toFriends:self.allFriends
               withData:params
       notificationType:ParseNotificationCreateChallenge
                  block:nil];
    
    [p addChannelWithChallengeID:params[@"challenge_id"]];

    /*
     [p sendTestNotification:@"Cj you should see this"
     withData:@{@"challenge_name": self.name}
     notificationType:ParseNotificationCreateChallenge
     block:nil];
     */
     
    

}


- (void)notifyDelegateAndGoHome
{
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(previewscreenFinished)]){
            [self.delegate previewscreenFinished];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }

    
}

- (void)showFacebookInvite
{
    /*
    [self dismissViewControllerAnimated:YES completion:^{
        UIViewController *menu = self.sideMenuViewController.menuViewController;
        if ([menu isKindOfClass:[MenuViewController class]]){
            [((MenuViewController *)menu) updateCurrentScreen:MenuFriendsScreen];
        }
        
        UIViewController *inviteScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"friendContainerRoot"];
        [self.sideMenuViewController setMainViewController:inviteScreen animated:YES closeMenu:NO];
    }];
     */
    [self dismissViewControllerAnimated:YES completion:^{
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[INVITE_TEXT] applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
        [self presentViewController:activityVC animated:YES completion:nil];

    }];
    
}


- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [a show];
}



#pragma -mark uiactionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        [self sendChallenge];
    }
}


#pragma -mark Contacts delegate

- (void)ContactViewControllerPressedCancel:(ContactsViewController *)controller
{
    [controller clearSelections];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)ContactViewControllerPressedDone:(ContactsViewController *)controller
{
    self.allFriends = nil;
    if (self.selectedContactFriends){
        self.selectedContactFriends = [@[] mutableCopy];
    }
    
    self.selectedContactFriends = controller.selection;
    [self dismissViewControllerAnimated:YES completion:^{
        @try {
            [self.allFriends addObjectsFromArray:self.selectedContactFriends];
            [self.allFriends addObjectsFromArray:self.selectedFacebookFriends];
            
            [self editSendButton];
        }
        @catch (NSException *exception) {
            DLog(@"%@",exception);
        }
        
        
    }];

}


- (void)ContactViewControllerDataChanged:(ContactsViewController *)controller
{
    //self.selectedContactFriends = controller.selection;
}

#pragma -mark FBFRIENDS delegate


- (void)facebookViewControllerDoneWasPressed:(id)sender
{
 
    
    self.selectedFacebookFriends = nil;
    self.allFriends = nil;
    
    for (NSDictionary *friend in self.facebookFriendsArray){
        NSString *first = friend[@"first_name"];
        NSString *second = friend[@"last_name"];
        NSString *username = [NSString stringWithFormat:@"%@-%@",first,second];
        
        [self.selectedFacebookFriends addObject:username];
    }
    
    
   
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.allFriends addObjectsFromArray:self.selectedContactFriends];
        [self.allFriends addObjectsFromArray:self.selectedFacebookFriends];
        
        [self editSendButton];


    }];
}


- (void)facebookViewControllerCancelWasPressed:(id)sender{
    
    [self.facebookScreen clearSelection];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker shouldIncludeUser:(id<FBGraphUser>)user
{
    /*
    if (friendPicker == self.facebookScreen){
        BOOL installed = [user objectForKey:@"installed"] != nil;
        return installed;
    }
    else{
        return YES;
    }
     */
    
    NSString *name = user[@"name"];
    BOOL should = [name hasPrefix:@"A"];
    if (should){
        @try {
            NSString *fbID = user[@"id"];
            NSDictionary *params = @{@"username": user[@"name"],
                                     @"facebook_user":[NSNumber numberWithBool:YES],
                                     @"facebook_id":fbID,
                                     };
            
            NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
            
            [User createFriendWithParams:params inMangedObjectContext:context];

        }
        @catch (NSException *exception) {
            DLog(@"%@",exception);
        }
    }
    
    return should;
    
#warning uncomment this to make sure only friends using app are shown.. mauybe show button to invite if none
    
    return YES;
}

- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker handleError:(NSError *)error
{
    [self alertErrorWithTitle:nil andMessage:error.localizedDescription];
    
}

- (void)friendPickerViewControllerDataDidChange:(FBFriendPickerViewController *)friendPicker
{
    // check to see if the rows in each section are empty
    // to show correct message
    
    if (friendPicker == self.facebookScreen){
        BOOL empty = YES;
        NSInteger sectionCount = [friendPicker.tableView numberOfSections];
        for (NSInteger i = 0; i < sectionCount; i++){
            if (![friendPicker.tableView numberOfRowsInSection:i] == 0){
                empty = NO;
            }
        }
        
        if (empty){
            // add subview with error message
            //self.facebookScreen.tableView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];

            [friendPicker.tableView removeFromSuperview];
            [friendPicker.view addSubview:self.errorContainerView];
            friendPicker.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];

            
        }
        else{
            self.facebookScreen.tableView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    
}

- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
    
    self.facebookFriendsArray = friendPicker.selection;
    //[friendPicker clearSelection];
    

}

- (NSMutableArray *)selectedContactFriends
{
    if (!_selectedContactFriends){
        _selectedContactFriends = [[NSMutableArray alloc] init];
    }
    
    return _selectedContactFriends;
}


- (NSMutableArray *)selectedFacebookFriends
{
    if (!_selectedFacebookFriends){
        _selectedFacebookFriends = [[NSMutableArray alloc] init];
    }
    
    return _selectedFacebookFriends;
}


- (NSMutableArray *)allFriends
{
    if (!_allFriends){
        _allFriends = [[NSMutableArray alloc] init];
    }
    
    return _allFriends;
}



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

- (UIViewController *)contactsScreen
{
    if (!_contactsScreen){
        UIViewController *contactScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"contactFriends"];
        _contactsScreen = [[UINavigationController alloc] initWithRootViewController:contactScreen];
        if ([contactScreen isKindOfClass:[ContactsViewController class]]){
            ((ContactsViewController *)contactScreen).delegate = self;
        }
    }
    
    return _contactsScreen;
}

- (FBFriendPickerViewController *)facebookScreen
{
    if (!_facebookScreen){
        NSSet *fields = [NSSet setWithObjects:@"installed", nil];
        _facebookScreen = [[FBFriendPickerViewController alloc] init];
        _facebookScreen.title = @"Select Friends";
        _facebookScreen.delegate = self;
        _facebookScreen.allowsMultipleSelection = YES;
        _facebookScreen.fieldsForRequest = fields;
        [_facebookScreen loadData];
        
    }
    
    
    return _facebookScreen;
}

- (UIView *)errorContainerView
{
    if (!_errorContainerView){
        _errorContainerView = [[UIView alloc] initWithFrame:self.facebookScreen.tableView.frame];
        _errorContainerView.layer.cornerRadius = 10;
        _errorContainerView.layer.masksToBounds = YES;
        _errorContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        
        CGRect containerFrame = _errorContainerView.frame;
        containerFrame.size.width -= 15;
        containerFrame.size.height -= 250;
        containerFrame.origin.y += 150;
        containerFrame.origin.x += 7;
        _errorContainerView.frame = containerFrame;
        
        
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        errorLabel.text = @"None of your facebook friends are on Captify! Tell some friends to Join!";
        errorLabel.numberOfLines = 0;
        [errorLabel sizeToFit];
        errorLabel.textColor = [UIColor whiteColor];
        errorLabel.frame = CGRectMake(15, 50, _errorContainerView.frame.size.width-20, 100);
        
        UIButton *invite = [UIButton buttonWithType:UIButtonTypeSystem];
        invite.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
        invite.layer.cornerRadius = 10;
        invite.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        [invite setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
        [invite setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
        invite.frame = CGRectMake(50, _errorContainerView.bounds.size.height - 90, 200, 50);
        [invite addTarget:self action:@selector(showFacebookInvite) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (!IS_IPHONE5){
            CGRect inviteFrame = invite.frame;
            containerFrame.origin.y -= 40;
            containerFrame.size.height += 25;
            inviteFrame.origin.y += 100;
            _errorContainerView.frame = containerFrame;
            invite.frame = inviteFrame;
            
        }

        
        [_errorContainerView addSubview:errorLabel];
        [_errorContainerView addSubview:invite];
        
    }
    
    return _errorContainerView;
}



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




@end
