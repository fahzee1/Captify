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

@interface HistorySentViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) NSArray *data;
@property BOOL pendingRequest;
@property (strong, nonatomic) Notifications *notifications;
@property (strong, nonatomic)UIView *errorContainerView;
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


- (void)showHomeScreen
{
    // update the highlighted menu button to the screen we're about to show
    UIViewController *menu = self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) updateCurrentScreen:MenuHomeScreen];
    }

    UIViewController *camera = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHomeNavigation"];
    [self.sideMenuViewController setMainViewController:camera animated:YES closeMenu:NO];
}

- (void)fetchUpdates
{
    if (!self.pendingRequest){
        self.pendingRequest = YES;
        NSDate *lastFetch = [[NSUserDefaults standardUserDefaults] valueForKey:[Challenge fetchedHistoryKey]];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:[Challenge fetchedHistoryKey]];
        NSMutableDictionary *params =[@{@"username": self.myUser.username,
                                        @"type":@"sent"} mutableCopy];
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
                                        // create json objects
                                        id challenges = [data valueForKey:@"my_challenges"];
                                        
                                        id json;
                                        if ([challenges isKindOfClass:[NSString class]]){
                                            NSData *jsonString = [challenges dataUsingEncoding:NSUTF8StringEncoding];
                                            json = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:nil];
                                        }
                                        else if ([challenges isKindOfClass:[NSDictionary class]]){
                                            json = challenges;
                                        }
                                        
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
                                                [self.errorContainerView removeFromSuperview];
                                                self.errorContainerView = nil;
                                
                                            }
                                            else{
                                                if ([self.data count] == 0){
                                                    [self.myTable addSubview:self.errorContainerView];
                                                }

                                            }
                                            

                                            [self.refreshControl endRefreshing];
                                            [self.myTable reloadData];
                                        });
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historySentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.cornerRadius = 10;
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
    int firstOpen = [challenge.first_open intValue];
    
    if (firstOpen){
        [self.notifications removeOneNotifFromView:self.navigationController.navigationBar atPoint:historyNOTIFPOINT];
        challenge.first_open = [NSNumber numberWithBool:NO];
        NSError *error;
        if (![challenge.managedObjectContext save:&error]){
            DLog(@"%@",error);
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
            ((HistoryDetailViewController *)vc).mediaURL = [NSURL URLWithString:challenge.image_path];
            ((HistoryDetailViewController *)vc).hideSelectButtons = YES;
            ((HistoryDetailViewController *)vc).hideSelectButtonsMax = YES;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    _data = [Challenge getHistoryChallengesForUser:self.myUser
                                              sent:YES];
    });
    
    return _data;
}


- (Notifications *)notifications
{
    if (!_notifications){
        _notifications = [[Notifications alloc] init];
    }
    
    return _notifications;
}

- (UIView *)errorContainerView
{
    if (!_errorContainerView){
        
       _errorContainerView = [[UIView alloc] initWithFrame:self.myTable.frame];
       _errorContainerView.layer.cornerRadius = 10;
       _errorContainerView.layer.masksToBounds = YES;
       _errorContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        
        CGRect containerFrame = _errorContainerView.frame;
        containerFrame.size.width -= 15;
        containerFrame.size.height -= 250;
        containerFrame.origin.y += 25;
        containerFrame.origin.x += 7;
        _errorContainerView.frame = containerFrame;
        
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        errorLabel.text = @"Sheesh! Somebody needs to start sending their friends challenges!";
        errorLabel.numberOfLines = 0;
        [errorLabel sizeToFit];
        errorLabel.textColor = [UIColor whiteColor];
        errorLabel.frame = CGRectMake(15, 50, _errorContainerView.frame.size.width -20, 100);
        
        UIButton *play = [UIButton buttonWithType:UIButtonTypeSystem];
        play.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
        play.layer.cornerRadius = 10;
        play.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        [play setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
        [play setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
        CGRect labelFrame = errorLabel.frame;
        play.frame = CGRectMake(labelFrame.origin.x + 15, labelFrame.size.height + 45, 200, 50);
        [play addTarget:self action:@selector(showHomeScreen) forControlEvents:UIControlEventTouchUpInside];
        
        if (!IS_IPHONE5){
            CGRect playFrame = play.frame;
            playFrame.origin.y += 50;
            play.frame = playFrame;
        }
        

        
        [_errorContainerView addSubview:errorLabel];
        [_errorContainerView addSubview:play];

    }
    
    return _errorContainerView;
}




@end
