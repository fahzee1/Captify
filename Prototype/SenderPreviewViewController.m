//
//  SenderPreviewViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SenderPreviewViewController.h"
#import "UIColor+HexValue.h"
#import "UIImage+Utils.h"
#import "SenderFriendsCell.h"
#import "FAImageView.h"
#import "Challenge+Utils.h"
#import "AppDelegate.h"
#import "UploaderAPIClient.h"
#import "UIImageView+WebCache.h"

typedef void (^SendChallengeRequestBlock) (BOOL wasSuccessful,BOOL fail, NSString *message);

#define SCROLLPICMULTIPLY_VALUE 100
#define SCROLLPICADD_VALUE 22

@interface SenderPreviewViewController ()<UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (strong, nonatomic)NSMutableDictionary *selectedFriends;
@property (strong, nonatomic)NSMutableDictionary *selectedPositions;
@property (strong, nonatomic) NSArray *friendsArray;
@property (strong, nonatomic) NSArray *facebookFriendsArray;
@property (strong, nonatomic)IBOutlet UIButton *bottomSendButton;
@property CGPoint scrollStart;
@property (strong, nonatomic)NSArray *sections;





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
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = NSLocalizedString(@"Preview", nil);
    self.friendsTable.delegate = self;
    self.friendsTable.dataSource = self;
    
    [self setupStyles];
    
    //self.name = @"Guess what im eating";
    //self.phrase = @"Nothing stupid";
    self.previewImage.image = [UIImage imageWithImage:self.image convertToSize:self.previewImage.frame.size];
    //self.friendsArray = @[@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM"];
    //self.facebookFriendsArray = @[@"dSanders21",@"theCantoon",@"darkness"];
 
    self.selectedFriends = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[@[]mutableCopy],@"friends",
                                                                               [@[]mutableCopy],@"index_paths",
                                                                               nil];
    self.selectedPositions = [[NSMutableDictionary alloc] init];
    self.topLabel.text = self.name;
    self.sections = @[NSLocalizedString(@"Facebook", nil), NSLocalizedString(@"Contacts", nil)];
    
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
    if (self.friendsTable.delegate == self){
        self.friendsTable.delegate = nil;
    }
    
    if (self.friendsTable.dataSource == self){
        self.friendsTable.dataSource = nil;
    }

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyles
{
    
    
    self.topLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#3498db"] CGColor];
    self.topLabel.textColor = [UIColor whiteColor];
    self.topLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    
    
    // the bottom send button
    [self.bottomSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bottomSendButton.layer.opacity = 0.6f;
    self.bottomSendButton.titleLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    self.bottomSendButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.bottomSendButton.userInteractionEnabled = NO;
    [self.bottomSendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];



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
#warning show progress hud here
    
    
    NSString *challenge_id = [Challenge createChallengeIDWithUser:self.myUser.username];
    /*
    [Challenge saveImage:thumbnail filename:thumbnail_path];
    [Challenge saveImage:self.image filename:image_path];
     */
    
    
    
        // create challenge in backend
    
    NSDictionary *apiParams = @{@"username": self.myUser.username,
                                @"is_picture":[NSNumber numberWithBool:YES],
                                @"name":self.name,
                                @"recipients":self.selectedFriends[@"friends"],
                                @"challenge_id":challenge_id};
    
 
    
    [self sendCreateChallengeRequest:apiParams image:UIImageJPEGRepresentation(self.image, 1) block:^(BOOL wasSuccessful,BOOL fail, NSString *message) {
        if (wasSuccessful){
            NSString *image_path = [NSString stringWithFormat:@"challenges/image-%@.jpg",challenge_id];
            NSUInteger count = [self.selectedFriends[@"friends"] count];
            NSDictionary *params = @{@"sender":self.myUser.username,
                                     @"context":self.myUser.managedObjectContext,
                                     @"recipients":self.selectedFriends[@"friends"],
                                     @"recipients_count":[NSNumber numberWithInteger:count],
                                     @"challenge_name":self.name,
                                     @"challenge_id":challenge_id,
                                     @"image_path":image_path};

            Challenge *challenge = [Challenge createChallengeWithRecipientsWithParams:params];
            if (challenge){
                [self notifyDelegateAndGoHome];
            }
            
            
        }
        else{
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
    
    
        NSLog(@"send challenge to %@",[self.selectedFriends[@"friends"] description]);
    
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

- (void)sendCreateChallengeRequest:(NSDictionary *)params
                             image:(NSData *)image
                             block:(SendChallengeRequestBlock)block
{
    UploaderAPIClient *client = [UploaderAPIClient sharedClient];
    client.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *apiString = [defaults valueForKey:@"apiString"];
    [client.requestSerializer setValue:apiString forHTTPHeaderField:@"Authorization"];
    if ([client connected]){
            [client startNetworkActivity];
            [client POST:AwesomeAPIChallengeCreateString parameters:params
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:image name:@"media" fileName:@"test.jpg" mimeType:@"image/jpeg"];
       }
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [client stopNetworkActivity];
                     NSLog(@"%@",responseObject);
                     int code = [[responseObject valueForKey:@"code"] intValue];
                     if (code == 1){
                         NSLog(@"true success");
                         if (block){
                             block(YES,NO,[responseObject valueForKey:@"message"]);
                         }
                     }
                     if (code == -10){
                         [self showAlertWithMessage:@"There was an error with your request."];
                         if (block){
                             block(NO,NO,[responseObject valueForKey:@"message"]);
                         }
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     [client stopNetworkActivity];
                     [self showAlertWithMessage:error.localizedDescription];
                     if (block){
                         block(NO,YES,error.localizedDescription);
                     }
                 }];

    }
    else{
        [self showAlertWithMessage:@"No connection detected"];
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

#pragma -mark UIscrollview delegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.friendsTable){

        CGRect frame = self.friendsTable.frame;
        self.friendsTable.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.bottomSendButton.frame.size.height);
        [self.view addSubview:self.bottomSendButton];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.friendsTable){
        [self.bottomSendButton removeFromSuperview];
        CGRect frame = self.friendsTable.frame;
        self.friendsTable.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + self.bottomSendButton.frame.size.height);
    }

}

- (NSArray *)friendsArray
{
    if (!_friendsArray){
        _friendsArray = [User fetchFriendsInContext:self.myUser.managedObjectContext getContacts:YES];
    }
    
    return _friendsArray;
}

- (NSArray *)facebookFriendsArray
{
    if (!_facebookFriendsArray){
        _facebookFriendsArray = [User fetchFriendsInContext:self.myUser.managedObjectContext getContacts:NO];
    }
    return _facebookFriendsArray;
}

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




@end
