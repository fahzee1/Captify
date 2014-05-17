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
#import "UIViewController+TargetViewController.h"
#import "MZFormSheetController.h"
#import "ChallengeResponsesViewController.h"

#define TEST 1

@interface ChallengeViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic)CJPopup *successPop;
@property (strong, nonatomic)CJPopup *failPop;


@property (weak, nonatomic) IBOutlet UIView *captionContainerView;
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *data;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *viewResponsesButton;

@property (weak, nonatomic) IBOutlet UIView *countContainerView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic)UIBarButtonItem *nextButton;
@property (strong, nonatomic)UIBarButtonItem *backButton;

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
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    //self.navigationItem.title = NSLocalizedString(@"Challenge", @"All captions to showing on final screen");
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-folder-o"] style:UIBarButtonItemStylePlain target:self action:@selector(popToHistory)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = self.backButton;
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.scrollView.delegate = self;
    self.captionField.delegate = self;
    self.captionField.returnKeyType = UIReturnKeyDone;
    [self setupStylesAndMore];
    
    // so the scroll view positions right
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    
    [self setupTopLabel];
    
    
    self.retryButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:50];
    [self.retryButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"] forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    [self.retryButton addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.hidden = YES;
    [self.challengeImage addSubview:self.retryButton];
    self.challengeImage.userInteractionEnabled = YES;

    [self downloadImage];
    
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    
    if (!IS_IPHONE5){
        self.scrollView.contentSize = CGSizeMake(320, 610);
        
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
    
    if (!IS_IPHONE5){
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        
    }

}


- (void)viewWillAppear:(BOOL)animated
{
    [self setupTopLabel];
    
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Sent Menu Screen";
    }
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
       DLog(@"received memory warning here");
    
    
}

- (void)popToHistory
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)downloadImage
{
    DLog(@"%@",self.mediaURL);
    if (self.mediaURL){
        self.retryButton.hidden = YES;
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
        [self.challengeImage setImageWithURL:self.mediaURL
                         placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     long percent = receivedSize / expectedSize;
                                     self.progressView.progress = (float)percent;
                                     
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    self.progressView.hidden = YES;
                                    if (!image){
                                        double delayInSeconds = 2.0;
                                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                             self.retryButton.hidden = NO;
                                        });
                                        
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
    
    [self.viewResponsesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.viewResponsesButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateHighlighted];
    self.viewResponsesButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:14];
    
    NSString *responseText;
    if ([self.data count] > 0){
        if ([self.data count] == 1){
            responseText = [NSString stringWithFormat:@"View %lu response",(unsigned long)self.data.count];
        }
        else{
            responseText = [NSString stringWithFormat:@"View %lu responses",(unsigned long)self.data.count];

        }
         self.viewResponsesButton.userInteractionEnabled = YES;
    }
    else{
        responseText = NSLocalizedString(@"0 responses", nil);
        self.viewResponsesButton.userInteractionEnabled = NO;
    }
    [self.viewResponsesButton setTitle:responseText forState:UIControlStateNormal];
    
    self.challengeNameLabel.textColor = [UIColor whiteColor];
    if ([self.name length] > 35){
         self.challengeNameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    }
    else{
         self.challengeNameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:17];
    }
    
    self.challengeNameLabel.text = [self.name capitalizedString];
    self.challengeNameLabel.layer.borderWidth = 2;
    self.challengeNameLabel.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] CGColor];
    self.challengeNameLabel.layer.cornerRadius = 5;

    self.challengeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.challengeNameLabel.numberOfLines = 0;
    [self.challengeNameLabel sizeToFit];
    
    CGRect frame = self.challengeNameLabel.frame;
    self.challengeNameLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, self.challengeNameLabel.superview.bounds.size.width, 40);
    
    
    self.captionField.backgroundColor = [UIColor whiteColor];
    self.captionField.borderStyle = UITextBorderStyleNone;
    self.captionField.placeholder = NSLocalizedString(@"Enter caption here", nil);
    
    
    self.captionContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    self.captionContainerView.layer.cornerRadius = 5;
    
    self.countContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    //self.countContainerView.layer.cornerRadius = 10;
    
    self.countLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
    self.countLabel.textColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.countLabel.text = [NSString stringWithFormat:@"%d",CAPTION_LIMIT];
    
    
    

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
            image.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
          
            
        }

        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 15.0f;
        image.frame = navFrameBase;
        
        UILabel *friendName = [[UILabel alloc] initWithFrame:CGRectMake(navFrameBase.origin.x+45, navFrameBase.origin.y, navFrameBase.size.width+200, navFrameBase.size.height)];
        friendName.text = [[self.sender stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
        friendName.textColor = [UIColor whiteColor];
        friendName.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:16];
        
        if ([friendName.text length] >= 16){
            NSString *newString = [friendName.text substringToIndex:15];
            friendName.text = [NSString stringWithFormat:@"%@...",newString];
        }

        
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


- (IBAction)tappedViewResponsesButton:(UIButton *)sender {
    
    UIViewController *responsesRoot = [self.storyboard instantiateViewControllerWithIdentifier:@"challengeResponsesRoot"];
    if ([responsesRoot isKindOfClass:[UINavigationController class]]){
        UIViewController *responsesVC =  ((UINavigationController *)responsesRoot).topViewController;
        if ([responsesVC isKindOfClass:[ChallengeResponsesViewController class]]){
            ((ChallengeResponsesViewController *)responsesVC).myChallenge = self.myChallenge;
        }
    }
    

    MZFormSheetController *formSheet;
    if (!IS_IPHONE5){
        formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 300) viewController:responsesRoot];
    }
    else{
        formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 350) viewController:responsesRoot];
    }
    
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideAndBounceFromRight;
    
    [[MZFormSheetController sharedBackgroundWindow] setBackgroundBlurEffect:YES];
    [[MZFormSheetController sharedBackgroundWindow] setBlurRadius:5.0];
    [[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor clearColor]];
    
    [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        //
    }];
    
    

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


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger stringCount = 0;
    
    if (![string isEqualToString:@""]){
         stringCount = [textField.text length] + 1;
    }
    else{
        stringCount = [textField.text length] - 1;
    }
    
    if (stringCount > 0){
        self.countLabel.text = [NSString stringWithFormat:@"%ld",CAPTION_LIMIT - stringCount];
    }
    else{
        self.countLabel.text = [NSString stringWithFormat:@"%d",CAPTION_LIMIT];
    }
    
    //DLog(@"string count is %ld",(long)stringCount);
    //DLog(@"limit is %d",CAPTION_LIMIT);
    //DLog(@"final count is %ld",CAPTION_LIMIT - stringCount);
    
    if ([string isEqualToString:@""]){
        return YES;
    }
    
    if ([textField.text length] <= CAPTION_LIMIT){
        return YES;
    }
    else{
        return NO;
    }

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

/*
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SentCaptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = 10;
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    

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
            imageView.layer.cornerRadius = 30;

            
            if (pick.player.facebook_user){
                NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",pick.player.facebook_id];
                NSURL * fbUrl = [NSURL URLWithString:fbString];
                [imageView setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
                
            }
            
            else{
                imageView.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
                
            }
            
            
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
            
            usernameLabel.text = username;
            usernameLabel.textColor = [UIColor whiteColor];
            usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:14];

            
            captionLabel.text =[NSString stringWithFormat:@"\"%@\"",[pick.answer capitalizedString]];
        
            
            // set width and height so "sizeToFit" uses those constraints
            captionLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
            captionLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
            captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);
            captionLabel.numberOfLines = 0;
            [captionLabel sizeToFit];
            
            dateLabel.text = [pick.timestamp timeAgo];
            dateLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
            dateLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:11];

            
            
            
        }
    }
    return cell;

    
}
 */

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
        [_nextButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                              NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
        
    }
    return  _nextButton;
}

- (UIBarButtonItem *)backButton
{
    if (!_backButton){
        _backButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-folder-o"] style:UIBarButtonItemStylePlain target:self action:@selector(popToHistory)];
        [_backButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                             NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    }
    
    return _backButton;
}




@end
