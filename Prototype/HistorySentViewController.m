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
    //self.data = [[NSArray alloc] initWithObjects:@"'Guess what happened next'\r by joe_bryant22",@"'The silver bullets shoots first' \rby quiver_hut",@"'I think I look good, what about you?'\r by dSanders21",@"' I got the juice' \r by theCantoon",@"' Its the loving by the moon' \r by darkness",@"'Fruits and veggies'\r by fruity_cup",@"'Lets get guapo' \r by d_rose",@"' The trinity' \r by splacca",@"'Yolo' \r by on_fire",@"'IAm' \r by IAM", nil];

}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTable deselectRowAtIndexPath:[self.myTable indexPathForSelectedRow] animated:NO];
    
    [self fetchUpdates];
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
                                            
                                            NSString *baseUrlString = [[AwesomeAPICLient sharedClient].baseURL absoluteString];
                                            NSString *fullMediaUrl = [baseUrlString stringByAppendingString:media_url];
                                            
                                            NSDictionary *params = @{@"sender": self.myUser.username,
                                                                     @"context": self.myUser.managedObjectContext,
                                                                     @"recipients": recipients,
                                                                     @"recipients_count": recipients_count,
                                                                     @"challenge_name":name,
                                                                     @"active":active,
                                                                     @"challenge_id":challenge_id,
                                                                     @"media_url":fullMediaUrl
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
                                    
                                    
                                }];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historySentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell isKindOfClass:[HistorySentCell class]]){
        UILabel *myLabel = ((HistorySentCell *)cell).myCaptionLabel;
        UIImageView *myImageView = ((HistorySentCell *)cell).myImageVew;
        UILabel *numberOfFriends = ((HistorySentCell *)cell).sentToLabel;
        UILabel *dateLabel = ((HistorySentCell *)cell).myDateLabel;
        UILabel *activeLabel = ((HistorySentCell *)cell).activeLabel;
        
        Challenge *challenge = [self.data objectAtIndex:indexPath.row];
        User *sender = challenge.sender;
        int active = [challenge.active intValue];
        int sentPick = [challenge.sentPick intValue];
        int shared = [challenge.shared intValue];
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
        


        if (active && !sentPick && !shared){
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        myLabel.text = [challenge.name capitalizedString];
        myLabel.frame = CGRectMake(myLabel.frame.origin.x, myLabel.frame.origin.y,176 , 30);
        myLabel.numberOfLines = 0;
        [myLabel sizeToFit];

        dateLabel.text = [challenge.timestamp timeAgo];
        
        [sender getCorrectProfilePicWithImageView:myImageView];
        
        if ([challenge.recipients_count intValue] == 1){
            numberOfFriends.text = [NSString stringWithFormat:@"%@ friend playing",[challenge.recipients_count stringValue]];
        }
        else{
            numberOfFriends.text = [NSString stringWithFormat:@"%@ friends playing",[challenge.recipients_count stringValue]];
        }
        
        // show green active circle
        activeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
        [activeLabel setTextColor:[UIColor greenColor]];
        
        if (active && !sentPick && !shared){
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
        else if (!shared) {
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
            [activeLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle-o"]];
            [activeLabel setTextColor:[UIColor redColor]];
            
        }

        

        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go to detail screen or go to challenge screen
    
    Challenge *challenge = [self.data objectAtIndex:indexPath.row];
    // check if active
    
    int active = [challenge.active intValue];
    int sentPick = [challenge.sentPick intValue];
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

    if (active && !sentPick && !shared){

        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
            UIImage *challenge_image = [Challenge loadImagewithFileName:challenge.image_path];
            ((HistoryDetailViewController *)vc).image = challenge_image;
            ((HistoryDetailViewController *)vc).myChallenge = challenge;
            ((HistoryDetailViewController *)vc).myUser = self.myUser;
            ((HistoryDetailViewController *)vc).mediaURL = [NSURL URLWithString:challenge.image_path];
            NSLog(@"%@ is image path",challenge.image_path);
            
             [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (!shared){
        
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
            UIImage *challenge_image = [Challenge loadImagewithFileName:challenge.image_path];
            ((HistoryDetailViewController *)vc).image = challenge_image;
            ((HistoryDetailViewController *)vc).myChallenge = challenge;
            ((HistoryDetailViewController *)vc).myUser = self.myUser;
            ((HistoryDetailViewController *)vc).mediaURL = [NSURL URLWithString:challenge.image_path];
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
