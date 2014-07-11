//
//  ChallengeResponsesViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 5/15/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengeResponsesViewController.h"
#import "UIColor+HexValue.h"
#import "ChallengePicks+Utils.h"
#import "HistoryDetailCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"
#import "User+Utils.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "UserProfileViewController.h"


@interface ChallengeResponsesViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) NSArray *data;

@end

@implementation ChallengeResponsesViewController

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
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] style:UIBarButtonItemStylePlain target:self action:@selector(closeScreen)];
    
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.myTable.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];;
    self.myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor clearColor];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.myTable reloadData];
    
    if (self.data.count > 2){
        CGPoint bottomOffset = CGPointMake(0, self.myTable.contentSize.height - self.myTable.bounds.size.height);
        [self.myTable setContentOffset:bottomOffset animated:YES];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeScreen
{
    [self.controller dismissAnimated:YES completionHandler:nil];

}



- (void)showProfile:(UITapGestureRecognizer *)sender
{
    NSString *friend;
    if ([sender.view isKindOfClass:[UILabel class]]){
        friend = ((UILabel *)sender.view).text;
    }
    
    
    [User showProfileOnVC:self
             withUsername:friend
               usingMZHud:NO
          fromExplorePage:YES
          showCloseButton:NO
        delaySetupWithTme:0.8f];
    
    
}



#pragma -mark Uitableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChallengePicks *pick = [self.data objectAtIndex:indexPath.section];
    if ([pick.answer length] > 40){
        return 110;
    }
    else{
        return 93;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
    
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"responsesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    //cell.layer.borderWidth = 2;
    //cell.layer.cornerRadius = 10;
    //cell.contentView.layer.cornerRadius = 10;
    //cell.backgroundView.layer.cornerRadius = 10;
    cell.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ChallengePicks *pick = [self.data objectAtIndex:indexPath.section];
    
    if ([pick isKindOfClass:[ChallengePicks class]]){
        
        if ([cell isKindOfClass:[HistoryDetailCell class]]){
            UILabel *captionLabel = ((HistoryDetailCell *)cell).myCaptionLabel;
            UILabel *dateLabel = ((HistoryDetailCell *)cell).myDateLabel;
            UILabel *usernameLabel = ((HistoryDetailCell *)cell).myUsername;
            UIImageView *imageView = ((HistoryDetailCell *)cell).myImageVew;
            
            [pick.player getCorrectProfilePicWithImageView:imageView];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = imageView.frame.size.height /2;
            
            
            
            [pick.player getCorrectProfilePicWithImageView:imageView];
            
            /*
            if ([pick.player.facebook_user intValue] == 1){
                NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",pick.player.facebook_id];
                NSURL * fbUrl = [NSURL URLWithString:fbString];
                [imageView setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]];
                
            }
            
            else if (pick.player.is_teamCaptify){
                imageView.image = [UIImage imageNamed:CAPTIFY_LOGO];
            }
            else{
                imageView.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
                
            }
             */
            
            
            /*
            NSString *username;
            if (pick.player.username){
                if ([pick.player.facebook_user intValue] == 1){
                    username = [[pick.player.username stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
                }
                else{
                    username = [pick.player.username capitalizedString];
                }
                
            }
            else{
                username = @"User";
            }
             */
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile:)];
            tap.numberOfTapsRequired = 1;
            [usernameLabel addGestureRecognizer:tap];
            usernameLabel.userInteractionEnabled = YES;
            usernameLabel.text = [pick.player displayName];
            usernameLabel.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
            usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:14];
            
            if ([usernameLabel.text length] >= 24){
                NSString *uString = [usernameLabel.text substringToIndex:23];
                usernameLabel.text = [NSString stringWithFormat:@"%@...",uString];
            }

            
            
            
            captionLabel.text =[NSString stringWithFormat:@"\"%@\"",[pick.answer capitalizedString]];
            
            
            // set width and height so "sizeToFit" uses those constraints
            captionLabel.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
            captionLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
            captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);
            captionLabel.numberOfLines = 0;
            [captionLabel sizeToFit];
            
            dateLabel.text = [pick.timestamp timeAgo];
            dateLabel.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
            dateLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:11];
            
            
            
            
        }
    }
    return cell;
    
    
}


- (NSArray *)data
{
    NSSet *picks = self.myChallenge.picks;
    _data = [picks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    return _data;
}

@end
