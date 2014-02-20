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
@property (strong, nonatomic)NSMutableDictionary *selectedFriends;
@property (strong, nonatomic)NSMutableDictionary *selectedPositions;
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
    self.navigationController.navigationBarHidden = NO;
    self.phraseCountPicker.delegate = self;
    self.phraseCountPicker.dataSource = self;
    self.selectedFriendsScroll.delegate = self;
    self.friendsTable.delegate = self;
    self.friendsTable.dataSource = self;
    self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width, self.selectedFriendsScroll.frame.size.height);
    self.scrollStart = CGPointMake(self.toLabel.frame.origin.x + 30, 15);
    
    [self setupStyles];
    
    self.name = @"Guess what im eating";
    self.phrase = @"Nothing stupid";
    self.phraseCountNumbers = [[NSArray alloc] initWithObjects:@"One Word",@"Two Words",@"Three Words" ,nil];
    self.friendsArray = [[NSArray alloc] initWithObjects:@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM", nil];
 
    self.selectedFriends = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[@[]mutableCopy],@"friends",
                                                                               [@[]mutableCopy],@"index_paths",
                                                                               nil];
    self.selectedPositions = [[NSMutableDictionary alloc] init];
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
    NSLog(@"send challenge to %@",[self.selectedFriends[@"friends"] description]);
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
            if ([self.selectedFriends[@"index_paths"] containsObject:indexPath]){
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
    if ([self.selectedFriends[@"friends"] containsObject:selection]){
        
          // remove user from list and and scroll view
        
        NSInteger index = [self.selectedFriends[@"friends"] indexOfObject:selection];
        
        // remove friends from list and their positions
        [self.selectedFriends[@"friends"] removeObject:selection];
        [self.selectedPositions removeObjectForKey:selection];
        
        // temp list of all users after the removed user to resize positions
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (NSString *username in self.selectedFriends[@"friends"]){
            NSInteger tempIndex = [self.selectedFriends[@"friends"] indexOfObject:username];
            if ( tempIndex >= index){
                [temp addObject:username];
            }
        }
        
        // get remaining users tags to reposition view
        for (NSString *username in temp){
            int viewTag = [[self.selectedPositions objectForKey:username] intValue];
            UIView *view = [self.selectedFriendsScroll viewWithTag:viewTag];
            [UIView animateWithDuration:1.0f
                             animations:^{
                                 if (view.frame.origin.x >= self.toLabel.frame.origin.x +7){
                                     view.frame = CGRectMake(view.frame.origin.x - 35, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                                 }

                             }];

        }
        
        if (self.scrollStart.x >= self.toLabel.frame.origin.x +45){
            self.scrollStart = CGPointMake(self.scrollStart.x -35, self.scrollStart.y);
        }
       
       
        self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width -40, self.selectedFriendsScroll.frame.size.height);

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
        // add user to selected list
        
        [self.selectedFriends[@"friends"] addObject:selection];
        
        
        
        // get users pic , testing for now, add it to scroll
        UIImageView *testView = [[UIImageView alloc] initWithImage:[UIImage imageWithRoundedCornersSize:30.0f usingImage:[UIImage imageNamed:@"profile-placeholder"]]];
        
        testView.layer.masksToBounds = YES;
        
        // set tag to a very unique value so we dont risk getting a tag for another view
        testView.tag = (indexPath.row + SCROLLPICADD_VALUE) * SCROLLPICMULTIPLY_VALUE;
        
        // save views postion to slide into freed up space
        // "positions" is a list of dictionaries with key being username
        // and value being cgpoint
        self.selectedPositions[selection] = [NSNumber numberWithInt:testView.tag];
        
        if ([self.selectedFriends[@"friends"] count] > 1){
            //int tag = [[self.selectedPositions objectForKey:nameOfLast] intValue];
            self.scrollStart = CGPointMake(self.scrollStart.x +45, self.scrollStart.y);
            
        }
        
     
        testView.frame = CGRectMake(self.scrollStart.x, self.scrollStart.y, 35, 35);

        
        [self.selectedFriendsScroll addSubview:testView];
        
        
        self.selectedFriendsScroll.contentSize = CGSizeMake(self.selectedFriendsScroll.contentSize.width +48, self.selectedFriendsScroll.frame.size.height);
        
    

        
    
    }
    
    // add/remove indexpath of cells selected to add checkmarks
    // this list is used in cellforrowindexpath of tableview
    if (![self.selectedFriends[@"index_paths"] containsObject:indexPath]){
        [self.selectedFriends[@"index_paths"] addObject:indexPath];
        
    }
    else{
        [self.selectedFriends[@"index_paths"] removeObject:indexPath];
    }

    // if selected friend list is empty show "choose friends" label
    // else remove label and show send button
    if (![self.selectedFriends[@"friends"] count] == 0){
    
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