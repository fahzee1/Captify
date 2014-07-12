//
//  HistoryViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryRecievedViewController.h"
#import "TWTSideMenuViewController.h"
#import "UIColor+HexValue.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "HistoryReceivedCell.h"
#import "HistoryDetailViewController.h"
#import "NSDate+TimeAgo.h"
#import "Challenge+Utils.h"
#import "ChallengePicks+Utils.h"
#import "AppDelegate.h"
#import "ChallengeViewController.h"
#import "UIImageView+WebCache.h"
#import "AwesomeAPICLient.h"
#import "Notifications.h"
#import "TWTSideMenuViewController.h"
#import "MenuViewController.h"


@interface HistoryRecievedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *cData;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property BOOL pendingRequest;
@property (strong, nonatomic) NSMutableArray *picksList;
@property (strong,nonatomic) Notifications *notifications;
@property (strong,nonatomic)UILabel *errorLabel;
@property (strong,nonatomic)UIButton *errorInvite;
@property (strong,nonatomic)UIRefreshControl *refreshControl;

@end

@implementation HistoryRecievedViewController

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
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTable.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.myTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchUpdates) forControlEvents:UIControlEventValueChanged];
    
    if ([self.cData count] == 0){
        [self.myTable addSubview:self.errorLabel];
    }
    
    if (!IS_IPHONE5){
        self.myTable.contentSize = CGSizeMake(320, 800);
        self.myTable.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
    }
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Received Menu Screen";
    }
    
 
    [self fetchUpdates];
        

}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTable deselectRowAtIndexPath:[self.myTable indexPathForSelectedRow] animated:NO];
    
    /*
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchUpdates];
        
    });
     */
}


- (void)dealloc
{
    self.cData = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
      DLog(@"received memory warning here");
}

- (void)reloadMyTable
{
    [self.myTable reloadData];
}


- (void)showInviteScreen:(UIButton *)sender
{
    [AppDelegate hightlightViewOnTap:sender
                           withColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE]
                           textColor:[UIColor whiteColor]
                       originalColor:[UIColor clearColor]
                   originalTextColor:[UIColor whiteColor]
                            withWait:0.3];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[INVITE_TEXT] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityVC animated:YES completion:nil];

}

- (void)fetchUpdates
{
    if (!self.pendingRequest){
        self.pendingRequest = YES;
        
        
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([self.refreshControl isRefreshing]){
                  [self.refreshControl endRefreshing];
            }
        });
        
        NSDate *lastFetch = [[NSUserDefaults standardUserDefaults] valueForKey:[Challenge fetchedHistoryKey]];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:[Challenge fetchedHistoryKey]];
        NSMutableDictionary *params =[@{@"username": self.myUser.username,
                                         @"type":@"received"} mutableCopy];
        if (lastFetch){
            params[@"date"] = [Challenge dateStringFromDate:lastFetch];
        }
        
        
        if (1){
            params[@"test"] = [NSNumber numberWithBool:YES];

        }
        

        [User fetchUserBlobWithParams:params
                                block:^(BOOL wasSuccessful, id data, NSString *message) {
                                    self.pendingRequest = NO;
                                    if (wasSuccessful){
                                        // fetch sender user and all recipient users
                                        // create challenge add recipients
                                        // create challege picks and add them to challenge
                                        
                                        
                                        // create json objects
                                        id challenges = [data valueForKey:@"received_challenges"];
                                    
                                        id json;
                                        if ([challenges isKindOfClass:[NSString class]]){
                                            NSData *jsonString = [challenges dataUsingEncoding:NSUTF8StringEncoding];
                                            json = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:nil];
                                        }
                                        else if ([challenges isKindOfClass:[NSDictionary class]]){
                                            json = challenges;
                                        }
                                        else if ([challenges isKindOfClass:[NSArray class]]){
                                            NSNumber *redis = data[@"redis"];
                                            if ([redis intValue] == 1){
                                                [self fetchRedisUpdateWithData:challenges];
                                            }

                                            
                                        }
                                      
                                        

                                        // get sender and create challenge from data
                                        for (id ch in json[@"challenges"]){
                                            NSString *challenge_id = ch[@"id"];
                                            NSString *name = ch[@"name"];
                                            NSNumber *active = ch[@"is_active"];
                                            NSNumber *recipients_count = ch[@"recipients_count"];
                                            //NSArray *recipients = ch[@"recipients"];
                                            NSString *media_url = ch[@"media_url"];
                                            
                                            NSNumber *isFb;
                                            NSString *fbID;
                                            
                                            id sender_name = ch[@"sender"];
                                            NSString *sender;
                                            if ([sender_name isKindOfClass:[NSString class]]){
                                                sender = sender_name;
                                            }
                                            else{
                                                sender = sender_name[0][@"username"];
                                                isFb = sender_name[0][@"is_facebook"];
                                                fbID = sender_name[0][@"facebook_id"];
                                            }
    
                                            NSMutableDictionary *params = [@{@"sender": sender_name,
                                                                     @"context": self.myUser.managedObjectContext,
                                                                     @"recipients_count": recipients_count,
                                                                     @"challenge_name":name,
                                                                     @"active":active,
                                                                     @"challenge_id":challenge_id,
                                                                     @"media_url":media_url
                                                                     } mutableCopy];
                                            if (fbID){
                                                params[@"facebook_user"] = isFb;
                                                params[@"facebook_id"] = fbID;
                                            }
                                            
                                            params[@"sent"] = [NSNumber numberWithBool:NO];
                                      
                                          
                                            
                                            Challenge *challenge = [Challenge createChallengeWithRecipientsWithParams:params];
                                            
                                            
                                            if (challenge){
                                                
                                                [self.myUser addRecipient_challengesObject:challenge];
                                                
                                                // create challenge picks to add to challenge
                                                for (id results in ch[@"results"]){
                                                    // create picks
                                                    NSString *player = results[@"player"];
                                                    NSString *caption = results[@"answer"];
                                                    NSNumber *is_chosen = results[@"is_chosen"];
                                                    NSString *pick_id = results[@"pick_id"];
                                                    NSNumber *is_facebook = results[@"is_facebook"];
                                                    NSString *facebook_id = results[@"facebook_id"];
                                                    
                                                    NSDictionary *params2 = @{@"player": player,
                                                                              @"context":self.myUser.managedObjectContext,
                                                                              @"is_chosen":is_chosen,
                                                                              @"answer":caption,
                                                                              @"pick_id":pick_id,
                                                                              @"is_facebook":is_facebook,
                                                                              @"facebook_id":facebook_id};
                                                    ChallengePicks *pick = [ChallengePicks createChallengePickWithParams:params2];
                                                    if (pick){
                                                        [challenge addPicksObject:pick];
                                                        
                                                        NSError *error;
                                                        if (![challenge.managedObjectContext save:&error]){
                                                            DLog(@"%@",error);
                                                            
                                                        }

                                                    }
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            
                                            if ([self.cData count] > 0){
                                                [self.errorLabel removeFromSuperview];
                                                [self.errorInvite removeFromSuperview];
                                                self.errorInvite = nil;
                                                self.errorLabel = nil;
                                                
                                            }
                                            else{
                                                /*
                                                if ([self.cData count] == 0){
                                                    [self.myTable addSubview:self.errorContainerView];
                                                }
                                                 */

                                            }

                                            [self.refreshControl endRefreshing];
                                            [self.myTable reloadData];
                                        });
                                    }
                                    
                                    
                                }];
    }
}

- (void)fetchRedisUpdateWithData:(id)data
{
    for (NSString *jsonString in data){
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        NSString *challenge_id = json[@"id"];
        NSString *name = json[@"name"];
        NSNumber *active = json[@"is_active"];
        NSNumber *recipients_count = json[@"recipients_count"];
        //NSArray *recipients = json[@"recipients"];
        NSString *media_url = json[@"media_url"];
        NSString *createdString = json[@"challenge_created"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:CAPTIFY_TIMEZONE];
        NSDate *created = [dateFormatter dateFromString:createdString];
        
        NSNumber *isFb;
        NSString *fbID;
        
        id sender_name = json[@"sender"];
        NSString *sender;
        if ([sender_name isKindOfClass:[NSString class]]){
            sender = sender_name;
        }
        else{
            sender = sender_name[0][@"username"];
            isFb = sender_name[0][@"is_facebook"];
            fbID = sender_name[0][@"facebook_id"];
        }
        
        
        if (!challenge_id || !name || !sender_name){
            continue;
        }
        
        NSMutableDictionary *params = [@{@"sender": sender,
                                 @"context": self.myUser.managedObjectContext,
                                 @"recipients_count": recipients_count,
                                 @"challenge_name":name,
                                 @"active":active,
                                 @"challenge_id":challenge_id,
                                 @"media_url":media_url
                                 } mutableCopy];
        
        if (fbID){
            params[@"facebook_user"] = isFb;
            params[@"facebook_id"] = fbID;
        }
        
        if (created){
            params[@"created"] = created;
        }
        
        params[@"sent"] = [NSNumber numberWithBool:NO];
        
        
        [Challenge createChallengeWithRecipientsWithParams:params];
        
    
        
        
    }

}

#pragma -mark Uitableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.cData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.cData count] == 0){
        return 0;
    }
    else{
        return 1;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forCell:cell];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forCell:cell];

}


- (void)setCellColor:(UIColor *)color forCell:(UITableViewCell *)cell
{
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;

    
}

#warning test the two tableview methods below for deleting
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        //add code here for when you hit delete
        // send api request to server to delete challenge
        // remove object from data source
        // reload table
        DLog(@"delete this row");
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.cornerRadius = 10;
    cell.backgroundView.layer.cornerRadius = 10;
    cell.layer.cornerRadius = 10;
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    

    if (cell && [cell isKindOfClass:[HistoryReceivedCell class]]){
        
        UILabel *titleLabel = ((HistoryReceivedCell *)cell).historyTitleLabel;
        UIButton *activeButton = ((HistoryReceivedCell *)cell).activeButton;
        UIImageView *myImageView =  ((HistoryReceivedCell *)cell).historyImageView;
        UILabel *dateLabel = ((HistoryReceivedCell *)cell).dateLabel;
        UILabel *usernameLabel = ((HistoryReceivedCell *)cell).myUsername;
        
        activeButton.userInteractionEnabled = NO;
        
        myImageView.layer.masksToBounds = YES;
        myImageView.layer.cornerRadius = 30;
        
        Challenge *challenge = [self.cData objectAtIndex:indexPath.section];
        User *sender = challenge.sender;
        
        if ([challenge.name length] >= 16){
            NSString *newString = [[challenge.name capitalizedString] substringToIndex:15];
            titleLabel.text = [NSString stringWithFormat:@"%@...",newString];
        }
        else{
            titleLabel.text = [challenge.name capitalizedString];
        }

       
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:14];
            
        /*
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 176, titleLabel.frame.size.height);
        //titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 176, titleLabel.frame.size.height);
         */
        
        
        usernameLabel.text = [sender displayName];
        
        if ([usernameLabel.text length] >= 24){
            NSString *uString = [usernameLabel.text substringToIndex:23];
            usernameLabel.text = [NSString stringWithFormat:@"%@...",uString];
        }

        usernameLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
        
        
        dateLabel.text = [challenge.timestamp timeAgo];
        dateLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        dateLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
        
        [sender getCorrectProfilePicWithImageView:myImageView];
        
        
        // check if challenge is active or not or if pick was sent
        // if active show animating green filled circle, if not ahow circle outline
   
        
        
        int active = [challenge.active intValue];
        if (active == 1){
            NSDate *created = challenge.timestamp;
            NSInteger hours = [[[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:created toDate:[NSDate date] options:0] hour];
            
            if (hours >= 24){
                NSError *error;
                challenge.active = [NSNumber numberWithBool:NO];
                [challenge.managedObjectContext save:&error];
                active = [challenge.active intValue];
            }
        }
        int sentPick = [challenge.sentPick intValue];
        
        ChallengePicks *myPick;
        NSArray *allPicks = [challenge.picks allObjects];
        NSArray *picks = [allPicks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player.username == %@",self.myUser.username]];
        if (picks){
            myPick = [picks firstObject];
        }

        int hackishCheck = [challenge.fields_count intValue];
        
        if (active && !sentPick && !hackishCheck){
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            /*
            if (![activeButton.layer animationForKey:@"historyActive"]){
                
                
                CABasicAnimation *colorPulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
                colorPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                colorPulse.fromValue = [NSNumber numberWithFloat:1.0];
                colorPulse.toValue = [NSNumber numberWithFloat:0.1];
                colorPulse.autoreverses = YES;
                colorPulse.duration = 0.8;
                colorPulse.repeatCount = FLT_MAX;
                [activeButton.layer addAnimation:colorPulse forKey:@"historyActive"];
            }
             */
            
            [activeButton setImage:[UIImage imageNamed:CAPTIFY_ACTIVE_HISTORY] forState:UIControlStateNormal];
        }
        
        else if ([myPick.is_chosen intValue] == 1){
            [activeButton setImage:[UIImage imageNamed:CAPTIFY_CHOSEN_HISTORY] forState:UIControlStateNormal];
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            [activeButton setImage:[UIImage imageNamed:CAPTIFY_INACTIVE_HISTORY] forState:UIControlStateNormal];
            
        }
        
        
        
        /*
        NSArray *allPicks = [challenge.picks allObjects];
        NSArray *pick = [allPicks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player.username == %@",self.myUser.username]];
        if (pick && [pick isKindOfClass:[ChallengePicks class]]){
            if (((ChallengePicks *)pick).is_chosen || ((ChallengePicks *)pick).challenge.is_chosen){
#warning show trophy here if selected caption is mines
                DLog(@"should show badge");
            }
            
        }
         */
        

        
        
        
    }
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go to detail screen or go to challenge screen
    
    // check if active
    Challenge *challenge = [self.cData objectAtIndex:indexPath.section];
    int active = [challenge.active intValue];
    int sentPick = [challenge.sentPick intValue];
    int hackishCheck = [challenge.fields_count intValue];

    
    if (active && !sentPick && hackishCheck != 333){
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"showChallenge"];
        if ([vc isKindOfClass:[ChallengeViewController class]]){
            ((ChallengeViewController *)vc).myChallenge = challenge;
            ((ChallengeViewController *)vc).myUser = self.myUser;
            ((ChallengeViewController *)vc).name = challenge.name;
            ((ChallengeViewController *)vc).sender = [challenge.sender firstName];
            ((ChallengeViewController *)vc).myFriend = challenge.sender.username;
            ((ChallengeViewController *)vc).mediaURL = [challenge.image_path isEqualToString:@""] ? nil:[NSURL URLWithString:challenge.image_path];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    // challenge inactive show detail screen
    else{
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
            ((HistoryDetailViewController *)vc).myChallenge = challenge;
            ((HistoryDetailViewController *)vc).myUser = self.myUser;
            ((HistoryDetailViewController *)vc).hideSelectButtons = YES;
            ((HistoryDetailViewController *)vc).hideSelectButtonsMax = YES;
            ((HistoryDetailViewController *)vc).sentHistory = NO;
            ((HistoryDetailViewController *)vc).mediaURL = [challenge.image_path isEqualToString:@""] ? nil:[NSURL URLWithString:challenge.image_path];
           
            
            NSArray *allPicks = [challenge.picks allObjects];
            NSArray *pick = [allPicks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player.username == %@",self.myUser.username]];
            if (pick && [pick isKindOfClass:[ChallengePicks class]]){
                ((ChallengePicks *)pick).challenge.is_chosen = [NSNumber numberWithBool:YES];
                ((HistoryDetailViewController *)vc).myPick = (ChallengePicks *)pick;
            }
            
            if (hackishCheck == 333){
                challenge.active = [NSNumber numberWithBool:NO];
            }
            

            [self.navigationController pushViewController:vc animated:YES];
        }

    }
    
    NSError *error;
    if (![challenge.managedObjectContext save:&error]){
        DLog(@"%@",error);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myTable reloadData];
    });

    
}



- (NSArray *)cData
{
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _cData = [Challenge getHistoryChallengesForUser:self.myUser
                                                   sent:NO];
        
    });
     */
    
    _cData = [Challenge getHistoryChallengesForUser:self.myUser
                                               sent:NO];
    

    
    return _cData;
    
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

- (Notifications *)notifications
{
    if (!_notifications){
        _notifications = [[Notifications alloc] init];
    }
    
    return _notifications;
}


- (UILabel *)errorLabel
{
    if (!_errorLabel){
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:17];
        _errorLabel.text = NSLocalizedString(@"No active challenges. Try inviting friends.", nil);
        _errorLabel.numberOfLines = 0;
        [_errorLabel sizeToFit];
        _errorLabel.textColor = [UIColor whiteColor];
        _errorLabel.frame = CGRectMake(35, 50, 300, 100);
        
        if ([self.cData count] == 0){
            self.errorInvite = [UIButton buttonWithType:UIButtonTypeSystem];
            self.errorInvite.backgroundColor = [UIColor clearColor];
            self.errorInvite.layer.cornerRadius = 5;
            self.errorInvite.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:16];
            self.errorInvite.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
            self.errorInvite.layer.borderWidth = CAPTIFY_BUTTON_LAYER;
            [self.errorInvite setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
            [self.errorInvite setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            CGRect labelFrame = _errorLabel.frame;
            self.errorInvite.frame = CGRectMake(labelFrame.origin.x + 33, labelFrame.size.height + 65, 175, 45);
            [self.errorInvite addTarget:self action:@selector(showInviteScreen:) forControlEvents:UIControlEventTouchUpInside];
            
            if (!IS_IPHONE5){
                CGRect inviteFrame = self.errorInvite.frame;
                inviteFrame.origin.y += 50;
                self.errorInvite.frame = inviteFrame;
            }
            
            [self.myTable addSubview:self.errorInvite];
        }
        

    }
    
    
    return _errorLabel;

}





@end