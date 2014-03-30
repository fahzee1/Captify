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

@interface ReceiverPreviewViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
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
    
    [self.previewImage addSubview:self.previewCaption];
    self.previewImage.clipsToBounds = YES;

    [self setupColors];
    [self setupOutlets];
    
    
	// Do any additional setup after loading the view.
}

- (void)dealloc
{
    self.image = nil;
    self.previewImage = nil;
}

- (void)setupOutlets
{
    self.errorCount = 3;
    self.previewImage.image = self.image;
    
    CGRect captionRect = self.previewCaption.frame;
    CGRect nameRect = self.previewChallengeName.frame;
    
    self.previewCaption.text = [self.caption capitalizedString];
    self.previewCaption.textAlignment = NSTextAlignmentCenter;
    self.previewCaption.font = [UIFont fontWithName:@"Chalkduster" size:25];
    self.previewCaption.numberOfLines = 0;
    [self.previewCaption sizeToFit];
    self.previewCaption.frame = CGRectMake(captionRect.origin.x, captionRect.origin.y, 300, 100);
    
    
    if ([self.challengeName length] > 35){
        self.previewChallengeName.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:15];
    }
    else{
        self.previewChallengeName.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    }
    self.previewChallengeName.text = [self.challengeName capitalizedString];
    self.previewChallengeName.textAlignment = NSTextAlignmentCenter;
    self.previewChallengeName.numberOfLines = 0;
    [self.previewChallengeName sizeToFit];
    self.previewChallengeName.frame = CGRectMake(nameRect.origin.x, nameRect.origin.y, 300, 50);
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startedLabelDrag:)];
    press.minimumPressDuration = 0.1;
    
    [self.previewCaption addGestureRecognizer:press];
    self.previewCaption.userInteractionEnabled = YES;
    self.previewImage.userInteractionEnabled = YES;

    
    
    

}
- (void)setupColors
{
       // title of challege
    self.previewChallengeName.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    self.previewChallengeName.textColor = [UIColor whiteColor];

    
    // the phrase
    self.previewCaption.font =  [UIFont fontWithName:@"Optima-ExtraBlack" size:21.5];
    self.previewCaption.textColor = [UIColor colorWithHexString:@"#3498db"];
    
    // the send button
    self.sendButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.layer.cornerRadius = 20.0f;
    
    

}

- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendRecieverPick:(UIButton *)sender
{
    NSDictionary *params = @{@"username": self.myUser.username,
                             @"challenge_id":self.myChallenge.challenge_id,
                             @"answer":self.previewCaption.text};
    
    [ChallengePicks sendCreatePickRequestWithParams:params
                                              block:^(BOOL wasSuccessful, BOOL fail, NSString *message, NSString *pick_id) {
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
                                                              NSLog(@"%@",error);
                                                          }
                                                      }
                                                      
                                                      [self.navigationController popToRootViewControllerAnimated:YES];

                                                      
                                                  }
                                                  else{
                                                      if (fail){
                                                            [self showAlertWithTitle:@"Error" message:message];
                                                          
                                                      }
                                                      else{
                                                          if (self.errorCount < 3){
                                                              [self showAlertWithTitle:@"Error" message:@"There was an error sending your caption. Try again."];
                                                              
                                                          }
                                                          else{
                                                              [self showAlertWithTitle:@"Bug" message:@"This might be a bug. Developer has been notified."];
                                                              MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
                                                              
                                                              if ([MFMailComposeViewController canSendMail])
                                                              {
#warning set correct email for live app
                                                                  tempMailCompose.mailComposeDelegate = self;
                                                                  [tempMailCompose setToRecipients:@[@"cj_ogbuehi@yahoo.com"]];
                                                                  [tempMailCompose setSubject:@"Theres a freaking bug!"];
                                                                  [tempMailCompose setMessageBody:[NSString stringWithFormat:@"I tried to send %@ a caption and I keep getting error alerts! Get this fixed now!",self.myChallenge.sender.username] isHTML:NO];
                                                                  [self presentViewController:tempMailCompose animated:YES completion:^{
                                                                  }];
                                                              }
                                                              
                                                              
                                                          }

                                                          
                                                           self.errorCount += 1;
                                                      }
                                                  }
                                              }];
    
    
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
