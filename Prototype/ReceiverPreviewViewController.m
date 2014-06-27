//
//  ReceiverPreviewViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ReceiverPreviewViewController.h"
#import "UIColor+HexValue.h"
#import "TWTSideMenuViewController.h"
#import "ChallengePicks+Utils.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"
#import "ParseNotifications.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"


@interface ReceiverPreviewViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *captionContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property int errorCount;
@end

@implementation ReceiverPreviewViewController

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
    // character limit of about 30 should be fine
    // for challenge name/title
    
    [super viewDidLoad];
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popToChallenge)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;

    self.navigationItem.title = NSLocalizedString(@"Preview", nil);
    
    [self.previewImage addSubview:self.previewCaption];
    self.previewImage.clipsToBounds = YES;

    [self setupColors];
    [self setupOutlets];
    
    if (!IS_IPHONE5){
        self.scrollView.contentSize = CGSizeMake(320, 675);
        
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    

    
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!IS_IPHONE5){
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog(@"received memory warning here");
}

- (void)dealloc
{
    self.image = nil;
    self.previewImage = nil;
}

- (void)setupOutlets
{
    self.errorCount = 0;
    self.previewImage.image = self.image;
    
    CGRect captionRect = self.previewCaption.frame;
    CGRect nameRect = self.previewChallengeName.frame;
    
    self.previewCaption.text = [self.caption capitalizedString];
    self.previewCaption.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.previewCaption.textAlignment = NSTextAlignmentCenter;
    self.previewCaption.font = [UIFont fontWithName:CAPTIFY_FONT_CAPTION size:35];
    self.previewCaption.numberOfLines = 0;
    [self.previewCaption sizeToFit];
    self.previewCaption.frame = CGRectMake(captionRect.origin.x, captionRect.origin.y, 300, 100);
    
    
    if ([self.challengeName length] > 35){
        self.previewChallengeName.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    }
    else{
        self.previewChallengeName.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:17];
    }
    self.previewChallengeName.text = [self.challengeName capitalizedString];
    self.previewChallengeName.layer.borderWidth = 2;
    self.previewChallengeName.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] CGColor];
    self.previewChallengeName.layer.cornerRadius = 5;
    self.previewChallengeName.textAlignment = NSTextAlignmentCenter;
    self.previewChallengeName.numberOfLines = 0;
    [self.previewChallengeName sizeToFit];
    self.previewChallengeName.frame = CGRectMake(nameRect.origin.x, nameRect.origin.y, self.previewChallengeName.superview.bounds.size.width, 50);
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startedLabelDrag:)];
    press.minimumPressDuration = 0.1;
    
    [self.previewCaption addGestureRecognizer:press];
    self.previewCaption.userInteractionEnabled = YES;
    self.previewImage.userInteractionEnabled = YES;
    
    self.captionContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];

    
    
    

}
- (void)setupColors
{
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
       // title of challege
    self.previewChallengeName.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:17];
    self.previewChallengeName.textColor = [UIColor whiteColor];

    
    // the phrase
    self.previewCaption.font =  [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:21.5];
    self.previewCaption.textColor = [UIColor colorWithHexString:@"#3498db"];
    
    // the send button
    self.sendButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    self.sendButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
    [self.sendButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
    [self.sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    self.sendButton.layer.cornerRadius = 10;
    
    self.captionContainerView.backgroundColor = [UIColor colorWithHexString:@"#f39c12"];
    self.captionContainerView.layer.cornerRadius = 5;
    
    

}


- (void)popToChallenge
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}


- (IBAction)sendRecieverPick:(UIButton *)sender
{
    NSString *date = [ChallengePicks dateStringFromDate:[NSDate date]];
    NSDictionary *params = @{@"username": self.myUser.username,
                             @"challenge_id":self.myChallenge.challenge_id,
                             @"answer":self.previewCaption.text,
                             @"date":date};
    

    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Sending", nil);
    hud.dimBackground = YES;
    hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    hud.color = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.8];


    
    [ChallengePicks sendCreatePickRequestWithParams:params
                                              block:^(BOOL wasSuccessful, BOOL fail, NSString *message, NSString *pick_id) {
                                                  [hud hide:YES];
                                                  if (wasSuccessful){
                                                      
                                                      
                                                      NSDictionary *params2 = @{@"player": self.myUser.username,
                                                                                @"context":self.myUser.managedObjectContext,
                                                                                @"is_chosen":[NSNumber numberWithBool:NO],
                                                                                @"answer":self.previewCaption.text,
                                                                                @"pick_id":pick_id,
                                                                                @"pick_chosen":[NSNumber numberWithBool:YES]};
                                                      ChallengePicks *pick = [ChallengePicks createChallengePickWithParams:params2];
                                                      if (pick){
                                                          NSError *error;
                                                          [self.myChallenge addPicksObject:pick];
                                                          self.myChallenge.sentPick = [NSNumber numberWithBool:YES];
                                                          if (![self.myChallenge.managedObjectContext save:&error]){
                                                              DLog(@"%@",error);
                                                              return;
                                                          }
                                                          
                                                          
                                                          [self notifyChallengeSender];
                                                          
                                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                                      }
                                                      
                                                      
                                                  }
                                                  else{
                                                      
                                                      if (fail){
                                                            [self showAlertWithTitle:@"Error" message:message];
                                                          
                                                      }
                                                      else{
                                                          if (self.errorCount < 3){
                                                              [self showAlertWithTitle:@"Error" message:message];
                                                              
                                                          }
                                                          else{
                                                              [self showAlertWithTitle:@"Bug" message:@"This might be a bug. Developer has been notified."];
                                                              MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
                                                              
                                                              if ([MFMailComposeViewController canSendMail])
                                                              {
                                                                  tempMailCompose.mailComposeDelegate = self;
                                                                  [tempMailCompose setToRecipients:@[@"help@gocaptify.com"]];
                                                                  [tempMailCompose setSubject:@"Theres a freaking bug!"];
                                                                  [tempMailCompose setMessageBody:[NSString stringWithFormat:@"I tried to send %@ a caption and I keep getting error alerts! Get this fixed now!",self.myChallenge.sender.username] isHTML:NO];
                                                                  [self presentViewController:tempMailCompose animated:YES completion:^{
                                                                  }];
                                                              }
                                                              
                                                              
                                                          }

                                                          
                                                        self.errorCount += 1;
                                                      }
                                                      
                                                      // if is no longer active is in error message
                                                      // mark challenge inactive
                                                      if ([message rangeOfString:@"is no longer active" options:NSCaseInsensitiveSearch].location != NSNotFound){
                                                          self.myChallenge.active = [NSNumber numberWithBool:NO];
                                                          NSError *error;
                                                          [self.myChallenge.managedObjectContext save:&error];
                                                      }

                                                  }
                                              }];
    
    
}

- (void)notifyChallengeSender
{
    
    ParseNotifications *p = [ParseNotifications new];
    
    [p addChannelWithChallengeID:self.myChallenge.challenge_id];
    
    /*
    [p sendNotification:[NSString stringWithFormat:@"Caption from %@",self.myUser.username]
              toFriend:self.myChallenge.sender.username
               withData:@{@"challenge_id": self.myChallenge.challenge_id}
       notificationType:ParseNotificationSendCaptionPick
                  block:nil];
     */
    
    [p sendNotification:[NSString stringWithFormat:@"Caption response from %@",[self.myUser displayName]]
               toFriend:self.myChallenge.sender.username
               withData:@{@"challenge_id": self.myChallenge.challenge_id}
       notificationType:ParseNotificationSendCaptionPick
                  block:nil];
    
}


- (void)startedLabelDrag:(UILongPressGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGPoint point = [gesture locationInView:view.superview];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //[self captionStartedDragging];
        }
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            view.center = point;
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //[self captionStoppedDragging];
        }
            break;
            
        default:
            break;
    }
}


- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    UIAlertView *a = [[UIAlertView alloc]
                      initWithTitle:title
                      message:message
                      delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    [a show];
}


#pragma -mark Mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}



@end
