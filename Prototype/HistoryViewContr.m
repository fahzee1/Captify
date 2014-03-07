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

@interface HistoryRecievedViewController ()<UITableViewDataSource,UITableViewDelegate>

@property NSArray *data;
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
   
    self.data = [[NSArray alloc] initWithObjects:@"'Guess what happened next'\r by joe_bryant22",@"'The silver bullets shoots first' \rby quiver_hut",@"'I think I look good, what about you?'\r by dSanders21",@"' I got the juice' \r by theCantoon",@"' Its the loving by the moon' \r by darkness",@"'Fruits and veggies'\r by fruity_cup",@"'Lets get guapo' \r by d_rose",@"' The trinity' \r by splacca",@"'Yolo' \r by on_fire",@"'IAm' \r by IAM", nil];

	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTable deselectRowAtIndexPath:[self.myTable indexPathForSelectedRow] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma -mark Uitableview delegate

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
     static NSString *cellIdentifier = @"historyCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell && [cell isKindOfClass:[HistoryReceivedCell class]]){
        
        if ([[self.data objectAtIndex:indexPath.row] isEqualToString:@"' The trinity' \r by splacca"]){
            UIView *colo = [[UIView alloc] initWithFrame:cell.frame];
            colo.backgroundColor = [UIColor whiteColor];
            colo.layer.borderColor = [[[UIColor greenColor]colorWithAlphaComponent:0.5f] CGColor];
            colo.layer.borderWidth = 2.0f;
            colo.layer.cornerRadius = 10.0f;
            cell.backgroundView = colo;
        }
        else{
            UIView *colo = [[UIView alloc] initWithFrame:cell.frame];
            colo.backgroundColor = [UIColor whiteColor];
            colo.layer.borderColor = [[[UIColor redColor] colorWithAlphaComponent:0.5f] CGColor];
            colo.layer.borderWidth = 2.0f;
            colo.layer.cornerRadius = 10.0f;
            cell.backgroundView = colo;

        }
    
        UILabel *titleLabel = ((HistoryReceivedCell *)cell).historyTitleLabel;
        UILabel *activeLabel = ((HistoryReceivedCell *)cell).activeLabel;
        UIImageView *KimageView =  ((HistoryReceivedCell *)cell).historyImageView;
        titleLabel.text = [self.data objectAtIndex:indexPath.row];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 200, titleLabel.frame.size.height);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 200, titleLabel.frame.size.height);

      
        
        KimageView.image = nil;
        activeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
        
        // check if challenge is active or not
        // if active show animating green filled circle, if not ahow circle outline
        [activeLabel setTextColor:[UIColor greenColor]];
        if (1){
            
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
    
        }
        
        FAImageView *imageView = ((FAImageView *)KimageView);
        [imageView setDefaultIconIdentifier:@"fa-user"];
        
    }
    
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go to detail screen or go to challenge screen
    UIViewController *vc;
    if ([[self.data objectAtIndex:indexPath.section]isEqualToString:@"' The trinity' \r by splacca"]){
        
         vc = [self.storyboard instantiateViewControllerWithIdentifier:@"showChallenge"];
    }
    else{
          vc = [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
    }
    
    
    
    if ([vc isKindOfClass:[HistoryDetailViewController class]]){
        
        // give vc all the data it needs
    }
    else if ([vc isKindOfClass:[ChallengeViewController class]]){
        // give vc all data it needs
    }
    
    // if responded too dont push anything
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (NSArray *)cData
{
    if (!_cData){
        _cData = [Challenge getChallengesWithUsername:nil
                                          fromFriends:0
                                               getAll:YES
                                              context:self.myUser.managedObjectContext];
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
