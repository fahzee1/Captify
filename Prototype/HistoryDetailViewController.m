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
#import "NSDate+TimeAgo.h"
#import "UIView+Screenshot.h"
#import "FacebookFriends.h"
#import "UIImage+Utils.h"



@interface HistoryDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property NSArray *data;
@property BOOL hideSelectButtons;
@property NSString *selectedCaption;
@property UIImageView *finalContainerScreen;
@property UIImage *finalImage;

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
    
    if (!self.hideSelectButtons){
        self.hideSelectButtons = NO;
    }
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureFinalScreen
{
    self.finalContainerScreen = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.finalContainerScreen.contentMode = UIViewContentModeScaleAspectFill;
    self.finalContainerScreen.image = self.myImageView.image;
    self.finalContainerScreen.alpha = 0;
    [self.view addSubview:self.finalContainerScreen];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.finalContainerScreen.alpha = 1;
                          self.navigationController.navigationBarHidden = YES;
                     } completion:^(BOOL finished) {
                         // do something
                     }];
 
}

- (void)captureFinalImage
{
    // hide controls
    
    self.finalImage = [self.view convertViewToImage];
    UIImageWriteToSavedPhotosAlbum(self.finalImage, nil, nil, nil);
    
}


- (void)selectedCaption:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTable];
    NSIndexPath *indexPath = [self.myTable indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil){
        self.selectedCaption = [self.data objectAtIndex:indexPath.row];
    }

    UIAlertView *confirm = [[UIAlertView alloc]
                            initWithTitle:@"Confirm"
                            message:[NSString stringWithFormat:@"Are you sure you want this caption? '%@' ",[self.data objectAtIndex:indexPath.row]]
                            delegate:self
                            cancelButtonTitle:@"Not sure"
                            otherButtonTitles:@"I'm sure", nil];
    [confirm show];
    
}


#pragma -mark Uialertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        self.selectedCaption = nil;
    }
    
    else if (buttonIndex == 1){
        self.hideSelectButtons = YES;
        [self.myTable reloadData];
        [self configureFinalScreen];
    }
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
    return @"Your friends say";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell isKindOfClass:[HistoryDetailCell class]]){
        UILabel *captionLabel = ((HistoryDetailCell *)cell).myCaptionLabel;
        UIButton *selectButton = ((HistoryDetailCell *)cell).mySelectButton;
        UILabel *dateLabel = ((HistoryDetailCell *)cell).myDateLabel;
        
        ((HistoryDetailCell *)cell).myImageVew.image = nil;
        FAImageView *imageView = ((FAImageView *)((HistoryDetailCell *)cell).myImageVew);
        [imageView setDefaultIconIdentifier:@"fa-user"];
        
        ((HistoryDetailCell *)cell).myCaptionLabel.text = [self.data objectAtIndex:indexPath.row];
    
        // set width and height so "sizeToFit" uses those constraints
      
        captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);

        captionLabel.numberOfLines = 0;
        [captionLabel sizeToFit];
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        dateLabel.text = [date timeAgo];
    
        
        
        [selectButton addTarget:self action:@selector(selectedCaption:) forControlEvents:UIControlEventTouchUpInside];
        if (self.hideSelectButtons){
            selectButton.hidden = YES;
        }
       
        /*
        [((HistoryDetailCell *)cell).mySelectButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:25]];
        [((HistoryDetailCell *)cell).mySelectButton.titleLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"]];
        [((HistoryDetailCell *)cell).mySelectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
         */
        
        
    }
    return cell;
    
}







@end
