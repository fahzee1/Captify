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
    
    

}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTable deselectRowAtIndexPath:[self.myTable indexPathForSelectedRow] animated:NO];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self fetchUpdates];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)fetchUpdates
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
                                    
                                    
                                }];
    }
}

#pragma -mark Uitableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell && [cell isKindOfClass:[HistoryReceivedCell class]]){
        
        UILabel *titleLabel = ((HistoryReceivedCell *)cell).historyTitleLabel;
        UILabel *activeLabel = ((HistoryReceivedCell *)cell).activeLabel;
        UIImageView *KimageView =  ((HistoryReceivedCell *)cell).historyImageView;
        UILabel *dateLabel = ((HistoryReceivedCell *)cell).dateLabel;
        
        Challenge *challenge = [self.cData objectAtIndex:indexPath.row];
        User *sender = challenge.sender;
        
        titleLabel.text = [[NSString stringWithFormat:@"%@ \r \rby %@",challenge.name,sender.username] capitalizedString];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 200, titleLabel.frame.size.height);
        //titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 200, titleLabel.frame.size.height);
        
        dateLabel.text = [challenge.timestamp timeAgo];
        
        [sender getCorrectProfilePicWithImageView:KimageView];
        
        
        // check if challenge is active or not or if pick was sent
        // if active show animating green filled circle, if not ahow circle outline
        activeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
        [activeLabel setTextColor:[UIColor greenColor]];
        
        int active = [challenge.active intValue];
        int sentPick = [challenge.sentPick intValue];
        int firstOpen = [challenge.first_open intValue];
        
        if (firstOpen){
            // add 'new' view to cell
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width -30,
                                                                  cell.contentView.bounds.size.height -70, 100, 50)];
            l.text = NSLocalizedString(@"NEW", nil);
            l.textColor = [[UIColor greenColor] colorWithAlphaComponent:0.6];
            l.font = [UIFont boldSystemFontOfSize:14];
            
            [cell.contentView addSubview:l];
        }
        
        if (active && !sentPick){
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            [activeLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle"]];
            [activeLabel setTextColor:[UIColor greenColor]];
            if (![activeLabel.layer animationForKey:@"historyActive"]){
                
                
                CABasicAnimation *colorPulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
                colorPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                colorPulse.fromValue = [NSNumber numberWithFloat:1.0];
                colorPulse.toValue = [NSNumber numberWithFloat:0.1];
                colorPulse.autoreverses = YES;
                colorPulse.duration = 0.8;
                colorPulse.repeatCount = FLT_MAX;
                [activeLabel.layer addAnimation:colorPulse forKey:@"historyActive"];
            }
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            [activeLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle-o"]];
            [activeLabel setTextColor:[UIColor redColor]];
            
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
    Challenge *challenge = [self.cData objectAtIndex:indexPath.row];
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