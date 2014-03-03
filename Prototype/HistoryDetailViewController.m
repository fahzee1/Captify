//
//  HistoryDetailViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/28/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryDetailViewController.h"
#import "HistoryDetailCell.h"
#import "NSString+FontAwesome.h"
#import "FAImageView.h"
#import "UIFont+FontAwesome.h"


@interface HistoryDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property NSArray *data;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;

@end

@implementation HistoryDetailViewController

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
    self.data = @[@"This is one long example of a caption that could be used",@"Buggy woggy its late right now",@"Wait a minute dont you hear me",@"She wanna have what you have",@"Yolo son!",@"Her ass cant handle it",@"Its alright, its Ok!"];
    
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Friends Captions";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell isKindOfClass:[HistoryDetailCell class]]){
        ((HistoryDetailCell *)cell).myImageVew.image = nil;
        FAImageView *imageView = ((FAImageView *)((HistoryDetailCell *)cell).myImageVew);
        [imageView setDefaultIconIdentifier:@"fa-user"];
        
        ((HistoryDetailCell *)cell).myCaptionLabel.text = [self.data objectAtIndex:indexPath.row];
        ((HistoryDetailCell *)cell).myCaptionLabel.numberOfLines = 0;
        [((HistoryDetailCell *)cell).myCaptionLabel sizeToFit];
        ((HistoryDetailCell *)cell).myCaptionLabel.preferredMaxLayoutWidth = 200;
        
        ((HistoryDetailCell *)cell).myDateLabel.text = @"30 mins ago";
        
        
        
    }
    return cell;
    
}







@end
