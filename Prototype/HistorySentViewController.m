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

@interface HistorySentViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property NSArray *data;
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
    self.data = [[NSArray alloc] initWithObjects:@"'Guess what happened next'\r by joe_bryant22",@"'The silver bullets shoots first' \rby quiver_hut",@"'I think I look good, what about you?'\r by dSanders21",@"' I got the juice' \r by theCantoon",@"' Its the loving by the moon' \r by darkness",@"'Fruits and veggies'\r by fruity_cup",@"'Lets get guapo' \r by d_rose",@"' The trinity' \r by splacca",@"'Yolo' \r by on_fire",@"'IAm' \r by IAM", nil];

}

- (void)viewDidAppear:(BOOL)animated{
    [self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        myLabel.text = [self.data objectAtIndex:indexPath.row];
        
        myLabel.frame = CGRectMake(myLabel.frame.origin.x, myLabel.frame.origin.y,176 , 30);
        
        myLabel.numberOfLines = 0;
        [myLabel sizeToFit];

        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:60];
        dateLabel.text = [date timeAgo];
        
        myImageView.image = nil;
        FAImageView *imageView = (FAImageView *)myImageView;
        [imageView setDefaultIconIdentifier:@"fa-user"];
        
        numberOfFriends.text = [NSString stringWithFormat:@"%d",[self.data count]];
        

        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go to detail screen or go to challenge screen
    
    // check if active
    if (1){
        UIViewController *vc;
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"historyDetail"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}





@end
