//
//  HistorySentViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/7/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistorySentViewController.h"
#import "HistorySentCell.h"
#import "NSDate+TimeAgo.h"
#import "FAImageView.h"
#import "Challenge+Utils.h"
#import "ChallengePicks+Utils.h"
#import "AppDelegate.h"
#import "HistoryDetailViewController.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "UIImageView+WebCache.h"
#import "AwesomeAPICLient.h"
#import "Notifications.h"
#import "UIColor+HexValue.h"

@interface HistorySentViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) NSArray *data;
@property BOOL pendingRequest;
@property (strong, nonatomic) Notifications *notifications;

@end

@implementation HistorySentViewController

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
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTable.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];

    
    if ([self.data count] == 0){

        UIView *view = [[UIView alloc] initWithFrame:self.myTable.frame];
        view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
        
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20];
        errorLabel.text = @"Sheesh! Somebody needs to start sending their friends challenges!";
        errorLabel.numberOfLines = 0;
        [errorLabel sizeToFit];
        errorLabel.textColor = [UIColor whiteColor];
        errorLabel.frame = CGRectMake(20, 50, 300, 100);
        
        [view addSubview:errorLabel];
        [self.myTable addSubview:view];
    }
    


}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTable deselectRowAtIndexPath:[self.myTable indexPathForSelectedRow] animated:NO];
    [self fetchUpdatesWithBlock:nil];
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


- (void)fetchUpdatesWithBlock:(FetchRecentsBlock2)block
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
                                        id challenges = [data valueForKey :@"my_challenges"];
                                        NSData *jsonString = [challenges dataUsingEncoding:NSUTF8StringEncoding];
                                        id json = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:nil];
                                        
                                        // get sender and create challenge from data
                                        for (id ch in json[@"challenges"]){
                                            NSString *challenge_id = ch[@"id"];
                                            NSString *name = ch[@"name"];
                                            NSNumber *active = ch[@"is_active"];
                                            NSNumber *recipients_count = ch[@"recipients_count"];
                                            NSArray *recipients = ch[@"recipients"];
                                            NSString *media_url = ch[@"media_url"];
                                            
                                            NSDictionary *params = @{@"sender": self.myUser.username,
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
                                                // increment notifications
                                                //[self.notifications addOneNotifToView:self.navigationController.navigationBar atPoint:historyNOTIFPOINT];
                                                
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.data count] == 0){
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
    static NSString *cellIdentifier = @"historySentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = 10;
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    if ([cell isKindOfClass:[HistorySentCell class]]){
        UILabel *myLabel = ((HistorySentCell *)cell).myCaptionLabel;
        UILabel *numberOfFriends = ((HistorySentCell *)cell).sentToLabel;
        UILabel *dateLabel = ((HistorySentCell *)cell).myDateLabel;
        UIButton *activeButton = ((HistorySentCell *)cell).activeButton;
        UIImageView *myImageView = ((HistorySentCell *)cell).myImageVew;
        UILabel *usernameLabel = ((HistorySentCell *)cell).myUsername;
    
        activeButton.userInteractionEnabled = NO;
        
        myImageView.layer.masksToBounds = YES;
        myImageView.layer.cornerRadius = 30;

        Challenge *challenge = [self.data objectAtIndex:indexPath.section];
        User *sender = challenge.sender;
        int active = [challenge.active intValue];
        //int sentPick = [challenge.sentPick intValue];
        int shared = [challenge.shared intValue];

        if (active && !shared){
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if ([challenge.name length] >= 25){
            NSString *newString = [[challenge.name capitalizedString] substringToIndex:24];
            myLabel.text = [NSString stringWithFormat:@"%@...",newString];
        }
        else{
            myLabel.text = [challenge.name capitalizedString];
        }
        myLabel.textColor = [UIColor whiteColor];
        myLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:14];
        
        /*
        myLabel.frame = CGRectMake(myLabel.frame.origin.x, myLabel.frame.origin.y,176 , 30);
        myLabel.numberOfLines = 0;
        [myLabel sizeToFit];
         */
        
        usernameLabel.text = sender.username;
        usernameLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];


        dateLabel.text = [challenge.timestamp timeAgo];
        dateLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        dateLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:11];
        
        [sender getCorrectProfilePicWithImageView:myImageView];
        
        if ([challenge.recipients_count intValue] == 1){
            numberOfFriends.text = [NSString stringWithFormat:@"%@ friend playing",[challenge.recipients_count stringValue]];
        }
        else{
            numberOfFriends.text = [NSString stringWithFormat:@"%@ friends playing",[challenge.recipients_count stringValue]];
        }
        
        numberOfFriends.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        numberOfFriends.font = [UIFont fontWithName:@"ProximaNova-Bold" size:11];
        
        // show green active circle
        
        if (active && !shared){
            /*
            if (![activeButton.layer animationForKey:@"historyActive"]){
                CABasicAnimation *colorPulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
                colorPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                colorPulse.fromValue = [NSNumber numberWithFloat:1.0];
                colorPulse.toValue = [NSNumber numberWithFloat:0.1];
                colorPulse.autoreverses = YES;
                colorPulse.duration = 1.0;
                colorPulse.repeatCount = FLT_MAX;
                [activeButton.layer addAnimation:colorPulse forKey:@"historyActive"];
            }
             */
        }
        else{
            [activeButton setImage:[UIImage imageNamed:CAPTIFY_INACTIVE_HISTORY] forState:UIControlStateNormal];
        
        }
        

        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // go to detail screen or go to challenge screen
    
    Challenge *challenge = [self.data objectAtIndex:indexPath.section];
    // check if active
    
    int active = [challenge.active intValue];
    int shared = [challenge.shared intValue];
    int firstOpen = [challenge.first_open intValue];
    
    if (firstOpen){
        [self.notifications removeOneNotifFromView:self.navigationController.navigationBar atPoint:historyNOTIFPOINT];
        challenge.first_open = [NSNumber numberWithBool:NO];
        NSError *error;
        if (![challenge.managedObjectContext save:&error]){
            NSLog(@"%@",error);
        }
    }

    if (active && !shared){

        
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
            UIImage *challenge_image = [Challenge loadImagewithFileName:challenge.local_image_path];
            ((HistoryDetailViewController *)vc).image = challenge_image;
            ((HistoryDetailViewController *)vc).myChallenge = challenge;
            ((HistoryDetailViewController *)vc).myUser = self.myUser;
            ((HistoryDetailViewController *)vc).mediaURL = [NSURL URLWithString:challenge.image_path];
            NSLog(@"%@ is image path",challenge.image_path);
            
             [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else{
        
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
            UIImage *challenge_image = [Challenge loadImagewithFileName:challenge.local_image_path];
            ((HistoryDetailViewController *)vc).image = challenge_image;
            ((HistoryDetailViewController *)vc).myChallenge = challenge;
            ((HistoryDetailViewController *)vc).myUser = self.myUser;
            ((HistoryDetailViewController *)vc).mediaURL = [NSURL URLWithString:challenge.image_path];
            ((HistoryDetailViewController *)vc).hideSelectButtons = YES;
            ((HistoryDetailViewController *)vc).hideSelectButtonsMax = YES;
            NSLog(@"%@ is image path",challenge.image_path);
            
            [self.navigationController pushViewController:vc animated:YES];
        }

        
    }


    
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



- (NSArray *)data
{
    _data = [Challenge getHistoryChallengesInContext:self.myUser.managedObjectContext
                                                    sent:YES];
    return _data;
}


- (Notifications *)notifications
{
    if (!_notifications){
        _notifications = [[Notifications alloc] init];
    }
    
    return _notifications;
}




@end
