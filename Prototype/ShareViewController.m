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
#import "SocialFriends.h"
#import "MBProgressHUD.h"
#import "ParseNotifications.h"
#import "MGInstagram.h"
#import "FUISwitch.h"
#import "UIColor+FlatUI.h"
#import "HistoryContainerViewController.h"
#import "User+Utils.h"

#import <Pinterest/Pinterest.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>


typedef void (^ShareToNetworksBlock) ();

@interface ShareViewController ()<MFMessageComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *myShareButton;
@property (weak, nonatomic) IBOutlet UIButton *myFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *myInstagramButton;
@property (weak, nonatomic) IBOutlet UIButton *myTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *myMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *myPinterestButton;


@property (weak, nonatomic) IBOutlet UIView *shareContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic)MBProgressHUD *hud;
@property (strong,nonatomic)SocialFriends *friends;

// use prior to initial sends
@property  BOOL sendFB;
@property BOOL sendTW;
@property BOOL sendIG;
@property BOOL sendPIN;

// these should be marked as yes after posting
// use for no duplicate posts
@property  BOOL sentFB;
@property BOOL sentTW;
@property BOOL sentIG;
@property BOOL sentPIN;

@property BOOL shareFacebook;
@property BOOL shareInstagram;
@property BOOL shareTwitter;
@property BOOL sharePinterest;

@property BOOL haveNotified;

@end

#define PRIVACY_ON_TEXT @"YES"
#define PRIVACY_OFF_TEXT @"NO"

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
    self.navigationItem.title = NSLocalizedString(@"Share", nil);
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.shareFacebook = NO;
    self.shareInstagram = NO;
    self.sendTW = YES;
    self.sendFB = YES;
    self.sendIG = YES;
    self.sendPIN = YES;
    [self setupShareStyles];
    
    if (!IS_IPHONE5){
        self.scrollView.contentSize = CGSizeMake(320, 730+30);
        
    }
    else{
        self.scrollView.contentSize = CGSizeMake(320, 630+30);

    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //reset 
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isPrivate"];
    
    /*
    UIButton* pinItButton = [Pinterest pinItButton];
    [pinItButton addTarget:self
                    action:@selector(pinIt)
          forControlEvents:UIControlEventTouchUpInside];
    pinItButton.frame = self.myFacebookButton.frame;
    
    [self.view addSubview:pinItButton];
     */
    
    // need this for pinterest post
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBecomingActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Share Screen";
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
      DLog(@"received memory warning here");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
}


- (void)popToDetail
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupShareStyles
{
    [self.myShareButton setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    self.shareImageView.image = self.shareImage;
    
    self.shareContainer.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    self.shareContainer.layer.cornerRadius = 10;
    
    self.myShareButton.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    self.myShareButton.layer.cornerRadius = 10;
    self.myShareButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
    [self.myShareButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
    CGRect shareFrame = self.myShareButton.frame;
    shareFrame.origin.y += 80;
    self.myShareButton.frame = shareFrame;
    
    
    self.myFacebookButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    [self.myFacebookButton setTitle:NSLocalizedString(@"Facebook", nil) forState:UIControlStateNormal];
    [self.myFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.myFacebookButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.myFacebookButton.layer.borderWidth = CAPTIFY_BUTTON_LAYER;
    self.myFacebookButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.myFacebookButton.layer.cornerRadius = 5;

    
    
    self.myInstagramButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    [self.myInstagramButton setTitle:NSLocalizedString(@"Instagram", nil) forState:UIControlStateNormal];
  
    [self.myInstagramButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.myInstagramButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.myInstagramButton.layer.borderWidth = CAPTIFY_BUTTON_LAYER;
    self.myInstagramButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.myInstagramButton.layer.cornerRadius = 5;
    
    

    self.myTwitterButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    [self.myTwitterButton setTitle:NSLocalizedString(@"Twitter", nil) forState:UIControlStateNormal];
    
    [self.myTwitterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.myTwitterButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.myTwitterButton.layer.borderWidth = CAPTIFY_BUTTON_LAYER;
    self.myTwitterButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.myTwitterButton.layer.cornerRadius = 5;

    
    self.myMessageButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    [self.myMessageButton setTitle:NSLocalizedString(@"Message", nil) forState:UIControlStateNormal];
    
    [self.myMessageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.myMessageButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.myMessageButton.layer.borderWidth = CAPTIFY_BUTTON_LAYER;
    self.myMessageButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.myMessageButton.layer.cornerRadius = 5;

    
    
    self.myPinterestButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    [self.myPinterestButton setTitle:NSLocalizedString(@"Pinterest", nil) forState:UIControlStateNormal];
    
    [self.myPinterestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.myPinterestButton.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.myPinterestButton.layer.borderWidth = CAPTIFY_BUTTON_LAYER;
    self.myPinterestButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.myPinterestButton.layer.cornerRadius = 5;
    


    
    
    
    
    FUISwitch *privacySwitch = [[FUISwitch alloc] initWithFrame:CGRectMake(shareFrame.origin.x,shareFrame.origin.y -85, 100, 35)];
    privacySwitch.onColor = [UIColor colorWithHexString:CAPTIFY_ORANGE]; //[UIColor turquoiseColor];
    privacySwitch.offColor = [UIColor cloudsColor];
    privacySwitch.onBackgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_BLUE];//[UIColor midnightBlueColor];
    privacySwitch.offBackgroundColor = [UIColor silverColor];
    privacySwitch.offLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:14];
    privacySwitch.onLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:14];
    privacySwitch.onLabel.text = NSLocalizedString(PRIVACY_ON_TEXT, nil);
    privacySwitch.offLabel.text = NSLocalizedString(PRIVACY_OFF_TEXT, nil);
    privacySwitch.layer.cornerRadius = 15;
    [privacySwitch addTarget:self action:@selector(changedPrivacy:) forControlEvents:UIControlEventValueChanged];
    
    CGRect privacyFrame = privacySwitch.frame;
    privacyFrame.origin.x += 20;
    privacySwitch.frame = privacyFrame;

    
    UILabel *privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(privacyFrame.origin.x,
                                                                      privacyFrame.origin.y + privacyFrame.size.height - 20, 200, 70)];
    privacyLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:11];;
    privacyLabel.textColor = [UIColor whiteColor];
    privacyLabel.text = NSLocalizedString(@"Show in explore feed?", nil);
    
    
    
    [self.scrollView addSubview:privacyLabel];
    [self.scrollView addSubview:privacySwitch];
    
    

    
}

- (IBAction)tappedFacebook:(UIButton *)sender {
    [self tappedFB];
}

- (IBAction)tappedInstagram:(UIButton *)sender {
    [self tappedInstagram];
}


- (IBAction)tappedTwiiter:(UIButton *)sender {
    [self tappedTwitter];
}

- (IBAction)tappedMessage:(UIButton *)sender {
    [self tappedMessage];
}

- (IBAction)tappedPinterest:(UIButton *)sender {
    [self tappedPinterest];
}




- (void)handleBecomingActive
{
    // because pinterest sdk actually sends you to their app
    // to post, must detect when our app is active again to resume
    // operations
    
    if (self.sentPIN){
        self.sentPIN = NO;
        
        if (self.shareInstagram){
            [self sendInstagram];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }

    }

}



- (void)pinIt
{
    Pinterest *pinterst = [[Pinterest alloc] initWithClientId:PINTEREST_APPID];
    if ([pinterst canPinWithSDK]){
        self.sentPIN = YES;
    [pinterst createPinWithImageURL:[NSURL URLWithString:@"http://placekitten.com/500/400"] sourceURL:[NSURL URLWithString:@"http://placekitten.com"] description:@"Pinning from Pin It Demo"];
    }
    else{
        [self showAlertWithTitle:@"error" message:@"cant send"];
    }
}


- (void)changedPrivacy:(FUISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (sender.isOn){
        [defaults setBool:NO forKey:@"isPrivate"];

    }
    else{
        [defaults setBool:YES forKey:@"isPrivate"];
    }
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
    

    if (![self.myChallenge.sender.facebook_user intValue] == 1){
    
        [self.friends hasFacebookAccess:^(BOOL wasSuccessful) {
            
                if (wasSuccessful){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.shareFacebook = !self.shareFacebook;
                        if (self.shareFacebook){
                            self.myFacebookButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_FACEBOOK] CGColor];
                            [self.myFacebookButton setBackgroundColor:[UIColor colorWithHexString:CAPTIFY_FACEBOOK]];
                            [self.myFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        }
                        else{
                            self.myFacebookButton.layer.borderColor = [[UIColor whiteColor] CGColor];
                            [self.myFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            [self.myFacebookButton setBackgroundColor:[UIColor clearColor]];
                            
                            
                        }
                        

                    });
                    
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Make sure you've allowed Captify to use Facebook in iOS Settings > Privacy > Facebook", nil)];
                    });

                }
            

        }];
    }
    // logged in with fbook
    else{
        self.shareFacebook = !self.shareFacebook;
        if (self.shareFacebook){
            self.myFacebookButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_FACEBOOK] CGColor];
            [self.myFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.myFacebookButton setBackgroundColor:[UIColor colorWithHexString:CAPTIFY_FACEBOOK]];
            
        }
        else{
            [self.myFacebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.myFacebookButton setBackgroundColor:[UIColor clearColor]];
            self.myFacebookButton.layer.borderColor = [[UIColor whiteColor] CGColor];
            
        }
        
     }
    
   }

- (void)tappedInstagram
{
    if (self.sharePinterest){
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry can't share to Pinterest and Instagram at the same time. Your image will be saved in your photo library, so share from there.", nil)];
        return;
    }


    if ([self.friends hasInstagramAccess]){

        self.shareInstagram = !self.shareInstagram;
        if (self.shareInstagram){
            self.myInstagramButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_INSTAGRAM] CGColor];
            [self.myInstagramButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.myInstagramButton setBackgroundColor:[UIColor colorWithHexString:CAPTIFY_INSTAGRAM]];

        }
        else{
            self.myInstagramButton.layer.borderColor = [[UIColor whiteColor] CGColor];
            [self.myInstagramButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.myInstagramButton setBackgroundColor:[UIColor clearColor]];
            if (!self.shareTwitter && !self.shareFacebook){
            }

        }
    }
    else{
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Download the Instagram app to share", nil)];

    }
    
    /*
    
    if (self.shareInstagram){
        
        [self shareToFacebookAndTwitterWithBlock:^{
            // attempts to share to the above networks if selected
            // then show instagram option when thats done since we
            // must leave the app for that share
            
            [self.hud hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.shareFacebook && self.shareTwitter){
                    [self showAlertWithTitle:@"Success" message:@"Your photo was shared to Facebook and Twitter. Press Ok to share to Instagram."];
                }
                
                else if (self.shareFacebook){
                    [self showAlertWithTitle:@"Success" message:@"Your photo was shared to Facebook. Press Ok to share to Instagram."];
                    
                }
                
                else if (self.shareTwitter){
                    [self showAlertWithTitle:@"Success" message:@"Your photo was shared to Twitter. Press Ok to share to Instagram."];
                    
                }

            });
            
            if ([MGInstagram isAppInstalled] && [MGInstagram isImageCorrectSize:self.shareImage]){
                [self.hud hide:YES];
                [MGInstagram setPhotoFileName:kInstagramOnlyPhotoFileName];
                [MGInstagram postImage:self.shareImage
                           withCaption:self.selectedCaption
                                inView:self.view
                              delegate:self];
            }
            else
            {
                    [self.hud hide:YES];
                DLog(@"Error Instagram is either not installed or image is incorrect size");
                [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Instagram is either not installed or image is incorrect size", nil)];
                
                self.myInstagramLabel.textColor = [UIColor whiteColor];
            }
           
        }];
    }
     */
    

}


- (void)tappedTwitter
{
    [self.friends hasTwitterAccess:^(BOOL wasSuccessful) {
        if (wasSuccessful){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.shareTwitter = !self.shareTwitter;
                if (self.shareTwitter){
                    self.myTwitterButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_TWITTER] CGColor];
                    [self.myTwitterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [self.myTwitterButton setBackgroundColor:[UIColor colorWithHexString:CAPTIFY_TWITTER]];
                    //[self.myTwitterButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_TWITTER] forState:UIControlStateNormal];
                    
                }
                else{
                    self.myTwitterButton.layer.borderColor = [[UIColor whiteColor] CGColor];
                    [self.myTwitterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [self.myTwitterButton setBackgroundColor:[UIColor clearColor]];
                    if (!self.shareInstagram && !self.shareFacebook){
                    }
                    
                }

            });
           
        }
        else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Make sure you've allowed Captify to use Twiiter in iOS Settings > Privacy > Twitter", nil)];
        });

        }
    }];
    
}


- (void)tappedPinterest
{
    if (self.shareInstagram){
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry can't share to Pinterest and Instagram at the same time. Your image will be saved in your photo library, so share from there.", nil)];
        return;
    }
    

   
    if ([self.friends hasPinterestAccess]){

        self.sharePinterest = !self.sharePinterest;
        if (self.sharePinterest){
            self.myPinterestButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_PINTEREST] CGColor];
            [self.myPinterestButton setBackgroundColor:[UIColor colorWithHexString:CAPTIFY_PINTEREST]];
            [self.myPinterestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        }
        else{
            self.myPinterestButton.layer.borderColor = [[UIColor whiteColor] CGColor];
            [self.myPinterestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.myPinterestButton setBackgroundColor:[UIColor clearColor]];

        }
    }
    else{
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Download the Pinterest app to pin", nil)];

    }
}
- (void)tappedMessage
{
    if(![MFMessageComposeViewController canSendText]) {
        [self showAlertWithTitle:@"Error" message:@"Your device doesn't support SMS!"];
        return;
    }
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Loading..", nil);
    self.hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.hud.color = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.8];
    
    
    MFMessageComposeViewController *composer = [[MFMessageComposeViewController alloc] init];
    composer.messageComposeDelegate = self;
    composer.body = [self shareCaption]; //NSLocalizedString(@"Check out my pic from Captify!", nil);
    
    if ([MFMessageComposeViewController canSendAttachments]){
        
        float compression;
        if (!IS_IPHONE5){
            compression = 0.5;
        }
        else{
            compression = 0.3;
        }

        NSData *attachment = UIImageJPEGRepresentation(self.shareImage, compression);
        [composer addAttachmentData:attachment typeIdentifier:@"public.data" filename:[NSString stringWithFormat:@"%@.jpg",self.myChallenge.challenge_id]];
        [self presentViewController:composer animated:YES completion:^{
            [self.hud hide:YES];
        }];
    }
    

}

- (void)testPost
{
    [self.friends postImage:self.shareImage block:^(BOOL wasSuccessful) {
        if (wasSuccessful){
            DLog(@"good money");
        }
    }];
}

- (NSString *)shareCaption
{
    return [NSString stringWithFormat:@"Captify by %@",[self.myPick.player displayName]];
}

- (void)notifyFriends
{
    
    ParseNotifications *p = [ParseNotifications new];
    
    NSString *channel = [self.myChallenge.challenge_id stringByReplacingOccurrencesOfString:@"." withString:@"-"];
    [p checkForChannelAndRemove:channel];
    
    // notify all receipients of challenge
    [p sendNotification:[NSString stringWithFormat:@"%@ chose a caption!",[self.myChallenge.sender displayName]]
              toChannel:channel
               withData:@{@"challenge_id": self.myChallenge.challenge_id}
       notificationType:ParseNotificationSenderChoseCaption
                  block:nil];
    
    if (![self.myPick.player isEqual:self.myChallenge.sender]){
        // notify chosen captions sender
        [p sendNotification:[NSString stringWithFormat:@"You captified %@!",[self.myChallenge.sender displayName]]
                   toFriend:self.myPick.player.username
                   withData:@{@"challenge_id": self.myChallenge.challenge_id}
           notificationType:ParseNotificationNotifySelectedCaptionSender
                      block:nil];
    }
    
    
    

}


- (void)shareToFacebookAndTwitterWithBlock:(ShareToNetworksBlock)block
{
    
    if (!self.shareTwitter && !self.shareInstagram && !self.shareFacebook && !self.sharePinterest){
        [self showAlertWithTitle:@"Error" message:NSLocalizedString(@"Choose a network to share too", nil)];
        return;
    }

    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = NSLocalizedString(@"Sharing", nil);
    self.hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.hud.detailsLabelText = NSLocalizedString(@"and saving to photo library", nil);
    self.hud.detailsLabelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.hud.color = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.8];
    
    if (self.shareFacebook){
        self.hud.labelText = NSLocalizedString(@"Sharing to Facebook", nil);
        if (USE_GOOGLE_ANALYTICS){
            id tracker = [[GAI sharedInstance] defaultTracker];
            NSString *targetUrl = @"https://developers.google.com/analytics";
            [tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:@"Facebook" action:@"Share" target:targetUrl] build]];
        }
        
        if (USE_GOOGLE_ANALYTICS){
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UI_Actions"
                                                                  action:@"facebook"
                                                                   label:@"share"
                                                                   value:nil] build]];
        }
        

        if (block){
            [self sendFacebookWithBlock:block];
        }
        else{
            [self sendFacebookWithBlock:nil];
        }
        
        
    }
    
    if (self.shareTwitter){
        if (USE_GOOGLE_ANALYTICS){
            id tracker = [[GAI sharedInstance] defaultTracker];
            NSString *targetUrl = @"https://developers.google.com/analytics";
            [tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:@"Twitter" action:@"Share" target:targetUrl] build]];
        }
        
        if (USE_GOOGLE_ANALYTICS){
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UI_Actions"
                                                                  action:@"twitter"
                                                                   label:@"share"
                                                                   value:nil] build]];
        }

        if (block){
            [self sendTwitterWithBlock:block];
        }
        else{
            [self sendTwitterWithBlock:nil];
        }

        
    }
    
    
    if (self.shareInstagram){
        [self sendInstagram];
        self.sendIG = YES;
    }

    
    if (!self.shareFacebook && !self.shareTwitter){
    
        if (self.sharePinterest){
            self.sendPIN = YES;
            [self updateChallengeOnBackend];
        }
    }
    
    
    
    
    

}

- (void)sendFacebookWithBlock:(ShareToNetworksBlock)block
{

    if (!self.sentFB){
        [self.friends postImageToFacebookFeed:self.shareImage
                                      message:[self shareCaption]
                                      caption:[self shareCaption]
                                         name:[self shareCaption]
                                      albumID:nil
                                 facebookUser:[self.myChallenge.sender.facebook_user boolValue]
                                    feedBlock:^(BOOL wasSuccessful) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            //[self.hud hide:YES];
                                        });

                                        if (wasSuccessful){
                                            DLog(@"posting to feed was successful");
                                            self.sentFB = YES;
                                            if (self.shareTwitter){
                                                if (block){
                                                    [self sendTwitterWithBlock:block];
                                                }
                                                else{
                                                    [self sendTwitterWithBlock:nil];
                                                }
                                            }
                                            else if (self.sharePinterest){
                                                // this block is updateChallengeOnBackend which
                                                // is where pinterest code runs
                                                if (block){
                                                    block();
                                                }

                                            }
                                            else if (self.shareInstagram){
                                                [self sendInstagram];
                                            }
                                            else{
                                                if (block){
                                                    block();
                                                }
                                            }
                                            
                                        }
                                        else{
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.hud hide:YES];
                                            });

                                            [self showAlertWithTitle:NSLocalizedString(@"Facebook Error!", nil)
                                                             message:NSLocalizedString(@"There was an error sharing your photo to Facebook", nil)];
                                            return;
                                            
                                        }
                                    }];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
        });
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Already shared to Facebook", nil)];
        return;
    }
}

- (void)sendTwitterWithBlock:(ShareToNetworksBlock)block
{
    if (!self.sentTW){
        if (self.sendTW){
            self.sendTW = NO;
            [self.friends postImageToTwitterFeed:self.shareImage
                                         caption:[self shareCaption]
                                           block:^(BOOL wasSuccessful, BOOL isGranted) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [self.hud hide:YES];
                                               });
                                               
                                               if (wasSuccessful){
                                                   DLog(@"post to twitter success");
                                                   self.sentTW = YES;
                                                   
                                                   if (self.sharePinterest){
                                                       // this block is updateChallengeOnBackend which
                                                       // is where pinterest code runs

                                                       if (block){
                                                           block();
                                                       }
                                                   }
                                                   
                                                   else if (self.shareInstagram){
                                                       [self sendInstagram];
                                                   }
                                                   
                                                   else if (block){
                                                       block();
                                                   }
                                                   
                                               }
                                               else{
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [self.hud hide:YES];
                                                   });

                                                   if (isGranted){
                                                       [self showAlertWithTitle:NSLocalizedString(@"Twitter Error!", nil)
                                                                        message:NSLocalizedString(@"There was an error sharing your photo to Twitter", nil)];
                                                   }
                                                   return;
                                               }
                                           }];
        }
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
        });

        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Already shared to Twitter", nil)];
    }
}

- (void)sendInstagram
{
    if (self.sendIG){
        self.sendIG = NO;
        if ([self.friends hasInstagramAccess] && [self.friends hasInstagramCorrectSize:self.shareImage]){
            [self.hud hide:YES];
            
            
            [self.friends postImageToInstagram:self.shareImage
                                   withCaption:[self shareCaption]
                                        inView:self.scrollView
                                      delegate:self];
        }
        else
        {
            [self.hud hide:YES];
            DLog(@"Error Instagram is either not installed or image is incorrect size");
            [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Instagram is either not installed or image is incorrect size", nil)];
            
            
        }
    }

}


- (void)startShare
{
    // share goes in this order...
    // first try facebook
    // then try twitter
    // then try instagram (problem for pinterst)
    

    [self saveImage];
    
    [self shareToFacebookAndTwitterWithBlock:^{
    
        [self updateChallengeOnBackend];
        
    }];

}


- (IBAction)tappedShare:(UIButton *)sender {
    
    
    if (!self.shareTwitter && !self.shareInstagram && !self.shareFacebook && !self.sharePinterest){
        [self showAlertWithTitle:@"Error" message:NSLocalizedString(@"Choose a network to share too", nil)];
        return;
    }

    
    NSString *shareString = @"Share to";
    if (self.shareFacebook){
        shareString = [shareString stringByAppendingString:@" Facebook"];
    }
    if (self.shareTwitter){
        if (self.shareFacebook){
            shareString = [shareString stringByAppendingString:@",Twitter"];
        }
        else{
            shareString = [shareString stringByAppendingString:@" Twitter"];
        }
    }
    
    if (self.shareInstagram){
        if (self.shareFacebook || self.shareTwitter){
            shareString = [shareString stringByAppendingString:@",Instagram"];
        }
        else{
            shareString = [shareString stringByAppendingString:@" Instagram"];
        }
    }
    
    if (self.sharePinterest){
        if (self.shareFacebook || self.shareTwitter || self.shareInstagram){
            shareString = [shareString stringByAppendingString:@", Pinterest"];
        }
        else{
            shareString = [shareString stringByAppendingString:@" Pinterest"];
        }
    }

    
    UIActionSheet *popUp = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:shareString, nil];
    
    [popUp showFromRect:self.myShareButton.frame inView:self.view animated:YES];

    
    
    
}

- (void)saveImage:(UIImage *)image
         filename:(NSString *)name
{
    // filename can be /test/another/test.jpg
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
        NSData* data = UIImageJPEGRepresentation(image, 0.9);
        [data writeToFile:path atomically:YES];
    }
}


- (UIImage *)loadImagewithFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}


- (BOOL)removeCurrentImageFromFiles
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    BOOL removed;
    if ([manager fileExistsAtPath:self.myChallenge.local_image_path]){
        removed = [manager removeItemAtPath:self.myChallenge.local_image_path error:&error];
        
        if (!removed){
            DLog(@"%@",error);
        }
    }
    else{
        removed = NO;
    }
    
    return removed;
}

- (void)updateChallengeOnBackend
{
    float compression;
    if (!IS_IPHONE5){
        compression = 0.7;
    }
    else{
        compression = 0.5;
    }

    NSData *imageData = UIImageJPEGRepresentation(self.shareImage, compression);
    
    
    NSData *mediaData = [imageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *mediaName = [NSString stringWithFormat:@"%@.jpg",self.myChallenge.challenge_id];
    
    BOOL removed = [self removeCurrentImageFromFiles];
    if (removed){
        [Challenge saveImage:imageData filename:mediaName];
    }
    
    
    NSMutableDictionary *params = [@{@"challenge_id": self.myChallenge.challenge_id,
                                     @"pick_id":self.myPick.pick_id} mutableCopy];
    if (mediaData){

        NSString *media = [[NSString alloc] initWithBytes:mediaData.bytes length:mediaData.length encoding:NSUTF8StringEncoding];
        if (media && mediaName){
            params[@"media"] = media;
            params[@"media_name"] = mediaName;
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isPrivate = [defaults boolForKey:@"isPrivate"];
    params[@"is_private"] = [NSNumber numberWithBool:isPrivate];

    [Challenge updateChallengeWithParams:params
                                   block:^(BOOL wasSuccessful, NSString *mediaUrl) {
                                       //[self.hud hide:YES];
                                       if (wasSuccessful){
                                           // sending image url in message response
                                           
                    
                                           self.myChallenge.shared = [NSNumber numberWithBool:YES];
                                           self.myChallenge.active = [NSNumber numberWithBool:NO];
                                           self.myPick.is_chosen = [NSNumber numberWithBool:YES];
                                           
                                           int playerScore = [self.myPick.player.score intValue];
                                           playerScore += 10;
                                           self.myPick.player.score = [NSString stringWithFormat:@"%d",playerScore];
                                           
                                           NSError *error;
                                           if (![self.myChallenge.managedObjectContext save:&error]){
                                               DLog(@"%@",error);
                                           }
                                           
                                           if (!self.haveNotified){
                                               [self notifyFriends];
                                               self.haveNotified = YES;
                                               
                                           }
                                           
                                           if (self.sharePinterest && mediaUrl){
                                               if ([self.friends hasPinterestAccess]){
                                                   self.sentPIN = YES;
                                                   if (self.sendPIN){
                                                       self.sendPIN = NO;
                                                       [self.friends postImageToPinterestWithUrl:[NSURL URLWithString:mediaUrl]
                                                                                        sourceUrl:[NSURL URLWithString:@"http://gocaptify.com"]
                                                                                   andDescription:[self shareCaption]];
                    
                                                   }
                                               }
                                               else{
                                                   [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Download the Pinterest app to pin", nil)];
                                               }
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
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *a = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
        [a show];

    });
}


#pragma -mark uiactionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        [self startShare];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    [actionSheet.subviews enumerateObjectsUsingBlock:^(id _currentView, NSUInteger idx, BOOL *stop) {
        if ([_currentView isKindOfClass:[UIButton class]]) {
            [((UIButton *)_currentView).titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
            // OR
            //[((UIButton *)_currentView).titleLabel setFont:[UIFont fontWithName:@"Exo2-SemiBold" size:17]];
        }
    }];
}


#pragma -mark Documents (share to IG) delegate
-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    
    if (USE_GOOGLE_ANALYTICS){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UI_Actions"
                                                              action:@"instagram"
                                                               label:@"share"
                                                               value:nil] build]];
    }

    if (!self.haveNotified){
        [self notifyFriends];
        self.haveNotified = YES;
    }

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //self.myChallenge.active = [NSNumber numberWithBool:NO];
        //self.myChallenge.shared = [NSNumber numberWithBool:YES];
        //self.myPick.is_chosen = [NSNumber numberWithBool:YES];
        //NSError *error;
        //if(![self.myChallenge.managedObjectContext save:&error]){
          //  DLog(@"%@",error);
            
        //}
        
        [self updateChallengeOnBackend];
        
        UIViewController *vc = self.navigationController.viewControllers[0];
        if ([vc isKindOfClass:[HistoryContainerViewController class]]){
            [((HistoryContainerViewController *)vc) showSentScreen];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
    
}


- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    if (USE_GOOGLE_ANALYTICS){
        id tracker = [[GAI sharedInstance] defaultTracker];
        NSString *targetUrl = @"https://developers.google.com/analytics";
        [tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:@"Instagram" action:@"Share" target:targetUrl] build]];
    }

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
            if (USE_GOOGLE_ANALYTICS){
                id tracker = [[GAI sharedInstance] defaultTracker];
                NSString *targetUrl = @"https://developers.google.com/analytics";
                [tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:@"SMS messaging" action:@"Share" target:targetUrl] build]];
            }
            
            if (USE_GOOGLE_ANALYTICS){
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UI_Actions"
                                                                      action:@"sms_text"
                                                                       label:@"share"
                                                                       value:nil] build]];
            }


            
            [self saveImage];
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.mode = MBProgressHUDModeIndeterminate;
            self.hud.labelText = @"Updating";
            self.hud.labelColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
            self.hud.color = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.8];

        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        //[self.hud hide:YES];
        if (result == MessageComposeResultSent){
             [self updateChallengeOnBackend];
        }
    }];
}


@end
