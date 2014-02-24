//
//  HistoryViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryViewController.h"
#import "TWTSideMenuViewController.h"
#import "UIColor+HexValue.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "HistoryCell.h"
#import "FAImageView.h"

@interface HistoryViewController ()<UITableViewDataSource,UITableViewDelegate>

@property NSArray *data;
@property (weak, nonatomic) IBOutlet UITableView *myTable;


@end

@implementation HistoryViewController

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
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [button setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = button;
    
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
   
    self.data = [[NSArray alloc] initWithObjects:@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM", nil];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
    
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
    if (cell && [cell isKindOfClass:[HistoryCell class]]){
        ((HistoryCell *)cell).historyTitleLabel = [self.data objectAtIndex:indexPath.row];
        ((HistoryCell *)cell).historyImageView.image = nil;
        ((HistoryCell *)cell).activeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
        
        // check if challenge is active or not
        // if active show animating green filled circle, if not ahow circle outline
        [((HistoryCell *)cell).activeLabel setTextColor:[UIColor greenColor]];
        if (1){
            CABasicAnimation *colorPulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
            colorPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            colorPulse.fromValue = [NSNumber numberWithFloat:1.0];
            colorPulse.toValue = [NSNumber numberWithFloat:0.1];
            colorPulse.autoreverses = YES;
            colorPulse.duration = 0.8;
            colorPulse.repeatCount = FLT_MAX;
            [((HistoryCell *)cell).activeLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle"]];
            [((HistoryCell *)cell).activeLabel setTextColor:[UIColor greenColor]];
            [((HistoryCell *)cell).activeLabel.layer addAnimation:colorPulse forKey:nil];
        }
        else{
             [((HistoryCell *)cell).activeLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle-o"]];
    
        }
        
        FAImageView *imageView = ((FAImageView *)((HistoryCell *)cell).historyImageView);
        [imageView setDefaultIconIdentifier:@"fa-user"];
        
    }
    
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // go to detail screen
    NSLog(@"selected cell");
}



@end
