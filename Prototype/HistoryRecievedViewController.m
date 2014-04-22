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
#import "FAImageView.h"
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
    
    if ([self.cData count] == 0){
        
        UIView *view = [[UIView alloc] initWithFrame:self.myTable.frame];
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE];
        
        CGRect containerFrame = view.frame;
        containerFrame.size.width -= 15;
        containerFrame.size.height -= 250;
        containerFrame.origin.y += 25;
        containerFrame.origin.x += 7;
        view.frame = containerFrame;
        
        
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        errorLabel.text = @"Awww! None of your friends have sent you a challenge. You should try inviting them!";
        errorLabel.numberOfLines = 0;
        [errorLabel sizeToFit];
        errorLabel.textColor = [UIColor whiteColor];
        errorLabel.frame = CGRectMake(15, 50, view.frame.size.width-20, 100);
        
        UIButton *invite = [UIButton buttonWithType:UIButtonTypeSystem];
        invite.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
        invite.layer.cornerRadius = 10;
        invite.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        [invite setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
        [invite setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
        invite.frame = CGRectMake(50, view.bounds.size.height - 130, 200, 50);
        [invite addTarget:self action:@selector(showInviteScreen) forControlEvents:UIControlEventTouchUpInside];
        
        
        [view addSubview:errorLabel];
        [view addSubview:invite];
        [self.myTable addSubview:view];
    }
    
    

}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTable deselectRowAtIndexPath:[self.myTable indexPathForSelectedRow] animated:NO];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchUpdatesWithBlock:nil];
    });
}


- (void)dealloc
{
    self.cData = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadMyTable
{
    [self.myTable reloadData];
}


- (void)showInviteScreen
{
    // update the highlighted menu button to the screen we're about to show
    UIViewController *menu = self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) updateCurrentScreen:MenuFriendsScreen];
    }

    UIViewController *inviteScreen = [self.storyboard instantiateViewControllerWithIdentifier:@"friendContainerRoot"];
    [self.sideMenuViewController setMainViewController:inviteScreen animated:YES closeMenu:NO];
}

- (void)fetchUpdatesWithBlock:(FetchRecentsBlock)block
{
    if (!self.pendingRequest){
        self.pendingRequest = YES;
        
        NSDate *lastFetch = [[NSUserDefaults standardUserDefaults] valueForKey:[Challenge fetchedHistoryKey]];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:[Challenge fetchedHistoryKey]];
        NSMutableDictionary *params =[@{@"username": self.myUser.username} mutableCopy];
        if (lastFetch){
            params[@"date"] = [Challenge dateStringFromDate:lastFetch];
        }
        
        if (1){
            params[@"test"] = [NSNumber numberWithBool:YES];
#warning remove this test when going live
        }

        [User fetchUserBlobWithParams:params
                                block:^(BOOL wasSuccessful, id data, NSString *message) {
                                    self.pendingRequest = NO;
                                    if (wasSuccessful){
                                        // fetch sender user and all recipient users
                                        // create challenge add recipients
                                        // create challege picks and add them to challenge
                                        
                                        
                                        // create json objects
                                        id challenges = [data valueForKey :@"received_challenges"];
                                        NSData *jsonString = [challenges dataUsingEncoding:NSUTF8StringEncoding];
                                        id json = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:nil];
                                        

                                        // get sender and create challenge from data
                                        for (id ch in json[@"challenges"]){
                                            NSString *challenge_id = ch[@"id"];
                                            NSString *name = ch[@"name"];
                                            NSNumber *active = ch[@"is_active"];
                                            NSNumber *recipients_count = ch[@"recipients_count"];
                                            NSString *sender_name = ch[@"sender"];
                                            NSArray *recipients = ch[@"recipients"];
                                            NSString *media_url = ch[@"media_url"];
    
                                            
                                            NSDictionary *params = @{@"sender": sender_name,
                                                                     @"context": self.myUser.managedObjectContext,
                                                                     @"recipients": recipients,
                                                                     @"recipients_count": recipients_count,
                                                                     @"challenge_name":name,
                                                                     @"active":active,
                                                                     @"challenge_id":challenge_id,
                                                                     @"media_url":media_url
                                                                     };
                                            
                                            Challenge *challenge = [Challenge createChallengeWithRecipientsWithParams:params];
                                            
                                            
                                            if (challenge){
                                                
                                                // create challenge picks to add to challenge
                                                for (id results in ch[@"results"]){
                                                    // create picks
                                                    NSString *player = results[@"player"];
                                                    NSString *caption = results[@"answer"];
                                                    NSNumber *is_chosen = results[@"is_chosen"];
                                                    NSString *pick_id = results[@"pick_id"];
                                                    
                                                    NSDictionary *params2 = @{@"player": player,
                                                                              @"context":self.myUser.managedObjectContext,
                                                                              @"is_chosen":is_chosen,
                                                                              @"answer":caption,
                                                                              @"pick_id":pick_id};
                                                    ChallengePicks *pick = [ChallengePicks createChallengePickWithParams:params2];
                                                    if (pick){
                                                        [challenge addPicksObject:pick];
                                                        
                                                        NSError *error;
                                                        if (![challenge.managedObjectContext save:&error]){
                                                            NSLog(@"%@",error);
                                                            
                                                        }

                                                    }
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.myTable reloadData];
                                        });
                                    }
                                    
                                    if (block){
                                        block();
                                    }
                                    
                                    
                                }];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 2;
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
        
        usernameLabel.text = [sender.username capitalizedString];
        usernameLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
        
        
        dateLabel.text = [challenge.timestamp timeAgo];
        dateLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        dateLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:11];
        
        [sender getCorrectProfilePicWithImageView:myImageView];
        
        
        // check if challenge is active or not or if pick was sent
        // if active show animating green filled circle, if not ahow circle outline
   
        
        int active = [challenge.active intValue];
        int sentPick = [challenge.sentPick intValue];
                
        if (active && !sentPick){
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
                NSLog(@"should show badge");
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
    int firstOpen = [challenge.first_open intValue];
    
    if (firstOpen){
        [self.notifications removeOneNotifFromView:self.navigationController.navigationBar atPoint:historyNOTIFPOINT];
        challenge.first_open = [NSNumber numberWithBool:NO];
        
    }

    if (active && !sentPick){
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"showChallenge"];
        if ([vc isKindOfClass:[ChallengeViewController class]]){
            ((ChallengeViewController *)vc).myChallenge = challenge;
            ((ChallengeViewController *)vc).myUser = self.myUser;
            ((ChallengeViewController *)vc).name = challenge.name;
            ((ChallengeViewController *)vc).sender = challenge.sender.username;
            ((ChallengeViewController *)vc).mediaURL = [NSURL URLWithString:challenge.image_path];
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
            ((HistoryDetailViewController *)vc).mediaURL = [NSURL URLWithString:challenge.image_path];
           
            
            NSArray *allPicks = [challenge.picks allObjects];
            NSArray *pick = [allPicks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player.username == %@",self.myUser.username]];
            if (pick && [pick isKindOfClass:[ChallengePicks class]]){
                ((ChallengePicks *)pick).challenge.is_chosen = [NSNumber numberWithBool:YES];
                ((HistoryDetailViewController *)vc).myPick = (ChallengePicks *)pick;
            }
            

            [self.navigationController pushViewController:vc animated:YES];
        }

    }
    
    NSError *error;
    if (![challenge.managedObjectContext save:&error]){
        NSLog(@"%@",error);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myTable reloadData];
    });

    
}


- (NSArray *)cData
{
    _cData = [Challenge getHistoryChallengesInContext:self.myUser.managedObjectContext
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



@end