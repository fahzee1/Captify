//
//  ChallengeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengeViewController.h"
#import "AnswerFieldView.h"
#import "AppDelegate.h"
#import "Challenge+Utils.h"
#import "ChallengePicks+Utils.h"
#import "AwesomeAPICLient.h"
#import "CJPopup.h"
#import "ReceiverPreviewViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIColor+HexValue.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "FAImageView.h"
#import "HistoryDetailCell.h"
#import "NSDate+TimeAgo.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

#define TEST 1

@interface ChallengeViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic)CJPopup *successPop;
@property (strong, nonatomic)CJPopup *failPop;


@property (weak, nonatomic) IBOutlet UIView *captionContainerView;
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *data;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (strong, nonatomic)UIBarButtonItem *nextButton;

@end

@implementation ChallengeViewController

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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.scrollView.delegate = self;
    self.captionField.delegate = self;
    self.myTable.dataSource = self;
    self.myTable.delegate = self;
    self.captionField.returnKeyType = UIReturnKeyDone;
    [self setupStylesAndMore];
    
    // so the scroll view positions right
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    
    [self setupTopLabel];
    
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    self.retryButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:60];
    [self.retryButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"] forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.hidden = YES;
    [self.challengeImage addSubview:self.retryButton];
    self.challengeImage.userInteractionEnabled = YES;

    [self downloadImage];
    
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    
    if ([self.data count] == 0){
        [self.myTable removeFromSuperview];
    }
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    double delayInSeconds = 4.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!self.captionField.isFirstResponder){
            [self.captionField becomeFirstResponder];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupTopLabel];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.topLabel removeFromSuperview];
    [self.captionField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}


- (void)downloadImage
{
    
    if (self.mediaURL){
        self.retryButton.hidden = YES;
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
        [self.challengeImage setImageWithURL:self.mediaURL
                         placeholderImage:[UIImage imageNamed:@"profile-placeholder"]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     long percent = receivedSize / expectedSize;
                                     self.progressView.progress = (float)percent;
                                     
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    self.progressView.hidden = YES;
                                    if (!image){
                                        self.retryButton.hidden = NO;
                                        
                                    }
                                }];
        
    }
    
}



- (void)showPreviewScreen
{
    [self textFieldShouldReturn:self.captionField];
}

- (void)setupStylesAndMore
{
    // need a limit of 30 - 40 for title
    //self.challengeNameLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#3498db"] CGColor];
    self.challengeNameLabel.textColor = [UIColor whiteColor];
    if ([self.name length] > 35){
         self.challengeNameLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:15];
    }
    else{
         self.challengeNameLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    }
    
    self.challengeNameLabel.text = [self.name capitalizedString];
    self.challengeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.challengeNameLabel.numberOfLines = 0;
    [self.challengeNameLabel sizeToFit];
    
    CGRect frame = self.challengeNameLabel.frame;
    self.challengeNameLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, 300, 40);
    
    self.captionContainerView.backgroundColor = [UIColor colorWithHexString:@"#f39c12"];
    
    
    
    

}

- (void)setupTopLabel
{
    if (!self.topLabel){
        User *sender = self.myChallenge.sender;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        view.backgroundColor = [UIColor clearColor];
        CGRect navFrameBase = CGRectMake(100, 8, 30, 30);
        
        FAImageView *image = [[FAImageView alloc] init];
        if (sender.facebook_user){
            NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small",sender.facebook_id];
            NSURL * fbUrl = [NSURL URLWithString:fbString];
            [image setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
            
        }
        
        else{
            image.image = nil;
            FAImageView *imageView2 = (FAImageView *)image;
            [imageView2 setDefaultIconIdentifier:@"fa-user"];
            
        }

     
        image.frame = navFrameBase;
        UILabel *friendName = [[UILabel alloc] initWithFrame:CGRectMake(navFrameBase.origin.x+45, navFrameBase.origin.y, navFrameBase.size.width+200, navFrameBase.size.height)];
        friendName.text = self.sender;
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 15.0f;
        [view addSubview:image];
        [view addSubview:friendName];
        view.userInteractionEnabled = NO;
        view.tag = SENDERPICANDNAME_TAG;
        self.topLabel = view;
    }
    [self.navigationController.navigationBar addSubview:self.topLabel];
    

}

- (void)dealloc
{
    self.myUser = nil;
    self.myFriend = nil;
    self.myChallenge = nil;
   
}


- (void)chooseCaption
{
    self.answer = self.captionField.text;
    
}



- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
{
    if (!title){
        title = @"Results";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma -mark Lazy Instantiation
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



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self chooseCaption];
    
    if (textField.returnKeyType == UIReturnKeyDone){
        // check if caption is empty
        if ([self.answer length] != 0){
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"receiverPreviewRoot"];
            if ([vc isKindOfClass:[UINavigationController class]]){
                UIViewController *finalVc = ((UINavigationController *)vc).topViewController;
                if ([finalVc isKindOfClass:[ReceiverPreviewViewController class]]){
                    ReceiverPreviewViewController *finalVcGo = (ReceiverPreviewViewController *)finalVc;
                    finalVcGo.image = self.challengeImage.image;
                    finalVcGo.challengeName = self.name;
                    finalVcGo.caption = self.answer;
                    finalVcGo.myChallenge = self.myChallenge;
                    finalVcGo.myUser = self.myUser;
                    [self.navigationController pushViewController:finalVc animated:YES];
                }
                
            }
        }
        else{
            [self showAlertWithTitle:@"Error" message:@"Did you forget to enter your caption?"];
        }
        
    }
    

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

#pragma -mark Uitableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Sent captions";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SentCaptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ChallengePicks *pick = [self.data objectAtIndex:indexPath.row];
    
    if ([pick isKindOfClass:[ChallengePicks class]]){
        
        if ([cell isKindOfClass:[HistoryDetailCell class]]){
            UILabel *captionLabel = ((HistoryDetailCell *)cell).myCaptionLabel;
            UILabel *dateLabel = ((HistoryDetailCell *)cell).myDateLabel;
            UIImageView *imageView = ((HistoryDetailCell *)cell).myImageVew;
            
            [pick.player getCorrectProfilePicWithImageView:imageView];
            
            if (pick.player.facebook_user){
                NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small",pick.player.facebook_id];
                NSURL * fbUrl = [NSURL URLWithString:fbString];
                [imageView setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
                
            }
            
            else{
                imageView.image = nil;
                FAImageView *imageView2 = (FAImageView *)imageView;
                [imageView2 setDefaultIconIdentifier:@"fa-user"];
                
            }
            
            
            NSString *username;
            if (pick.player.username){
                username = [pick.player.username capitalizedString];
            }
            else{
                username = @"User";
            }
            
            
            NSString *me = [self.myUser.username capitalizedString];
            if ([username isEqualToString:me]){
                captionLabel.text = [NSString stringWithFormat:@"You said \r \r \"%@\"",pick.answer];
            }
            else{
                captionLabel.text = [NSString stringWithFormat:@"%@ said \r \r \"%@\"",username,pick.answer];
            }
        
            
            // set width and height so "sizeToFit" uses those constraints
            
            captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);
            captionLabel.numberOfLines = 0;
            [captionLabel sizeToFit];
            
            dateLabel.text = [pick.timestamp timeAgo];
            
            
        }
    }
    return cell;

    
}

#pragma -mark UIscrollview delegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.captionField resignFirstResponder];
}


- (NSArray *)data
{
    NSSet *picks = self.myChallenge.picks;
    _data = [picks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    
    return _data;
}


- (UIBarButtonItem *)nextButton
{
    if (!_nextButton){
        _nextButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-right"] style:UIBarButtonItemStylePlain target:self action:@selector(showPreviewScreen)];
        [_nextButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25]} forState:UIControlStateNormal];
        [_nextButton setTintColor:[UIColor greenColor]];
        
    }
    return  _nextButton;
}




@end
