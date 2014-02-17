//
//  SenderPreviewViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SenderPreviewViewController.h"
#import "UIColor+HexValue.h"
#import "UIImage+RoundedCorners.h"
#import "SenderFriendsCell.h"

#define SCROLLPICMULTIPLY_VALUE 100
#define SCROLLPICADD_VALUE 22

@interface SenderPreviewViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,UIScrollViewDelegate,UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;

@property (weak, nonatomic) IBOutlet UIPickerView *phraseCountPicker;
@property (strong, nonatomic)NSArray *phraseCountNumbers;
@property (weak, nonatomic) IBOutlet UIScrollView *selectedFriendsScroll;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (strong, nonatomic)NSMutableArray *selectedFriendsArray;
@property (strong, nonatomic)NSMutableArray *selectedFriendsIndex;
@property (strong, nonatomic) NSArray *friendsArray;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic) UIButton *bottomSendButton;
@property CGPoint scrollStart;
@property (nonatomic, assign) NSInteger numberOfFields;

@end

@implementation SenderPreviewViewController

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
    self.phraseCountPicker.delegate = self;
    self.phraseCountPicker.dataSource = self;
    self.selectedFriendsScroll.delegate = self;
    self.friendsTable.delegate = self;
    self.friendsTable.dataSource = self;
    self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width, self.selectedFriendsScroll.frame.size.height);
    self.scrollStart = CGPointMake(self.toLabel.frame.origin.x + 20, 15);
    
    [self setupStyles];
    
    self.name = @"Guess what im eating";
    self.phrase = @"Nothing stupid";
    self.phraseCountNumbers = [[NSArray alloc] initWithObjects:@"One Word",@"Two Words",@"Three Words" ,nil];
    self.friendsArray = [[NSArray alloc] initWithObjects:@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM", nil];
    self.selectedFriendsArray = [[NSMutableArray alloc] init];
    self.selectedFriendsIndex = [[NSMutableArray alloc] init];
    
    self.topLabel.text = self.name;
    
}

- (void)dealloc
{
    if (self.phraseCountPicker.delegate == self){
        self.phraseCountPicker.delegate = nil;
    }
    if (self.phraseCountPicker.dataSource == self){
        self.phraseCountPicker.dataSource = nil;
    }
    if (self.selectedFriendsScroll.delegate == self){
        self.selectedFriendsScroll.delegate = nil;
    }
    if (self.friendsTable.delegate == self){
        self.friendsTable.delegate = nil;
    }
    
    if (self.friendsTable.dataSource == self){
        self.friendsTable.dataSource = nil;
    }

    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyles
{
    self.topLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#3498db"] CGColor];
    self.topLabel.textColor = [UIColor whiteColor];
    self.topLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    
    // the bottom label
    self.bottomLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.bottomLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    self.bottomLabel.textColor = [UIColor whiteColor];
    self.bottomLabel.layer.opacity = 0.6f;
    
    // the bottom send button
    self.bottomSendButton = [[UIButton alloc] initWithFrame:self.bottomLabel.frame];
    self.bottomSendButton.titleLabel.textColor = [UIColor whiteColor];
    [self.bottomSendButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.bottomSendButton setTitle:@"Send" forState:UIControlStateHighlighted];
    self.bottomSendButton.titleLabel.font = self.bottomLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25
    ];
    self.bottomSendButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.bottomSendButton.userInteractionEnabled = YES;
    [self.bottomSendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];



}

- (void)sendButtonTapped:(UIButton *)sender
{
    NSLog(@"send challenge to %@",[self.selectedFriendsArray description]);
}



#pragma -mark UIpicker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.phraseCountNumbers objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
        {
            self.numberOfFields = 1;
        }
            break;
            
        case 1:
        {
            self.numberOfFields = 2;
        }
            break;
        case 2:
        {
            self.numberOfFields = 3;
        }
            break;
            
        default:
            break;
    }
    
}

#pragma -mark UItableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friendsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    if (tableView == self.friendsTable){
        CellIdentifier = @"senderFriends";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell){
            ((SenderFriendsCell *)cell).myFriendUsername.text = [self.friendsArray objectAtIndex:indexPath.row];
            ((SenderFriendsCell *)cell).myFriendPic.image = [UIImage imageWithRoundedCornersSize:30.0f usingImage: [UIImage imageNamed:@"profile-placeholder"]];
            
            // add this to list of cells that have checkmarks
            if ([self.selectedFriendsIndex containsObject:indexPath]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }

    
        }
    }
    
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *selection = [self.friendsArray objectAtIndex:indexPath.row];
    if ([self.selectedFriendsArray containsObject:selection]){
        
          // remove user from list and and scroll view
        [self.selectedFriendsArray removeObject:selection];
        if (self.scrollStart.x > self.toLabel.frame.origin.x){
            self.scrollStart = CGPointMake(self.scrollStart.x-35, self.scrollStart.y);
            self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width -40, self.selectedFriendsScroll.frame.size.height);
        }
        UIView *userPic = [self.selectedFriendsScroll viewWithTag:(indexPath.row + SCROLLPICADD_VALUE) * SCROLLPICMULTIPLY_VALUE];
        if (userPic){
            if ([userPic.subviews count] == 0 && [userPic isKindOfClass:[UIImageView class]]){
            [userPic removeFromSuperview];
            }
            else{
                // not the userpic i want to remove
            }
        }
        
    }
    else{
        
        // get users pic , testing for now, add it to scroll
        UIImageView *testView = [[UIImageView alloc] initWithImage:[UIImage imageWithRoundedCornersSize:30.0f usingImage:[UIImage imageNamed:@"profile-placeholder"]]];
        testView.frame = CGRectMake(self.scrollStart.x, self.scrollStart.y, 30, 30);
        testView.layer.masksToBounds = YES;
        
        // set tag to a very unique value so we dont risk getting a tag for another view
        testView.tag = (indexPath.row + SCROLLPICADD_VALUE) * SCROLLPICMULTIPLY_VALUE;
        [self.selectedFriendsScroll addSubview:testView];
        
        // add horizontal space of 30 each image and 40 to scroll view
        // so you can actually see all images easily
        self.scrollStart = CGPointMake(self.scrollStart.x+35, self.scrollStart.y);
        self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width +40, self.selectedFriendsScroll.frame.size.height);
        
        // add user to selected list
        [self.selectedFriendsArray addObject:selection];

        
    
    }
    
    // add/remove indexpath of cells selected to add checkmarks
    if (![self.selectedFriendsIndex containsObject:indexPath]){
        [self.selectedFriendsIndex addObject:indexPath];
        
    }
    else{
        [self.selectedFriendsIndex removeObject:indexPath];
    }

    // if selected friend list is empty show "choose friends" label
    // else remove label and show send button
    if (![self.selectedFriendsArray count] == 0){
    
        self.bottomLabel.hidden = YES;
        [self.view addSubview:self.bottomSendButton];
        
    }
    else{
        [self.bottomSendButton removeFromSuperview];
        self.bottomLabel.hidden = NO;
    }
    
    // reload to show checkmarks
    [tableView reloadData];
}


@end
