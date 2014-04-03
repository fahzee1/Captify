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

@interface ShareViewController ()

@property (weak, nonatomic) IBOutlet UIButton *myShareButton;
@property (weak, nonatomic) IBOutlet UILabel *myFacebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *myInstagramLabel;
@property (weak, nonatomic) IBOutlet UILabel *myTwitterLabel;
@property (weak, nonatomic) IBOutlet UIView *shareContainer;
@property (weak, nonatomic) IBOutlet UILabel *facebookDisplayLabel;
@property (weak, nonatomic) IBOutlet UILabel *instagramDisplayLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterDisplayLabel;
@property (strong,nonatomic)SocialFriends *friends;
@property  BOOL fbSuccess;
@property BOOL twSuccess;


@property BOOL shareFacebook;
@property BOOL shareInstagram;
@property BOOL shareTwitter;

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
    self.shareFacebook = NO;
    self.shareInstagram = NO;
    [self setupShareStyles];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupShareStyles
{
    [self.myShareButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    self.shareImageView.image = self.shareImage;
    
    self.shareContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.myShareButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    [self.myShareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapFB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFB)];
    tapFB.numberOfTapsRequired = 1;
    tapFB.numberOfTouchesRequired = 1;
    
    self.myFacebookLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    self.myFacebookLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"];
    self.myFacebookLabel.textColor = [UIColor whiteColor];
    self.myFacebookLabel.userInteractionEnabled = YES;
    [self.myFacebookLabel addGestureRecognizer:tapFB];
    
    
    UITapGestureRecognizer *tapIG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInstagram)];
    tapIG.numberOfTapsRequired = 1;
    tapIG.numberOfTouchesRequired = 1;
    
    self.myInstagramLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    self.myInstagramLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-instagram"];
    self.myInstagramLabel.textColor = [UIColor whiteColor];
    self.myInstagramLabel.userInteractionEnabled = YES;
    [self.myInstagramLabel addGestureRecognizer:tapIG];
    
    
    UITapGestureRecognizer *tapTw = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTwitter)];
    self.myTwitterLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    self.myTwitterLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-twitter"];
    self.myTwitterLabel.textColor = [UIColor whiteColor];
    self.myTwitterLabel.userInteractionEnabled = YES;
    [self.myTwitterLabel addGestureRecognizer:tapTw];
    
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
        self.myFacebookLabel.textColor = [UIColor colorWithHexString:@"#3B5998"];
        self.facebookDisplayLabel.textColor = [UIColor colorWithHexString:@"#3B5998"];
        [self.myShareButton setTitle:@"Share" forState:UIControlStateNormal];
    
    }
    else{
        self.myFacebookLabel.textColor = [UIColor whiteColor];
        self.facebookDisplayLabel.textColor = [UIColor whiteColor];
        
        if (!self.shareTwitter && !self.shareInstagram){
            [self.myShareButton setTitle:@"Save" forState:UIControlStateNormal];
        }
    }
}

- (void)tappedInstagram
{
    self.shareInstagram = !self.shareInstagram;
    if (self.shareInstagram){
        self.myInstagramLabel.textColor = [UIColor colorWithHexString:@"#3f729b"];
        self.instagramDisplayLabel.textColor = [UIColor colorWithHexString:@"#3f729b"];
        [self.myShareButton setTitle:@"Share" forState:UIControlStateNormal];

    }
    else{
        self.myInstagramLabel.textColor = [UIColor whiteColor];
        self.instagramDisplayLabel.textColor = [UIColor whiteColor];
        if (!self.shareTwitter && !self.shareFacebook){
            [self.myShareButton setTitle:@"Save" forState:UIControlStateNormal];
        }

    }
}


- (void)tappedTwitter
{
    NSLog(@"tapped twitter");
    self.shareTwitter = !self.shareTwitter;
    if (self.shareTwitter){
        self.myTwitterLabel.textColor = [UIColor colorWithHexString:@"#00aced"];
        self.twitterDisplayLabel.textColor = [UIColor colorWithHexString:@"#00aced"];
        [self.myShareButton setTitle:@"Share" forState:UIControlStateNormal];
    }
    else{
        self.myTwitterLabel.textColor = [UIColor whiteColor];
        self.twitterDisplayLabel.textColor = [UIColor whiteColor];
        if (!self.shareInstagram && !self.shareFacebook){
            [self.myShareButton setTitle:@"Save" forState:UIControlStateNormal];
        }

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

- (IBAction)tappedShare:(UIButton *)sender {
    // after share show success overlay or alert or something
    // then pop to root
    [self saveImage];
    

    if (self.shareFacebook){
        NSString *albumID = [[NSUserDefaults standardUserDefaults] objectForKey:@"albumID"];
        if (!albumID){
            albumID = @"NEED TO GRAB THIS";
        }
        
        [self.friends postImageToFacebookFeed:self.shareImage
                              message:@"Or nah?"
                              caption:@"Or nah?"
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
                                     caption:@"..."
                                       block:^(BOOL wasSuccessful) {
                                           if (wasSuccessful){
                                               NSLog(@"post to twitter success");
                                               self.twSuccess = YES;
                                           }
                                        }];
    }
    
    if (self.shareFacebook){
        if (!self.fbSuccess){
            [self showAlertWithTitle:@"Facebook Error!" message:@"There was an error sharing your photo to Facebook."];
            return;
        }
    }
    
    if (self.shareTwitter){
        if (!self.twSuccess){
            [self showAlertWithTitle:@"Twitter Error!" message:@"There was an error sharing your photo to Twitter."];
            return;
        }
    }
    
    
    NSDictionary *params = @{@"challenge_id": self.myChallenge.challenge_id,
                             @"pick_id":self.myPick.pick_id};
    [Challenge updateChallengeWithParams:params
                                   block:^(BOOL wasSuccessful, NSString *message) {
                                       if (wasSuccessful){
                                           
                                           self.myChallenge.shared = [NSNumber numberWithBool:YES];
                                           self.myChallenge.active = [NSNumber numberWithBool:NO];
                                           NSError *error;
                                           if (![self.myChallenge.managedObjectContext save:&error]){
                                               NSLog(@"%@",error);
                                           }
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.navigationController popToRootViewControllerAnimated:YES];
                                           });

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



@end
