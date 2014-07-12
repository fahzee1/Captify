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
#import "TWTSideMenuViewController.h"
#import "MenuViewController.h"
#import "AppDelegate.h"

@interface HistorySentViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) NSArray *data;
@property BOOL pendingRequest;
@property (strong, nonatomic) Notifications *notifications;
@property (strong,nonatomic)UILabel *errorLabel;
@property (strong,nonatomic)UIButton *errorPlay;
@property (strong,  nonatomic)UIRefreshControl *refreshControl;
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

    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.myTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchUpdates) forControlEvents:UIControlEventValueChanged];
    

    if ([self.data count] == 0){
        [self.myTable addSubview:self.errorLabel];
    }
    
    if (!IS_IPHONE5){
        self.myTable.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
    }

    if (self.challenge_id){
        [self showDetailScreen];
    }
    


}


- (void)viewWillAppear:(BOOL)animated
{
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Sent Menu Screen";
    }
    
    [self fetchUpdates];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTable deselectRowAtIndexPath:[self.myTable indexPathForSelectedRow] animated:NO];
    
    
}

- (void)dealloc
{
    self.data = nil;
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


- (void)showHomeScreen:(UIButton *)sender
{
    [AppDelegate hightlightViewOnTap:sender
                           withColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE]
                           textColor:[UIColor whiteColor]
                       originalColor:[UIColor clearColor]
                   originalTextColor:[UIColor whiteColor]
                            withWait:0.3];

    // update the highlighted menu button to the screen we're about to show
    UIViewController *menu = self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) updateCurrentScreen:MenuHomeScreen];
    }

    UIViewController *camera = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHomeNavigation"];
    [self.sideMenuViewController setMainViewController:camera animated:YES closeMenu:NO];
}


- (void)showDetailScreen
{
    if (self.challenge_id){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Challenge"];
        request.shouldRefreshRefetchedObjects = YES;
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"(challenge_id = %@)",self.challenge_id];
        NSError *error;
        Challenge *challenge = [[self.myUser.managedObjectContext executeFetchRequest:request error:&error] firstObject];
        
        if (challenge){
            UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
            if ([vc isKindOfClass:[HistoryDetailViewController class]]){
                UIImage *challenge_image = [Challenge loadImagewithFileName:challenge.local_image_path];
                ((HistoryDetailViewController *)vc).image = challenge_image;
                ((HistoryDetailViewController *)vc).myChallenge = challenge;
                ((HistoryDetailViewController *)vc).myUser = self.myUser;
                ((HistoryDetailViewController *)vc).mediaURL = [challenge.image_path isEqualToString:@""] ? nil:[NSURL URLWithString:challenge.image_path];
                ((HistoryDetailViewController *)vc).hideSelectButtons = YES;
                ((HistoryDetailViewController *)vc).hideSelectButtonsMax = YES;
                ((HistoryDetailViewController *)vc).sentHistory = YES;
                
                [self.navigationController pushViewController:vc animated:YES];
            }
        }

        
    }
    

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
                                        @"type":@"sent"} mutableCopy];
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
                                        // create json objects
                                        id challenges = [data valueForKey:@"my_challenges"];
                                        /*
                                        NSNumber *redis = data[@"redis"];
                                        if ([redis intValue] == 1){
                                            
                                            return;
                                        }
                                         */
                                        
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
                                            
                                            NSDictionary *params = @{@"sender": self.myUser.username,
                                                                     @"context": self.myUser.managedObjectContext,
                                                                     @"recipients_count": recipients_count,
                                                                     @"challenge_name":name,
                                                                     @"active":active,
                                                                     @"challenge_id":challenge_id,
                                                                     @"media_url":media_url,
                                                                     @"sent":[NSNumber numberWithBool:YES]
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
                                            if ([self.data count] > 0){
                                                [self.errorPlay removeFromSuperview];
                                                [self.errorLabel removeFromSuperview];
                                                self.errorLabel = nil;
                                                self.errorPlay = nil;
                                
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
        
        @try {
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
            //"2014-06-25T20:40:56.823Z"
            NSMutableDictionary *params = [@{@"sender": self.myUser.username,
                                     @"context": self.myUser.managedObjectContext,
                                     @"recipients_count": recipients_count,
                                     @"challenge_name":name,
                                     @"active":active,
                                     @"challenge_id":challenge_id,
                                     @"media_url":media_url,
                                     @"sent":[NSNumber numberWithBool:YES]
                                     } mutableCopy];
            if (created){
                params[@"created"] = created;
            }
            
            
            [Challenge createChallengeWithRecipientsWithParams:params];
            
            

        }
        @catch (NSException *e) {
            return;
        }
        

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
    //cell.backgroundColor = color;
}


#warning test the two tableview methods below for deleting
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        //add code here for when you hit delete
        // send api request to server to delete challenge
        // remove object from data source
        // reload table
        Challenge *challenge = [self.data objectAtIndex:indexPath.section];
        NSDictionary *params = @{@"username": self.myUser.username,
                                 @"challenge_id":challenge.challenge_id,
                                 @"location":@"sent"
                                 };
        [Challenge deleteChallengeWithParams:params block:^(BOOL wasSuccessful) {
            if (wasSuccessful){
                [challenge.managedObjectContext deleteObject:challenge];
                [self.myTable reloadData];
                
            }
            else{
                [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Error deleting challenge", nil)];
            }
        }];
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historySentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = 10;
    //cell.contentView.layer.cornerRadius = 10;
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

        //int sentPick = [challenge.sentPick intValue];
        int shared = [challenge.shared intValue];

        if (active && !shared){
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if ([challenge.name length] >= 16){
            NSString *newString = [[challenge.name capitalizedString] substringToIndex:15];
            myLabel.text = [NSString stringWithFormat:@"%@...",newString];
        }
        else{
            myLabel.text = [challenge.name capitalizedString];
        }
        myLabel.textColor = [UIColor whiteColor];
        myLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:14];
        
        /*
        myLabel.frame = CGRectMake(myLabel.frame.origin.x, myLabel.frame.origin.y,176 , 30);
        myLabel.numberOfLines = 0;
        [myLabel sizeToFit];
         */
        
        usernameLabel.text = NSLocalizedString(@"You", @"referring to the superuser"); //sender.username;
        usernameLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];


        dateLabel.text = [challenge.timestamp timeAgo];
        dateLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        dateLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
        
        [sender getCorrectProfilePicWithImageView:myImageView];
        
        if ([challenge.recipients_count intValue] == 1){
            numberOfFriends.text = [NSString stringWithFormat:@"%@ friend",[challenge.recipients_count stringValue]];
        }
        else{
            numberOfFriends.text = [NSString stringWithFormat:@"%@ friends",[challenge.recipients_count stringValue]];
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
            
            [activeButton setImage:[UIImage imageNamed:CAPTIFY_ACTIVE_HISTORY] forState:UIControlStateNormal];
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

    

    if (active && !shared){

        
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
            UIImage *challenge_image = [Challenge loadImagewithFileName:challenge.local_image_path];
            ((HistoryDetailViewController *)vc).image = challenge_image;
            ((HistoryDetailViewController *)vc).myChallenge = challenge;
            ((HistoryDetailViewController *)vc).myUser = self.myUser;
            ((HistoryDetailViewController *)vc).sentHistory = YES;
            ((HistoryDetailViewController *)vc).mediaURL = [challenge.image_path isEqualToString:@""] ? nil:[NSURL URLWithString:challenge.image_path];
            DLog(@"%@ is image path",challenge.image_path);
            
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
            ((HistoryDetailViewController *)vc).mediaURL = [challenge.image_path isEqualToString:@""] ? nil:[NSURL URLWithString:challenge.image_path];
            ((HistoryDetailViewController *)vc).hideSelectButtons = YES;
            ((HistoryDetailViewController *)vc).hideSelectButtonsMax = YES;
            ((HistoryDetailViewController *)vc).sentHistory = YES;
            DLog(@"%@ is image path",challenge.image_path);
            
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
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    _data = [Challenge getHistoryChallengesForUser:self.myUser
                                              sent:YES];
    });
     */
    
    
    _data = [Challenge getHistoryChallengesForUser:self.myUser
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



- (UILabel *)errorLabel
{
    if (!_errorLabel){
        
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:17];
        _errorLabel.text = NSLocalizedString(@"No active challenges. Play captify below.", nil);
        _errorLabel.numberOfLines = 0;
        [_errorLabel sizeToFit];
        _errorLabel.textColor = [UIColor whiteColor];
        _errorLabel.frame = CGRectMake(35, 50, 300, 100);
        
        if ([self.data count] == 0){
            self.errorPlay = [UIButton buttonWithType:UIButtonTypeSystem];
            [self.errorPlay setBackgroundColor:[UIColor clearColor]];
            self.errorPlay.layer.cornerRadius = 5;
            self.errorPlay.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
            self.errorPlay.layer.borderWidth = CAPTIFY_BUTTON_LAYER;
            self.errorPlay.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
            [self.errorPlay setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
            [self.errorPlay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            CGRect labelFrame = _errorLabel.frame;
            self.errorPlay.frame = CGRectMake(labelFrame.origin.x + 33, labelFrame.size.height + 65, 175, 45);
            [self.errorPlay addTarget:self action:@selector(showHomeScreen:) forControlEvents:UIControlEventTouchUpInside];
            
            if (!IS_IPHONE5){
                CGRect playFrame = self.errorPlay.frame;
                playFrame.origin.y += 50;
                self.errorPlay.frame = playFrame;
            }
            
            [self.myTable addSubview:self.errorPlay];
        }

    }
    
    
    return _errorLabel;
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *a = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
        [a show];
        
    });
}



@end
