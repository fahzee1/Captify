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
#import "UploaderAPIClient.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "ParseNotifications.h"
#import "SocialFriends.h"
#import "ContactsViewController.h"
#import <FacebookSDK/FacebookSDK.h>

#define SCROLLPICMULTIPLY_VALUE 100
#define SCROLLPICADD_VALUE 22

@interface SenderPreviewViewController ()<FBViewControllerDelegate,FBFriendPickerDelegate,ContactsControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIView *selectedContainerView;
@property (weak, nonatomic) IBOutlet UILabel *chooseFriendsLabel;

@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;

@property (weak, nonatomic) IBOutlet UILabel *facebookLabel;
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
    
    //self.name = @"Guess what im eating";
    //self.phrase = @"Nothing stupid";
    self.previewImage.image = [UIImage imageWithImage:self.image convertToSize:self.previewImage.frame.size];
    //self.friendsArray = @[@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM"];
    //self.facebookFriendsArray = @[@"dSanders21",@"theCantoon",@"darkness"];
 
    self.topLabel.text = self.name;
    self.sections = @[NSLocalizedString(@"Facebook", nil), NSLocalizedString(@"Contacts", nil)];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Sender Preview Screen";
    }
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
    
    
    UITapGestureRecognizer *tapC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedContacts)];
    tapC.numberOfTapsRequired = 1;
    tapC.numberOfTouchesRequired = 1;

    self.contactsLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.contactsLabel.textColor = [UIColor whiteColor];
    self.contactsLabel.layer.cornerRadius = 5;
    self.contactsLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.contactsLabel.text = [NSString stringWithFormat:@"%@   Contacts",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"]];
    self.contactsLabel.userInteractionEnabled = YES;
    [self.contactsLabel addGestureRecognizer:tapC];
    
    
    UITapGestureRecognizer *tapFB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFB)];
    tapFB.numberOfTapsRequired = 1;
    tapFB.numberOfTouchesRequired = 1;

    self.facebookLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] CGColor];
    self.facebookLabel.textColor = [UIColor whiteColor];
    self.facebookLabel.layer.cornerRadius = 5;
    self.facebookLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.facebookLabel.text = [NSString stringWithFormat:@"%@   Facebook",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"]];
    self.facebookLabel.userInteractionEnabled = YES;
    [self.facebookLabel addGestureRecognizer:tapFB];
    
    
    // the bottom send button
    [self.bottomSendButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
    self.bottomSendButton.layer.opacity = 0.6f;
    self.bottomSendButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:35];
    self.bottomSendButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    self.bottomSendButton.layer.cornerRadius = 5;
    self.bottomSendButton.userInteractionEnabled = NO;
    [self.bottomSendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];



}

- (void)tappedFB
{
    [self presentViewController:self.facebookScreen animated:YES completion:nil];
}

- (void)tappedContacts
{
  
    [self presentViewController:self.contactsScreen animated:YES completion:nil];

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
    // create challenge in backend
    // then in core data
    // then show history screen
    
    
    NSString *challenge_id = [Challenge createChallengeIDWithUser:[self.myUser.username stringByReplacingOccurrencesOfString:@"." withString:@"-"]];
    /*
    [Challenge saveImage:thumbnail filename:thumbnail_path];
    [Challenge saveImage:self.image filename:image_path];
     */
    
    
    
        // create challenge in backend
    
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.1);
    TICK;
    NSData *mediaData = [imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    TOCK;
    

    NSMutableDictionary *apiParams = [@{@"username": self.myUser.username,
                                @"is_picture":[NSNumber numberWithBool:YES],
                                @"name":self.name,
                                @"recipients":self.allFriends,
                                @"challenge_id":challenge_id,
                               } mutableCopy];
    
    NSString *mediaName = [NSString stringWithFormat:@"%@.jpg",challenge_id];
    if (mediaData){
        NSString *mediaName = [NSString stringWithFormat:@"%@.jpg",challenge_id];
        NSString *media = [NSString stringWithUTF8String:mediaData.bytes];
        apiParams[@"media"] = media;
        apiParams[@"media_name"] = mediaName;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Sending", nil);
    

    [Challenge sendCreateChallengeRequestWithParams:apiParams
                                              block:^(BOOL wasSuccessful, BOOL fail, NSString *message, id data) {
                                                  if (wasSuccessful){
                                                      NSUInteger count = [self.allFriends count];
                                                      NSString *media_url = [data valueForKey:@"media"];
                                                      
                                                      // save image locally in documents directory
                                                      NSString *localMediaName = [Challenge saveImage:imageData filename:mediaName];
    
                                                      NSDictionary *params = @{@"sender":self.myUser.username,
                                                                               @"context":self.myUser.managedObjectContext,
                                                                               @"recipients":self.allFriends,
                                                                               @"recipients_count":[NSNumber numberWithInteger:count],
                                                                               @"challenge_name":self.name,
                                                                               @"challenge_id":challenge_id,
                                                                               @"media_url":media_url,
                                                                               @"local_media_url":localMediaName};
                                                      
                                                      Challenge *challenge = [Challenge createChallengeWithRecipientsWithParams:params];
                                                      if (challenge){
                                                          [hud hide:YES];
                                                          
                                                          // send notification
                                                          [self notifyFriendsWithParams:params];
                                                          
                                                          // leave screen
                                                          [self notifyDelegateAndGoHome];
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
    
    
    
        NSLog(@"send challenge to %@",[self.selectedFacebookFriends description]);
    
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
    
    [p sendNotification:[NSString stringWithFormat:@"Challenge from %@",self.myUser.username]
              toFriends:self.selectedFacebookFriends
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


- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Error"
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [a show];
}






/*
#pragma -mark UItableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return [self.sections count];;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sections;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return [self.sections objectAtIndex:section];
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     // Return the number of rows in the section.
    
    if ([[self.sections objectAtIndex:section] isEqualToString:@"Facebook"]){
        
        // get count of facebook friends
        // return it
            return [self.facebookFriendsArray count];
    }
    
    else if ([[self.sections objectAtIndex:section] isEqualToString:@"Contact"]){
        // get count of contact friends
        // return it
            return [self.friendsArray count];
    }
    
    else{
        
        return [self.friendsArray count];
    }



}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;

    CellIdentifier = @"senderFriends";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = ((SenderFriendsCell *)cell).myFriendPic;
    UILabel *usernameLabel =  ((SenderFriendsCell *)cell).myFriendUsername;
    
    if (cell){
        
        if ([[self.sections objectAtIndex:indexPath.section] isEqualToString:@"Facebook"]){
            // retrurn cells for fbook friends
            User *friend = [self.facebookFriendsArray objectAtIndex:indexPath.row];
            usernameLabel.text = friend.username;
            usernameLabel.frame = CGRectMake(usernameLabel.frame.origin.x, usernameLabel.frame.origin.y, 200, 40);
            usernameLabel.numberOfLines = 0;
            [usernameLabel sizeToFit];
            
            NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small",friend.facebook_id];
            NSURL * fbUrl = [NSURL URLWithString:fbString];
            [imageView setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];

            
            
        }
        else if ([[self.sections objectAtIndex:indexPath.section] isEqualToString:@"Contacts"]){
            // return cells for contact friends
            User *friend = [self.friendsArray objectAtIndex:indexPath.row];
            usernameLabel.text = friend.username;
            usernameLabel.frame = CGRectMake(usernameLabel.frame.origin.x, usernameLabel.frame.origin.y, 200, 40);
            usernameLabel.numberOfLines = 0;
            [usernameLabel sizeToFit];

            ((SenderFriendsCell *)cell).myFriendPic.image = nil;
            FAImageView *imageView =  ((FAImageView *)((SenderFriendsCell *)cell).myFriendPic);
            [imageView setDefaultIconIdentifier:@"fa-user"];

        }

        // add this to list of cells that have checkmarks
        if ([self.selectedFriends[@"index_paths"] containsObject:indexPath]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }


    }

    
    return cell;
}
 */

/*

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

   // get correct type of friend
    User *friend;
    if ([[self.sections objectAtIndex:indexPath.section] isEqualToString:@"Facebook"]){
        friend = [self.facebookFriendsArray objectAtIndex:indexPath.row];
    }
    else{
        friend = [self.friendsArray objectAtIndex:indexPath.row];
    }
    
    
    // add/remove friend from selected list
    if ([self.selectedFriends[@"friends"] containsObject:friend.username]){
        
        // remove friends from list and their positions
        [self.selectedFriends[@"friends"] removeObject:friend.username];
        
        
    }
    else{
        // add user to selected list
        
        [self.selectedFriends[@"friends"] addObject:friend.username];
        
        
    
    }
    
    // add/remove indexpath of cells selected to add checkmarks
    // this list is used in cellforrowindexpath of tableview
    if (![self.selectedFriends[@"index_paths"] containsObject:indexPath]){
        [self.selectedFriends[@"index_paths"] addObject:indexPath];
        
    }
    else{
        [self.selectedFriends[@"index_paths"] removeObject:indexPath];
    }

    // if selected friend list is empty show "choose friends" label
    // else remove label and show send button
    NSUInteger count = [self.selectedFriends[@"friends"] count];
    if (!count == 0){
        self.bottomSendButton.userInteractionEnabled = YES;
        self.bottomSendButton.layer.opacity = 1.0f;
        NSString *sendString = [NSString stringWithFormat:@"Send to %lu friends",(unsigned long)count];
        [self.bottomSendButton setTitle:NSLocalizedString(sendString, nil) forState:UIControlStateNormal];
        
    }
    else{
        self.bottomSendButton.userInteractionEnabled = NO;
        self.bottomSendButton.layer.opacity = 0.6f;
        [self.bottomSendButton setTitle:NSLocalizedString(@"Choose Friends", nil) forState:UIControlStateNormal];
    }
    
    // reload to show checkmarks
    [tableView reloadData];
   
}
*/

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
        [self.allFriends addObjectsFromArray:self.selectedContactFriends];
        [self.allFriends addObjectsFromArray:self.facebookFriendsArray];
        
        [self editSendButton];
        
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
    
    
    //NSLog(@"%@",self.selectedFriends[@"friends"]);
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.allFriends addObjectsFromArray:self.selectedContactFriends];
        [self.allFriends addObjectsFromArray:self.facebookFriendsArray];
        
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
        NSString *fbID = user[@"id"];
        NSDictionary *params = @{@"username": user[@"name"],
                                 @"facebook_user":[NSNumber numberWithBool:YES],
                                 @"facebook_id":[NSNumber numberWithInt:[fbID intValue]],
                                 };
        
        NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
        
        [User createFriendWithParams:params inMangedObjectContext:context];
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
    
    self.facebookFriendsArray = friendPicker.selection;
    [friendPicker clearSelection];
    

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
