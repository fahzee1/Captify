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
#import "AppDelegate.h"
#import "ChallengeViewController.h"
#import "UIImageView+WebCache.h"
#import "AwesomeAPICLient.h"


@interface HistoryRecievedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *cData;
@property (weak, nonatomic) IBOutlet UITableView *myTable;


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
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
	// Do any additional setup after loading the view.
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
    [User fetchUserBlobWithParams:@{@"username": self.myUser.username}
                            block:^(BOOL wasSuccessful, id data, NSString *message) {
                                if (wasSuccessful){
                                    id challenges = [data valueForKey:@"received_challenges"];
#warning loop through here and create challenges in core data
                                    /*
                                    NSData *json = [challenges dataUsingEncoding:NSUTF8StringEncoding];
                                    NSError *error;
                                    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
                                     */
                                    
                                }
                            }];
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
        
        titleLabel.text = [NSString stringWithFormat:@"%@ \r- %@",challenge.name,sender.username];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 200, titleLabel.frame.size.height);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 200, titleLabel.frame.size.height);
        
        dateLabel.text = [challenge.timestamp timeAgo];
        
        [sender getCorrectProfilePicWithImageView:KimageView];
        
        
        // check if challenge is active or not
        // if active show animating green filled circle, if not ahow circle outline
        activeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
        [activeLabel setTextColor:[UIColor greenColor]];
        if ([challenge.active intValue] == 1){
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
        
        
        
    }
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go to detail screen or go to challenge screen
    
    // check if active
    Challenge *challenge = [self.cData objectAtIndex:indexPath.row];
    if ([challenge.active intValue] == 1){
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"showChallenge"];
        if ([vc isKindOfClass:[ChallengeViewController class]]){
#warning load challenge image for inactive screen
            ((ChallengeViewController *)vc).myChallenge = challenge;
            ((ChallengeViewController *)vc).myUser = self.myUser;
            ((ChallengeViewController *)vc).name = challenge.name;
            ((ChallengeViewController *)vc).sender = challenge.sender.username;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    // challenge inactive show detail screen
    else{
        UIViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
#warning load challenge image for inactive screen
            ((HistoryDetailViewController *)vc).image = [UIImage imageNamed:@"brilliant-grill"];
            ((HistoryDetailViewController *)vc).myChallenge = challenge;
            ((HistoryDetailViewController *)vc).myUser = self.myUser;
            ((HistoryDetailViewController *)vc).hideSelectButtons = YES;
            ((HistoryDetailViewController *)vc).hideSelectButtonsMax = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }

    }
    
}


- (NSArray *)cData
{
    if (!_cData){
        _cData = [Challenge getHistoryChallengesInContext:self.myUser.managedObjectContext
                                                     sent:NO];
    }
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




@end