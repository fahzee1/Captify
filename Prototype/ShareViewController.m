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
#import "FacebookFriends.h"

@interface ShareViewController ()

@property (weak, nonatomic) IBOutlet UIButton *myShareButton;
@property (weak, nonatomic) IBOutlet UILabel *myFacebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *myInstagramLabel;
@property (weak, nonatomic) IBOutlet UIView *shareContainer;
@property (weak, nonatomic) IBOutlet UILabel *facebookDisplayLabel;

@property (weak, nonatomic) IBOutlet UILabel *instagramDisplayLabel;
@property (strong,nonatomic)FacebookFriends *friends;

@property BOOL shareFacebook;
@property BOOL shareInstagram;

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
    self.shareImageView.image = self.shareImage;
    
    self.shareContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.myShareButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    [self.myShareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapFB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFacebook)];
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
}

- (void)saveImage
{
    NSParameterAssert(self.shareImage);
    UIImageWriteToSavedPhotosAlbum(self.shareImage, nil, nil, nil);
}



- (void)tappedFacebook
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
                                                 [self tappedFacebook];
                                             }
                                         }];
        
        return;
    }
    

    
    self.shareFacebook = !self.shareFacebook;
    if (self.shareFacebook){
        self.myFacebookLabel.textColor = [UIColor colorWithHexString:@"#3B5998"];
        self.facebookDisplayLabel.textColor = [UIColor colorWithHexString:@"#3B5998"];
    }
    else{
        self.myFacebookLabel.textColor = [UIColor whiteColor];
        self.facebookDisplayLabel.textColor = [UIColor whiteColor];
    }
}

- (void)tappedInstagram
{
    self.shareInstagram = !self.shareInstagram;
    if (self.shareInstagram){
        self.myInstagramLabel.textColor = [UIColor colorWithHexString:@"#3f729b"];
        self.instagramDisplayLabel.textColor = [UIColor colorWithHexString:@"#3f729b"];

    }
    else{
        self.myInstagramLabel.textColor = [UIColor whiteColor];
        self.instagramDisplayLabel.textColor = [UIColor whiteColor];
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
        [self.friends postImageToFeed:self.shareImage
                              message:@"Or nah?"
                              caption:@"Or nah?"
                                 name:@"A name"
                              albumID:albumID
                            feedBlock:^(BOOL wasSuccessful) {
                                if (wasSuccessful){
                                    NSLog(@"posting to feed was successful");
                                }
                            } albumBlock:^(BOOL wasSuccessful) {
                                NSLog(@"posting to album was successful");
                            }];
    }
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
    
}

- (FacebookFriends *)friends
{
    if (!_friends){
        _friends = [[FacebookFriends alloc] init];
    }
    return _friends;
}




@end
