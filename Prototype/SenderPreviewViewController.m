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

#define SCROLLPICMULTIPLY_VALUE 100
#define SCROLLPICADD_VALUE 22

@interface SenderPreviewViewController ()<UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *selectedFriendsScroll;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (strong, nonatomic)NSMutableDictionary *selectedFriends;
@property (strong, nonatomic)NSMutableDictionary *selectedPositions;
@property (strong, nonatomic) NSArray *friendsArray;
@property (strong, nonatomic) NSArray *facebookFriendsArray;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) UIButton *bottomSendButton;
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
    self.selectedFriendsScroll.delegate = self;
    self.friendsTable.delegate = self;
    self.friendsTable.dataSource = self;
    self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width, self.selectedFriendsScroll.frame.size.height);
    self.selectedFriendsScroll.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    self.scrollStart = CGPointMake(self.toLabel.frame.origin.x + 30, 10);
    
    [self setupStyles];
    
    //self.name = @"Guess what im eating";
    //self.phrase = @"Nothing stupid";
    self.previewImage.image = [UIImage imageWithImage:self.image convertToSize:self.previewImage.frame.size];
    self.friendsArray = @[@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM"];
    self.facebookFriendsArray = @[@"dSanders21",@"theCantoon",@"darkness"];
 
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
    if (self.selectedFriendsScroll.delegate == self){
        self.selectedFriendsScroll.delegate = nil;
    }
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
    
    self.toLabel.text = NSLocalizedString(@"To:", @"Recipient list to send challenge to");
    
    self.topLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#3498db"] CGColor];
    self.topLabel.textColor = [UIColor whiteColor];
    self.topLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    
    // the bottom label
    self.bottomLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.bottomLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    self.bottomLabel.textColor = [UIColor whiteColor];
    self.bottomLabel.layer.opacity = 0.6f;
    self.bottomLabel.text = NSLocalizedString(@"Choose Friends", @"Choose a list of friends to send challenge to");
    
    // the bottom send button
    self.bottomSendButton = [[UIButton alloc] initWithFrame:self.bottomLabel.frame];
    self.bottomSendButton.titleLabel.textColor = [UIColor whiteColor];
    [self.bottomSendButton setTitle:NSLocalizedString(@"Send", @"Send challenge to recipients") forState:UIControlStateNormal];
    self.bottomSendButton.titleLabel.font = self.bottomLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25
    ];
    self.bottomSendButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.bottomSendButton.userInteractionEnabled = YES;
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
    // create thumbnail, save it, and save filepath
    // save image and save filepath
    // create challenge in core data.
    // send request to create challenge on backend.

    
    
     NSString *challenge_id = [Challenge createChallengeIDWithUser:self.myUser.username];
    
    // create/save thumbnail and save image
    // thumbnail is size of imageview
    UIImage *thumbnail = [self createThumbnailWithSize:CGSizeMake(60, 60)];
    NSString *thumbnail_path = [NSString stringWithFormat:@"challenges/thumbnail-%@.jpg",challenge_id];
    NSString *image_path = [NSString stringWithFormat:@"challenges/image-%@.jpg",challenge_id];
    [Challenge saveImage:thumbnail filename:thumbnail_path];
    [Challenge saveImage:self.image filename:image_path];
    
    
    // create challenge in core data
    int count = [self.selectedFriends[@"friends"] count];
    NSDictionary *params = @{@"sender":self.myUser.username,
                             @"context":self.myUser.managedObjectContext,
                             @"recipients":self.selectedFriends[@"friends"],
                             @"recipients_count":[NSNumber numberWithInt:count],
                             @"challenge_name":self.name,
                             @"challenge_id":challenge_id,
                             @"thumbnail_path":thumbnail_path,
                             @"image_path":image_path};
    
    Challenge *challenge = [Challenge createChallengeWithParams:params];
    
    
    // create challenge in backend
    NSDictionary *apiParams = @{@"username": self.myUser.username,
                                @"is_picture":[NSNumber numberWithBool:YES],
                                @"name":self.name,
                                @"recipients":self.selectedFriends[@"friends"],
                                @"challenge_id":challenge.challenge_id};
    
    [Challenge sendCreateChallengeRequest:apiParams image:UIImageJPEGRepresentation(self.image, 1)];
    
    NSLog(@"send challenge to %@",[self.selectedFriends[@"friends"] description]);
    
    
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(previewscreenFinished)]){
            
            [self.delegate previewscreenFinished];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma -mark UIscrollview delegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.friendsTable){
        self.bottomLabel.hidden = NO;
        self.bottomSendButton.hidden = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.friendsTable){
        self.bottomLabel.hidden = YES;
        self.bottomSendButton.hidden = YES;
    }

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
        if (cell){
            
            if ([[self.sections objectAtIndex:indexPath.section] isEqualToString:@"Facebook"]){
                // retrurn cells for fbook friends
                    ((SenderFriendsCell *)cell).myFriendUsername.text = [self.facebookFriendsArray objectAtIndex:indexPath.row];
            }
            else if ([[self.sections objectAtIndex:indexPath.section] isEqualToString:@"Contacts"]){
                // return cells for contact friends
                ((SenderFriendsCell *)cell).myFriendUsername.text = [self.friendsArray objectAtIndex:indexPath.row];
                
            }

            
            ((SenderFriendsCell *)cell).myFriendPic.image = nil;
            FAImageView *imageView =  ((FAImageView *)((SenderFriendsCell *)cell).myFriendPic);
            [imageView setDefaultIconIdentifier:@"fa-user"];
            
            // add this to list of cells that have checkmarks
            if ([self.selectedFriends[@"index_paths"] containsObject:indexPath]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }

    
        }
    
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *selection = [self.friendsArray objectAtIndex:indexPath.row];
    if ([self.selectedFriends[@"friends"] containsObject:selection]){
        
          // remove user from list and and scroll view
        
        NSInteger index = [self.selectedFriends[@"friends"] indexOfObject:selection];
        
        // remove friends from list and their positions
        [self.selectedFriends[@"friends"] removeObject:selection];
        [self.selectedPositions removeObjectForKey:selection];
        
        // temp list of all users after the removed user to resize positions
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (NSString *username in self.selectedFriends[@"friends"]){
            NSInteger tempIndex = [self.selectedFriends[@"friends"] indexOfObject:username];
            if ( tempIndex >= index){
                [temp addObject:username];
            }
        }
        
        // get remaining users tags to reposition view
        for (NSString *username in temp){
            int viewTag = [[self.selectedPositions objectForKey:username] intValue];
            UIView *view = [self.selectedFriendsScroll viewWithTag:viewTag];
            [UIView animateWithDuration:1.0f
                             animations:^{
                                 if (view.frame.origin.x >= self.toLabel.frame.origin.x +7){
                                     view.frame = CGRectMake(view.frame.origin.x - 35, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                                 }

                             }];

        }
        
        if (self.scrollStart.x >= self.toLabel.frame.origin.x +45){
            self.scrollStart = CGPointMake(self.scrollStart.x -35, self.scrollStart.y);
        }
       
       
        self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width -40, self.selectedFriendsScroll.frame.size.height);

        UIView *userPic = [self.selectedFriendsScroll viewWithTag:(indexPath.row + SCROLLPICADD_VALUE) * SCROLLPICMULTIPLY_VALUE];
        if (userPic){
            if ([userPic.subviews count] == 0 && [userPic isKindOfClass:[UIImageView class]]){
            [userPic removeFromSuperview];
            }
            else{
                // not the userpic i want to remove
            }
        }
        
    }
    else{
        // add user to selected list
        
        [self.selectedFriends[@"friends"] addObject:selection];
        
        
        
        // get users pic , testing for now, add it to scroll
        UIImageView *testView = [[UIImageView alloc] initWithImage:[UIImage imageWithRoundedCornersSize:30.0f usingImage:[UIImage imageNamed:@"profile-placeholder"]]];
        
        testView.layer.masksToBounds = YES;
        
        // set tag to a very unique value so we dont risk getting a tag for another view
        testView.tag = (indexPath.row + SCROLLPICADD_VALUE) * SCROLLPICMULTIPLY_VALUE;
        
        // save views postion to slide into freed up space
        // "positions" is a list of dictionaries with key being username
        // and value being cgpoint
        self.selectedPositions[selection] = [NSNumber numberWithInt:testView.tag];
        
        if ([self.selectedFriends[@"friends"] count] > 1){
            //int tag = [[self.selectedPositions objectForKey:nameOfLast] intValue];
            self.scrollStart = CGPointMake(self.scrollStart.x +45, self.scrollStart.y);
            
        }
        
     
        testView.frame = CGRectMake(self.scrollStart.x, self.scrollStart.y, 35, 35);

        
        [self.selectedFriendsScroll addSubview:testView];
        
        
        self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width +48, self.selectedFriendsScroll.frame.size.height);
        
    

        
    
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
    if (![self.selectedFriends[@"friends"] count] == 0){
    
        self.bottomLabel.hidden = YES;
        [self.view addSubview:self.bottomSendButton];
        
    }
    else{
        [self.bottomSendButton removeFromSuperview];
        self.bottomLabel.hidden = NO;
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
