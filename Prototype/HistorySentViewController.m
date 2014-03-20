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
#import "AppDelegate.h"
#import "HistoryDetailViewController.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"

@interface HistorySentViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *data;
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
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    //self.data = [[NSArray alloc] initWithObjects:@"'Guess what happened next'\r by joe_bryant22",@"'The silver bullets shoots first' \rby quiver_hut",@"'I think I look good, what about you?'\r by dSanders21",@"' I got the juice' \r by theCantoon",@"' Its the loving by the moon' \r by darkness",@"'Fruits and veggies'\r by fruity_cup",@"'Lets get guapo' \r by d_rose",@"' The trinity' \r by splacca",@"'Yolo' \r by on_fire",@"'IAm' \r by IAM", nil];

}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (!_data){
        _data = [Challenge getHistoryChallengesInContext:self.myUser.managedObjectContext
                                                    sent:YES];
    }
    
    return _data;
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
        
        if ([challenge.active intValue] == 0){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else{
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        
        myLabel.text = challenge.name;
        myLabel.frame = CGRectMake(myLabel.frame.origin.x, myLabel.frame.origin.y,176 , 30);
        myLabel.numberOfLines = 0;
        [myLabel sizeToFit];

        dateLabel.text = [challenge.timestamp timeAgo];
        
        UIImage *thumbnail = [Challenge loadImagewithFileName:challenge.thumbnail_path];
        myImageView.image = thumbnail;
        /*
        FAImageView *imageView = (FAImageView *)myImageView;
        [imageView setDefaultIconIdentifier:@"fa-user"];
         */
        
        numberOfFriends.text = [NSString stringWithFormat:@"Sent to %@ friends",[challenge.recipients_count stringValue]];
        
        // show green active circle
        activeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
        [activeLabel setTextColor:[UIColor greenColor]];
        if ([challenge.active intValue] == 1){
            
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

        

        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go to detail screen or go to challenge screen
    
    Challenge *challenge = [self.data objectAtIndex:indexPath.row];
    // check if active
    
    if ([challenge.active intValue] == 1){
        
        UIViewController *vc;
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        if ([vc isKindOfClass:[HistoryDetailViewController class]]){
            UIImage *challenge_image = [Challenge loadImagewithFileName:challenge.image_path];
            ((HistoryDetailViewController *)vc).image = challenge_image;
             [self.navigationController pushViewController:vc animated:YES];
        }
    }
        
}





@end
