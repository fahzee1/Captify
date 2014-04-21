//
//  ShareViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/4/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ShareViewController.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "UIColor+HexValue.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SocialFriends.h"
#import "MBProgressHUD.h"
#import "ParseNotifications.h"
#import "MGInstagram.h"
#import <MessageUI/MessageUI.h>

typedef void (^ShareToNetworksBlock) ();

@interface ShareViewController ()<MFMessageComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *myShareButton;
@property (weak, nonatomic) IBOutlet UILabel *myFacebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *myInstagramLabel;
@property (weak, nonatomic) IBOutlet UILabel *myTwitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *myMessageLabel;

@property (weak, nonatomic) IBOutlet UIView *shareContainer;
@property (strong,nonatomic)MBProgressHUD *hud;
@property (strong,nonatomic)SocialFriends *friends;
@property  BOOL fbSuccess;
@property BOOL twSuccess;
@property BOOL igSuccess;



@property BOOL shareFacebook;
@property BOOL shareInstagram;
@property BOOL shareTwitter;

@property BOOL haveNotified;

@end

@implementation ShareViewController

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
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popToDetail)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.shareFacebook = NO;
    self.shareInstagram = NO;
    [self setupShareStyles];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"check if this challenge is acive.. if not shoot back to history");
    if (!self.myChallenge.active){
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)popToDetail
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupShareStyles
{
    [self.myShareButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    self.shareImageView.image = self.shareImage;
    
    self.shareContainer.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    self.shareContainer.layer.cornerRadius = 10;
    
    self.myShareButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    self.myShareButton.layer.cornerRadius = 10;
    self.myShareButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
    [self.myShareButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapFB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFB)];
    tapFB.numberOfTapsRequired = 1;
    tapFB.numberOfTouchesRequired = 1;
    
    self.myFacebookLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    self.myFacebookLabel.text = [NSString stringWithFormat:@"%@   Facebook",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"]];
    
    NSMutableAttributedString *fbString = [[NSMutableAttributedString alloc] initWithString:self.myFacebookLabel.text];
    [fbString addAttribute:NSFontAttributeName value:[UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15] range:NSMakeRange(4, 8)];
    
    self.myFacebookLabel.attributedText = fbString;
    self.myFacebookLabel.textColor = [UIColor whiteColor];
    self.myFacebookLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.myFacebookLabel.layer.cornerRadius = 5;
    self.myFacebookLabel.userInteractionEnabled = YES;
    [self.myFacebookLabel addGestureRecognizer:tapFB];
    
    
    UITapGestureRecognizer *tapIG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInstagram)];
    tapIG.numberOfTapsRequired = 1;
    tapIG.numberOfTouchesRequired = 1;
    
    self.myInstagramLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    self.myInstagramLabel.text = [NSString stringWithFormat:@"%@   Instagram",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-instagram"]];
    NSMutableAttributedString *igString = [[NSMutableAttributedString alloc] initWithString:self.myInstagramLabel.text];
    [igString addAttribute:NSFontAttributeName value:[UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15] range:NSMakeRange(4, 9)];

    self.myInstagramLabel.attributedText = igString;
    self.myInstagramLabel.textColor = [UIColor whiteColor];
    self.myInstagramLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.myInstagramLabel.layer.cornerRadius = 5;
    self.myInstagramLabel.userInteractionEnabled = YES;
    [self.myInstagramLabel addGestureRecognizer:tapIG];
    
    
    UITapGestureRecognizer *tapTw = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTwitter)];
    self.myTwitterLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    self.myTwitterLabel.text = [NSString stringWithFormat:@"%@   Twitter",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-twitter"]];
    
    NSMutableAttributedString *twString = [[NSMutableAttributedString alloc] initWithString:self.myTwitterLabel.text];
    [twString addAttribute:NSFontAttributeName value:[UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15] range:NSMakeRange(4, 7)];

    self.myTwitterLabel.attributedText = twString;
    self.myTwitterLabel.textColor = [UIColor whiteColor];
    self.myTwitterLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.myTwitterLabel.layer.cornerRadius = 5;
    self.myTwitterLabel.userInteractionEnabled = YES;
    [self.myTwitterLabel addGestureRecognizer:tapTw];
    
    UITapGestureRecognizer *tapM = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMessage)];
    self.myMessageLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    self.myMessageLabel.text = [NSString stringWithFormat:@"%@   Message",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-comment"]];
    
    NSMutableAttributedString *msString = [[NSMutableAttributedString alloc] initWithString:self.myMessageLabel.text];
    [msString addAttribute:NSFontAttributeName value:[UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15] range:NSMakeRange(4, 7)];
    
    self.myMessageLabel.attributedText = msString;
    self.myMessageLabel.textColor = [UIColor whiteColor];
    self.myMessageLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
    self.myMessageLabel.layer.cornerRadius = 5;
    self.myMessageLabel.userInteractionEnabled = YES;
    [self.myMessageLabel addGestureRecognizer:tapM];

    
}

- (void)saveImage
{
    NSParameterAssert(self.shareImage);
    UIImageWriteToSavedPhotosAlbum(self.shareImage, nil, nil, nil);
}



- (void)tappedFB
{
    if (!FBSession.activeSession.isOpen){
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (error){
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                 message:error.localizedDescription
                                                                                                delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                 
                                                 [alert show];
                                             }
                                             else if (session.isOpen){
                                                 [self tappedFB];
                                             }
                                         }];
        
        return;
    }
    

    
    self.shareFacebook = !self.shareFacebook;
    if (self.shareFacebook){
        self.myFacebookLabel.textColor = [UIColor colorWithHexString:CAPTIFY_FACEBOOK];
        [self.myShareButton setTitle:@"Share" forState:UIControlStateNormal];
    
    }
    else{
        self.myFacebookLabel.textColor = [UIColor whiteColor];
        
        if (!self.shareTwitter && !self.shareInstagram){
            [self.myShareButton setTitle:@"Save" forState:UIControlStateNormal];
        }
    }
}

- (void)tappedInstagram
{
    self.shareInstagram = !self.shareInstagram;
    if (self.shareInstagram){
        self.myInstagramLabel.textColor = [UIColor colorWithHexString:CAPTIFY_INSTAGRAM];
        [self.myShareButton setTitle:@"Share" forState:UIControlStateNormal];

    }
    else{
        self.myInstagramLabel.textColor = [UIColor whiteColor];
        if (!self.shareTwitter && !self.shareFacebook){
            [self.myShareButton setTitle:@"Save" forState:UIControlStateNormal];
        }

    }
    
    if (self.shareInstagram){
        [self shareToFacebookAndTwitterWithBlock:^{
            // attempts to share to the above networks if selected
            // then show instagram option when thats done since we
            // must leave the app for that share
            
            [self.hud hide:YES];
            
            if ([MGInstagram isAppInstalled] && [MGInstagram isImageCorrectSize:self.shareImage]){
                [MGInstagram setPhotoFileName:kInstagramOnlyPhotoFileName];
                [MGInstagram postImage:self.shareImage
                           withCaption:self.selectedCaption
                                inView:self.view
                              delegate:self];
            }
            else
            {
                NSLog(@"Error Instagram is either not installed or image is incorrect size");
                [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Instagram is either not installed or image is incorrect size", nil)];
                
                  self.myInstagramLabel.textColor = [UIColor whiteColor];
            }

        }];
    }

}


- (void)tappedTwitter
{
    NSLog(@"tapped twitter");
    self.shareTwitter = !self.shareTwitter;
    if (self.shareTwitter){
        self.myTwitterLabel.textColor = [UIColor colorWithHexString:CAPTIFY_TWITTER];
        //self.twitterDisplayLabel.textColor = [UIColor colorWithHexString:@"#00aced"];
        [self.myShareButton setTitle:@"Share" forState:UIControlStateNormal];
    }
    else{
        self.myTwitterLabel.textColor = [UIColor whiteColor];
        if (!self.shareInstagram && !self.shareFacebook){
            [self.myShareButton setTitle:@"Save" forState:UIControlStateNormal];
        }

    }
}

- (void)tappedMessage
{
    if(![MFMessageComposeViewController canSendText]) {
        [self showAlertWithTitle:@"Error" message:@"Your device doesn't support SMS!"];
        return;
    }
    
    MFMessageComposeViewController *composer = [[MFMessageComposeViewController alloc] init];
    composer.messageComposeDelegate = self;
    composer.body = NSLocalizedString(@"Check out my pic from Captify!", nil);
    
    if ([MFMessageComposeViewController canSendAttachments]){
        NSData *attachment = UIImageJPEGRepresentation(self.shareImage, 0.1);
        [composer addAttachmentData:attachment typeIdentifier:@"public.data" filename:[NSString stringWithFormat:@"%@.jpg",self.myChallenge.challenge_id]];
        [self presentViewController:composer animated:YES completion:nil];
    }
    

}

- (void)testPost
{
    [self.friends postImage:self.shareImage block:^(BOOL wasSuccessful) {
        if (wasSuccessful){
            NSLog(@"good money");
        }
    }];
}


- (void)notifyFriends
{
    
    ParseNotifications *p = [ParseNotifications new];
    
    NSString *channel = [self.myChallenge.challenge_id stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    // notify all receipients of challenge
    [p sendNotification:[NSString stringWithFormat:@"%@ chose a caption!",self.myChallenge.sender.username]
              toChannel:channel
               withData:@{@"challenge_id": self.myChallenge.challenge_id}
       notificationType:ParseNotificationSenderChoseCaption
                  block:nil];
    
    // notify chosen captions sender
    [p sendNotification:[NSString stringWithFormat:@"%@ chose your caption!",self.myChallenge.sender.username]
               toFriend:@"cj.ogbuehi"  // this should be self.myPick.player.username
               withData:@{@"challenge_id": self.myChallenge.challenge_id}
       notificationType:ParseNotificationNotifySelectedCaptionSender
                  block:nil];
    
#warning send this notification to the player not myself
    

}


- (void)shareToFacebookAndTwitterWithBlock:(ShareToNetworksBlock)block
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"Saving/Sharing";
    
    if (self.shareFacebook){
        NSString *albumID = [[NSUserDefaults standardUserDefaults] objectForKey:@"albumID"];
        if (!albumID){
            albumID = @"NEED TO GRAB THIS";
        }
        
        [self.friends postImageToFacebookFeed:self.shareImage
                                      message:self.selectedCaption
                                      caption:self.selectedCaption
                                         name:@"A name"
                                      albumID:albumID
                                 facebookUser:[[NSUserDefaults standardUserDefaults] boolForKey:@"facebook_user"]
                                    feedBlock:^(BOOL wasSuccessful) {
                                        if (wasSuccessful){
                                            NSLog(@"posting to feed was successful");
                                            self.fbSuccess = YES;
                                        }
                                    }];
    }
    
    if (self.shareTwitter){
        [self.friends postImageToTwitterFeed:self.shareImage
                                     caption:self.selectedCaption
                                       block:^(BOOL wasSuccessful) {
                                           if (wasSuccessful){
                                               NSLog(@"post to twitter success");
                                               self.twSuccess = YES;
                                           }
                                       }];
    }
    
    
    if (self.shareFacebook){
        if (!self.fbSuccess){
            [self.hud hide:YES];
            [self showAlertWithTitle:NSLocalizedString(@"Facebook Error!", nil)
                             message:NSLocalizedString(@"There was an error sharing your photo to Facebook", nil)];
            return;
        }
    }
    
    if (self.shareTwitter){
        if (!self.twSuccess){
            [self.hud hide:YES];
            [self showAlertWithTitle:NSLocalizedString(@"Twitter Error!", nil)
                             message:NSLocalizedString(@"There was an error sharing your photo to Twitter", nil)];
            return;
        }
    }
    
    
    if (block){
        block();
    }
    
    

}


- (IBAction)tappedShare:(UIButton *)sender {
    // after share show success overlay or alert or something
    // then pop to root
    [self saveImage];
    
    [self shareToFacebookAndTwitterWithBlock:^{
        [self updateChallengeOnBackend];
    }];
    
    
    
}

- (void)updateChallengeOnBackend
{
    
    NSDictionary *params = @{@"challenge_id": self.myChallenge.challenge_id,
                             @"pick_id":self.myPick.pick_id};
    [Challenge updateChallengeWithParams:params
                                   block:^(BOOL wasSuccessful, NSString *message) {
                                       [self.hud hide:YES];
                                       if (wasSuccessful){
                                           
                                           self.myChallenge.shared = [NSNumber numberWithBool:YES];
                                           self.myChallenge.active = [NSNumber numberWithBool:NO];
                                           NSError *error;
                                           if (![self.myChallenge.managedObjectContext save:&error]){
                                               NSLog(@"%@",error);
                                           }
                                           
                                           if (!self.haveNotified){
                                               [self notifyFriends];
                                               self.haveNotified = YES;
                                           }
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self.navigationController popToRootViewControllerAnimated:YES];
                                           });
                                           
                                       }
                                       else{
                                           [self showAlertWithTitle:@"Error" message:@"There was an error updating your challenge. Try again"];
                                       }
                                   }];

    
}

- (SocialFriends *)friends
{
    if (!_friends){
        _friends = [[SocialFriends alloc] init];
    }
    return _friends;
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



#pragma -mark Documents (share to IG) delegate
-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    if (!self.haveNotified){
        [self notifyFriends];
        self.haveNotified = YES;
    }

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.myChallenge.active = [NSNumber numberWithBool:NO];
        self.myChallenge.shared = [NSNumber numberWithBool:YES];
        NSError *error;
        if(![self.myChallenge.managedObjectContext save:&error]){
            NSLog(@"%@",error);
            
        }

        [self.navigationController popToRootViewControllerAnimated:YES];
    });
    
}


#pragma -mark Message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            [self showAlertWithTitle:@"Error" message:@"Failed to send SMS"];
        }
            break;
        case MessageComposeResultSent:
        {
            [self saveImage];
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = @"Updating";

        }
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent){
             [self updateChallengeOnBackend];
        }
    }];
}


@end
