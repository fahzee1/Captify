//
//  HomeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UIView+Screenshot.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "LoginViewController.h"
#import "User+Utils.h"
#import "Challenge+Utils.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ChallengeViewController.h"
#import "UIColor+HexValue.h"
#import "GoHomeTransition.h"
#import "ReceiverPreviewViewController.h"
#import "ChallengeViewController.h"
#import "UIColor+HexValue.h"
#import "GPUImage.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "SenderPreviewViewController.h"
#import "UIImage+Utils.h"
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SocialFriends.h"
#import "UIImage+Utils.h"
#import "CMPopTipView.h"
#import "HistoryContainerViewController.h"
#import "TestDataCreator.h"
#import "Contacts.h"
#import <Parse/Parse.h>
#import "ParseNotifications.h"
#import "ABWrappers.h"
#import "AwesomeAPICLient.h"


#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define ONEFIELD_TAG 1990
#define PHONE_LIMIT 12

@interface HomeViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ODelegate,SenderPreviewDelegate,MenuDelegate,UITextFieldDelegate, TWTSideMenuViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *snapPicButton;
@property CGRect firstFrame;
@property (weak, nonatomic) IBOutlet UIButton *topMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *rotateButton;

@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureDevice *cameraDevice;
@property (strong,nonatomic)AVCaptureDeviceInput *cameraInput;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic)AVCaptureStillImageOutput *snapper;
@property (strong,nonatomic)UIImageView *previewSnap;
@property (strong,nonatomic)UIImage *previewEditedSnapshot;
@property (strong,nonatomic)UIImage *previewOriginalSnapshot;
@property (strong, nonatomic)UIView *previewControls;
@property (strong, nonatomic)UIView *mainControls;
@property (strong, nonatomic)UIView *previewBackground;
@property (weak, nonatomic) IBOutlet UIButton *previewCancelButton;

@property (weak, nonatomic) IBOutlet UIView *previewCountContainerView;
@property (weak, nonatomic) IBOutlet UILabel *previewCountLabel;


@property (weak, nonatomic) IBOutlet UITextField *previewTextField;
@property (weak, nonatomic) IBOutlet UIButton *previewNextButton;

@property (weak, nonatomic) IBOutlet UIView *cameraOptionsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraOptionsButton;

@property (weak, nonatomic) IBOutlet UIView *previewOneFieldContainer;


@property (weak, nonatomic) IBOutlet UILabel *previewTextFieldIcon;

@property (nonatomic, strong)NSString *challengeTitle;
@property CGPoint finalPhraseLabelPostion;
@property (strong,nonatomic)CMPopTipView *toolTip;
@property (strong, nonatomic)UIAlertView *makePhoneAlert;
@property (strong, nonatomic)UITextField *makePhoneTextField;
@property (strong, nonatomic) NSArray *contactNumbers;
@property (strong,nonatomic) NSTimer *contactFetchTimer;
@property BOOL showHistory;
@property BOOL showingPreview;

@end

@implementation HomeViewController



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
    
    
    
     [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    
    //DLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL already = [defaults boolForKey:@"alreadyLogged"];
    
    if (!already){
        [self fetchContacts2];
        [defaults setBool:YES forKey:@"alreadyLogged"];
    }
    
    /*
    else{
        if (!self.contactFetchTimer){
            self.contactFetchTimer = [NSTimer scheduledTimerWithTimeInterval:60 * 10
                                                                      target:self
                                                                    selector:@selector(fetchContacts2)
                                                                    userInfo:nil repeats:YES];

        }
    }
     */
    
    
    [self createTeamCaptify];
    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[User name]];
     NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
    NSError *e;
    NSArray *t = [context executeFetchRequest:request error:&e];

    for (User *a in t){
        DLog(@"user:%@",a.username);
    }
     
     
    
    //NSLog(@"%@",self.myUser);
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"]){
    
        
        /*
         User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.myUser.managedObjectContext];
        user.super_user = [NSNumber numberWithBool:NO];
        user.is_friend = [NSNumber numberWithBool:YES];
        user.facebook_user = [NSNumber numberWithBool:YES];
        user.username = @"gumbo";
        NSError *e;
        [user.managedObjectContext save:&e];
        
        
        User *user2 = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.myUser.managedObjectContext];
        user2.super_user = [NSNumber numberWithBool:NO];
        user2.is_friend = [NSNumber numberWithBool:YES];
        user2.facebook_user = [NSNumber numberWithBool:YES];
        user2.username = @"Ally-Allen";
        [user.managedObjectContext save:&e];

        
        
        
        User *user4 = [TestDataCreator createTestFriendWithName:@"kona2" facebook:YES fbID:@"698982729" inContext:self.myUser.managedObjectContext];
        User *user6 = [TestDataCreator createTestFriendWithName:@"square" facebook:NO fbID:0 inContext:self.myUser.managedObjectContext];
        User *user3 = [TestDataCreator createTestFriendWithName:@"circle" facebook:YES fbID:@"698982729" inContext:self.myUser.managedObjectContext];
        
        
        
        
        User *user5 = [TestDataCreator createTestFriendWithName:@"gucci_77" facebook:YES fbID:[NSNumber numberWithInt:698982729] inContext:self.myUser.managedObjectContext];
        Challenge *challenge = [TestDataCreator createTestChallengeWithName:@"Making no noise yall boys aint making no noise" byUser:user2 toFriends:@[user,self.myUser] withID:@"0004"];
        
        [TestDataCreator addChallengePickToChallenge:challenge withPlayer:user caption:@"Yall look in drunk in love"];
        [TestDataCreator addChallengePickToChallenge:challenge withPlayer:self.myUser caption:@"We aint never going broke...this the shit i live for"];
        [TestDataCreator addChallengePickToChallenge:challenge withPlayer:user caption:@"Pour it for the dead homies"];
        [TestDataCreator addChallengePickToChallenge:challenge withPlayer:self.myUser caption:@"Well let me be the first to get mines"];
        */

    }
    
    //if user not logged in segue to login screen
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"logged"]){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }
    // used from settings to logout
    if (self.goToLogin){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }

    
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"]){
        PFInstallation *currentOnstallation = [PFInstallation currentInstallation];
        [currentOnstallation setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] forKey:@"username"];
      }

    
    self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    
    [self makeHomeMenuDelegate];


    
    
  
    
    
}


- (void)makeHomeMenuDelegate
{
    MenuViewController *menu = (MenuViewController *)self.sideMenuViewController.menuViewController;
    menu.delegate = self;
    
    self.sideMenuViewController.delegate = self;
}

- (void)shout
{
    NSLog(@"screaming");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Home screen";
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // got a camera
        [self setupCamera];
        
    }
    else{
        // using simulator with no camera so just add buttons
        
        [self setupTestNoCamera];
    }


    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self showAlertForPhoneNumber];
    
    if (self.showHistory){
        UIViewController *historyNav = [self.storyboard instantiateViewControllerWithIdentifier:@"rootHistoryNew"];
        if ([historyNav isKindOfClass:[UINavigationController class]]){
            ((UINavigationController *)historyNav).navigationBarHidden = NO;
            UIViewController *history = ((UINavigationController *)historyNav).topViewController;
            if ([history isKindOfClass:[HistoryContainerViewController class]]){
                UIViewController *menu = self.sideMenuViewController.menuViewController;
                if ([menu isKindOfClass:[MenuViewController class]]){
                    [((MenuViewController *)menu) updateCurrentScreen:MenuHistoryScreen];
                }
                
                ((HistoryContainerViewController *)history).showSentScreen = YES;
                [self.sideMenuViewController setMainViewController:historyNav animated:YES closeMenu:YES];
            }
            
        }
        
        self.showHistory = NO;

    }
    
    //[self testNotifs];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
       DLog(@"received memory warning here");
    
    self.myUser = nil;
    
    [self.contactFetchTimer invalidate];
    self.contactFetchTimer = nil;
    
    [AppDelegate clearImageCaches];
    
    //self.snapPicButton = nil;
    //self.topMenuButton = nil;
    //self.flashButton = nil;
    //self.rotateButton = nil;
    
    //self.session = nil;
    //self.cameraDevice = nil;
    //self.cameraInput = nil;
    //self.previewLayer = nil;


    
}


- (void)testNotifs
{
#define challengeID @"cj-0001-0002-0003"
    ParseNotifications *p = [[ParseNotifications alloc] init];
    NSArray *list = [NSArray arrayWithObjects:self.myUser.username,@"DEBA",@"cedric" ,nil];
    
    [p sendNotification:[NSString stringWithFormat:@"Challenge from %@",self.myUser.username]
                  toFriends:list
                   withData:@{@"challenge": challengeID}
           notificationType:ParseNotificationCreateChallenge
                      block:^(BOOL wasSuccessful) {
                          if (wasSuccessful){
                              DLog(@"sent notif");
                          }
                          else{
                              DLog(@"didnt send notif");
                          }
                      }];

    
    [p addChannelWithChallengeID:challengeID];
    
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [p sendNotification:[NSString stringWithFormat:@"Caption from %@",self.myUser.username]
                   toFriend:self.myUser.username
                   withData:@{@"challenge": challengeID}
           notificationType:ParseNotificationSendCaptionPick
                      block:^(BOOL wasSuccessful) {
                          if (wasSuccessful){
                              DLog(@"sent challenge pick notif");
                          }
                          else{
                              DLog(@"didnt send challenge pic notif");
                          }

                      }];

    });
    
    
    double delayInSeconds2 = 20.0;
    dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
    dispatch_after(popTime2, dispatch_get_main_queue(), ^(void){
        [p sendNotification:[NSString stringWithFormat:@"%@ chose a caption!",@"DEBA"]
                  toChannel:challengeID
                   withData:@{@"challenge_id": challengeID}
           notificationType:ParseNotificationSenderChoseCaption
                      block:^(BOOL wasSuccessful) {
                          if (wasSuccessful){
                              DLog(@"sent final notif");
                          }
                          else{
                              DLog(@"didnt send final notif");
                          }

                      }];

    });
    
    
}

- (void)createTeamCaptify
{
     static int retrys = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    
    BOOL createdTeamCaptify = [defaults boolForKey:@"createdTeamCaptify"];
    if (!createdTeamCaptify){
        
        if ([defaults valueForKey:@"username"]){
            NSDictionary  *params = @{@"username": @"Team-Captify",
                                      @"facebook_user":[NSNumber numberWithBool:NO],
                                      @"is_contact":[NSNumber numberWithBool:YES],
                                      @"is_teamCaptify":[NSNumber numberWithBool:YES]
                                      };
            
            
            User *captify = [User createFriendWithParams:params inMangedObjectContext:self.myUser.managedObjectContext];
            if (captify){
                [defaults setBool:YES forKey:@"createdTeamCaptify"];
            }
        }
        else{
            
            retrys += 1;
            if (retrys < 10){
                double delayInSeconds = 30.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self createTeamCaptify];
                });
            }
            
        }
    }

    
}


- (void)setupCamera
{
    // everything here is being lazy loaded because of memory issues
    
    NSError *error;
    
    // set flash
    [self.cameraDevice lockForConfiguration:&error];
    if ([self.cameraDevice isFlashModeSupported:AVCaptureFlashModeOn]){
            self.cameraDevice.flashMode = AVCaptureFlashModeOn;
    }
    [self.cameraDevice unlockForConfiguration];
    

    if (self.cameraInput){
        if ([self.session canAddInput:self.cameraInput]){
            [self.session addInput:self.cameraInput];
        }
    }
    if (self.snapper){
        if ([self.session canAddOutput:self.snapper]){
            [self.session addOutput:self.snapper];
        }
    }
    
    if (self.cameraInput && self.snapper){
        if (![self.view.layer.sublayers containsObject:self.previewLayer]){
            [self.view.layer addSublayer:self.previewLayer];
            [self.view addSubview:self.mainControls];
            [self setupStylesAndMore];
            
            
            [self.session startRunning];
        }
        
        
        
    }
    else{
        DLog(@"error creating camera input or output");
    }
    

}

- (void)setupTestNoCamera
{
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeSystem];
    [menu setTitle:NSLocalizedString(@"Menu", nil) forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    menu.frame = CGRectMake(50, 100, 60, 60);
    
    UIButton *preview = [UIButton buttonWithType:UIButtonTypeSystem];
    [preview setTitle:@"Preview" forState:UIControlStateNormal];
    [preview addTarget:self action:@selector(tappedNextPreview:) forControlEvents:UIControlEventTouchUpInside];
    preview.frame = CGRectMake(115, 100, 60, 60);
    
    UITextField *text = [[UITextField alloc] init];
    text.frame = CGRectMake(30, 0, 150, 100);
    text.text = @"enter text";
    text.tag = 5;
    text.backgroundColor = [UIColor clearColor];
    
    UIImage *image = [UIImage imageNamed:@"bubble"];
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    
    iv.frame = CGRectZero;
    iv.userInteractionEnabled = YES;
    [iv addSubview:text];
    
    [UIView animateWithDuration:1
                     animations:^{
                         iv.frame = CGRectMake(50, 50, 200, 100);
                     }];
    
    /*
    UIButton *capture = [UIButton buttonWithType:UIButtonTypeSystem];
    capture.frame = text.frame;
    capture.backgroundColor = [UIColor clearColor];
    capture.tag = 6;
    [capture addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    */
    
    
    
    
    
    [self.view addSubview:iv];
    //[self.view addSubview:capture];
    [self.view addSubview:preview];
    [self.view addSubview:menu];
}

- (void)capture
{
    UIView *view = [self.view viewWithTag:5];
    [((UITextField *)view) becomeFirstResponder];
    /*
    CGRect currentFrame = self.bounds;
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, [MyPopupLayer popupBorderColor]);
    CGContextSetFillColorWithColor(context, [MyPopupLayer popupBackgroundColor]);
    
    // Draw and fill the bubble
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, borderRadius + strokeWidth + 0.5f, strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f);
    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f - WIDTHOFPOPUPTRIANGLE / 2.0f) + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f);
    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f) + 0.5f, strokeWidth + 0.5f);
    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f + WIDTHOFPOPUPTRIANGLE / 2.0f) + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, round(currentFrame.size.width / 2.0f + WIDTHOFPOPUPTRIANGLE / 2.0f) - strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, strokeWidth + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, strokeWidth + 0.5f, strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, borderRadius - strokeWidth);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // Draw a clipping path for the fill
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, borderRadius + strokeWidth + 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, round(currentFrame.size.width / 2.0f + WIDTHOFPOPUPTRIANGLE / 2.0f) - strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, strokeWidth + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, borderRadius - strokeWidth);
    CGContextAddArcToPoint(context, strokeWidth + 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f, borderRadius - strokeWidth);
    CGContextClosePath(context);
    CGContextClip(context);
    */
}

- (void)setupStylesAndMore
{
 
    UITapGestureRecognizer *snapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSnapPic:)];
    snapTap.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *libraryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedSnap:)];
    libraryTap.numberOfTapsRequired = 2;
    
    [snapTap requireGestureRecognizerToFail:libraryTap];
    
    [self.snapPicButton addGestureRecognizer:libraryTap];
    [self.snapPicButton addGestureRecognizer:snapTap];
    self.snapPicButton.userInteractionEnabled = YES;
    
    
    self.snapPicButton.font = [UIFont fontWithName:kFontAwesomeFamilyName size:45];
    self.snapPicButton.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-camera"];
    self.snapPicButton.textColor =[UIColor colorWithHexString:CAPTIFY_ORANGE];
    
    if (!IS_IPHONE5){
        CGRect snapPicFrame = self.snapPicButton.frame;
        snapPicFrame.origin.y -= IPHONE4_PAD + 30;
        self.snapPicButton.frame = snapPicFrame;
    }
    
    // alert shows in viewdidappear which is to late from where this is being
    // called so delay a second then run
    if (!self.makePhoneAlert.isVisible){
        [self showTooltip];
    }
    

    
    self.topMenuButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.topMenuButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [self.topMenuButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];


    
    self.flashButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ On", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];
    [self.flashButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    
    self.rotateButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    [self.rotateButton setTitle:[NSString stringWithFormat:@"%@ %@",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-camera"],[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"]] forState:UIControlStateNormal];
    [self.rotateButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE]  forState:UIControlStateNormal];
    
    self.cameraOptionsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.cameraOptionsButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cog"] forState:UIControlStateNormal];
    [self.cameraOptionsButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    
    self.cameraOptionsContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.cameraOptionsContainerView.layer.cornerRadius = 10.0f;
    self.cameraOptionsContainerView.hidden = YES;
    


}

- (void)setupPreviewStylesAndMore
{
    
    self.previewCancelButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:45];
    [self.previewCancelButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
    [self.previewCancelButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    
    self.previewNextButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:45];
    [self.previewNextButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-right"] forState:UIControlStateNormal];
    [self.previewNextButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    
    /*
    // add pulsating effect to button
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.3];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
     */
    

    //self.previewFinalPhraseLabel.font = [UIFont fontWithName:@"Chalkduster" size:25];
    //self.previewFinalPhraseLabel.hidden = YES;
    
    //self.previewTextField.placeholder = NSLocalizedString(@"Enter title of your caption challenge!", @"Textfield placeholder text");
    self.previewTextField.borderStyle = UITextBorderStyleNone;
    self.previewTextField.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    self.previewTextField.textColor = [UIColor whiteColor];
    self.previewTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: NSLocalizedString(@"Enter a title for your caption challenge", @"Textfield placeholder text") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.previewTextField.layer.cornerRadius = 5;
    
    self.previewTextFieldIcon.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    self.previewTextFieldIcon.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-pencil-square"];
    self.previewTextFieldIcon.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.previewTextFieldIcon.layer.cornerRadius = 5;
    
    self.previewOneFieldContainer.layer.cornerRadius = 10.0f;
    self.previewOneFieldContainer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5f];
    CGRect firstRect = self.previewOneFieldContainer.frame;
    self.previewOneFieldContainer.frame = CGRectMake(firstRect.origin.x, SCREENHEIGHT , firstRect.size.width, firstRect.size.height);
    for (id textField in self.previewOneFieldContainer.subviews){
        if ([textField isKindOfClass:[UITextField class]]){
            ((UITextField *)textField).delegate = self;
        }
    }
   
    
    self.previewCountContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.previewCountContainerView.layer.cornerRadius = 5;
    
    self.previewCountLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
    self.previewCountLabel.textColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.previewCountLabel.text = [NSString stringWithFormat:@"%d",TITLE_LIMIT];
    

    
}

- (void)showAlertForPhoneNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"phone_never"]){
        if (![defaults valueForKey:@"phone_number"]){
            self.makePhoneAlert = [[UIAlertView alloc] initWithTitle:@"Enter Phone Number"
                                                               message:@"Your phone number will only be used to find all your contacts using the app. We promise it wont be shared in any way!" delegate:self
                                                     cancelButtonTitle:@"No Thanks"
                                                     otherButtonTitles:@"Get contacts!", nil];
            self.makePhoneAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [self.makePhoneAlert show];
        }
    }
}

- (void)showTooltip
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    int count = [[defaults valueForKey:@"homeToolTip"] intValue];
    if (count < 3){
        self.toolTip = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"Tap to take picture", nil)];

        self.toolTip.backgroundColor = [UIColor whiteColor];
        self.toolTip.hasGradientBackground = NO;
        self.toolTip.preferredPointDirection = PointDirectionDown;
        self.toolTip.hasShadow = NO;
        self.toolTip.has3DStyle = NO;
        self.toolTip.borderWidth = 0;
        self.toolTip.textColor = [UIColor blackColor];
        self.toolTip.textFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
        self.toolTip.titleFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
        [self.toolTip autoDismissAnimated:YES atTimeInterval:3.0];
        [self.toolTip presentPointingAtView:self.snapPicButton inView:self.mainControls animated:YES];
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showTooltip2];
        });
        
        [defaults setValue:[NSNumber numberWithInt:count + 1] forKey:@"homeToolTip"];
    }

}

- (void)showTooltip2
{
    self.toolTip = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"Tap twice to enter the photo gallery", nil)];
    self.toolTip.backgroundColor = [UIColor whiteColor];
    self.toolTip.hasGradientBackground = NO;
    self.toolTip.preferredPointDirection = PointDirectionDown;
    self.toolTip.hasShadow = NO;
    self.toolTip.has3DStyle = NO;
    self.toolTip.borderWidth = 0;
    self.toolTip.textColor = [UIColor blackColor];
    self.toolTip.textFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
    self.toolTip.titleFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
    [self.toolTip autoDismissAnimated:YES atTimeInterval:5.0];
    [self.toolTip presentPointingAtView:self.snapPicButton inView:self.mainControls animated:YES];

}



- (void)fetchContacts2
{
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static int retrys = 0;
        
        if ([ABStandin authorizationStatus] != kABAuthorizationStatusAuthorized){
            [ABStandin requestAccess];
            
            
            if (retrys < 5){
                double delayInSeconds = 10.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    retrys += 1;
                    [self fetchContacts2];
                });
            }
            
            return;
        }
        
        NSArray *contacts = [ABContactsHelper contacts];
        NSMutableArray *list = [@[] mutableCopy];
        
        for (ABContact *contact in contacts){
            DLog(@"%@ number is %@",contact.firstname,contact.phonenumbers);
            NSString *formattedPhoneNumber = contact.phonenumbers;
            NSString *phoneNumber = [[formattedPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet]] componentsJoinedByString:@""];
            DLog(@"%@ formatted number is %@",contact.firstname,phoneNumber);
            
            if (contact.phonenumbers){
                [list addObject:phoneNumber];
            }
        }
        
        
        if ([list count] > 0 && self.myUser){
            NSDictionary *params = @{@"username":self.myUser.username ,
                                     @"action":@"getCF",
                                     @"content":list};
            
            Contacts *c = [[Contacts alloc] init];
            [c requestFriendsFromContactsList:params
                                        block:^(BOOL success, id data) {
                                            if (success){
                                                for (id user in data[@"contacts"]){
                                                    NSString *facebook_id;
                                                    if (user[@"facebook_id"] == (id)[NSNull null] || user[@"facebook_id"] == nil){
                                                        facebook_id = @"0";
                                                    }
                                                    else{
                                                        facebook_id = user[@"facebook_id"];
                                                    }
                                                    
                                                    NSDictionary *params;
                                                    @try {
                                                        params = @{@"username": user[@"username"],
                                                                   @"facebook_user":user[@"is_facebook"],
                                                                   @"facebook_id":facebook_id,
                                                                   @"is_contact":[NSNumber numberWithBool:YES]};
                                                        
                                                    }
                                                    @catch (NSException *exception) {
                                                        DLog(@"%@",exception);
                                                    }
                                                    
                                                    if ([user[@"username"] isEqualToString:self.myUser.username])
                                                    {
                                                        return;
                                                    }

                                                    
                                                    User *userCreated = [User createFriendWithParams:params
                                                                               inMangedObjectContext:self.myUser.managedObjectContext];
                                                    if (userCreated){
                                                        DLog(@"successfully created %@", user[@"username"]);
                                                    }
                                                    else
                                                    {
                                                        DLog(@"failerd created %@", user[@"username"]);
                                                    }
                                                    
                                                }
                                                
                                            }
                                            else{
                                                DLog(@"no success");
                                            }
                                        }];
            
        }
        else{
            if (retrys < 10){
                retrys += 1;
                double delayInSeconds = 10.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     [self fetchContacts2];
                });
             
                
            }
        }

    });
    

}


- (void)fetchContacts
{
    
    // fetch contacts from phone and
    // from backend in the background
    static int retrys;
    double delayInSeconds = 30.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
 
        // get all phone numbers
        Contacts *c = [[Contacts alloc] init];
        [c fetchContactsWithBlock:^(BOOL done, id data) {
            if (done){
                //DLog(@"%@",data);
                if ([data isKindOfClass:[NSArray class]]){
                    self.contactNumbers = data;
                    
                    if (self.contactNumbers && self.myUser){
                        // send numbers to backend to see if any users return
                        NSDictionary *params;
                        @try {
                           params = @{@"username":self.myUser.username ,
                                      @"action":@"getCF",
                                      @"content":self.contactNumbers};
                        }
                        @catch (NSException *exception) {
                            DLog(@"%@",exception);
                        }
                        
                        [c requestFriendsFromContactsList:params
                                                    block:^(BOOL success, id data) {
                                                        if (success){
                                                            for (id user in data[@"contacts"]){
                                                                NSString *facebook_id;
                                                                if (user[@"facebook_id"] == (id)[NSNull null] || user[@"facebook_id"] == nil){
                                                                    facebook_id = @"0";
                                                                }
                                                                else{
                                                                    facebook_id = user[@"facebook_id"];
                                                                }
                                                                
                                                                NSDictionary *params;
                                                                @try {
                                                                   params = @{@"username": user[@"username"],
                                                                              @"facebook_user":user[@"is_facebook"],
                                                                              @"facebook_id":facebook_id};

                                                                }
                                                                @catch (NSException *exception) {
                                                                     DLog(@"%@",exception);
                                                                }
                                                                
                                                                User *create = [User createFriendWithParams:params
                                                                                       inMangedObjectContext:self.myUser.managedObjectContext];
                                                                if (create){
                                                                    DLog(@"successfully created %@", user[@"username"]);
                                                                }
                                                                else
                                                                {
                                                                    DLog(@"failerd created %@", user[@"username"]);
                                                                }
                                                                
                                                            }
                                                            
                                                        }
                                                        else{
                                                            DLog(@"no success");
                                                        }
                                                    }];
                    }
                    else{
                        if (retrys < 3){
                            [self fetchContacts];
                            retrys += 1;
                        }
                    }
                }
            }
        }];
        
    });
    
    
}

- (IBAction)tappedMenuButton:(UIButton *)sender
{
    [self showMenu];
}



- (void)tappedSnapPic:(UITapGestureRecognizer *)sender
{
    sender.view.userInteractionEnabled = NO;
    [self snapPhoto];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        sender.view.userInteractionEnabled = YES;
    });
    
    
    if (USE_GOOGLE_ANALYTICS){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UI_Actions"
                                                             action:@"one_tap"
                                                              label:@"picture"
                                                              value:nil] build]];
    }
}


- (IBAction)tappedFlashButton:(UIButton *)sender {
    [self toggleFlash];
}

- (IBAction)tappedCancelPreview:(UIButton *)sender {
    [self cancelPreviewImage];
}

- (IBAction)tappedCameraOptions:(UIButton *)sender {
    if (self.cameraOptionsContainerView.hidden){
        self.cameraOptionsContainerView.hidden = NO;
        
    }
    else{
        self.cameraOptionsContainerView.hidden = YES;
    }

}


- (IBAction)tappedRotateCamera:(UIButton *)sender {
    [self toggleCameraPosition];
}




- (IBAction)tappedNextPreview:(UIButton *)sender {
    
    self.previewNextButton.userInteractionEnabled = NO;
    if ([self.previewTextField.text length] == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Alert error title")
                                                            message:NSLocalizedString(@"Must enter challenge title before continuing", @"Alert error message")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        self.previewNextButton.userInteractionEnabled = YES;
            return;
    }
    
    [self pushFinalPreview];
}


- (void)doubleTappedSnap:(UITapGestureRecognizer *)sender {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        DLog(@"no photo library");
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
    if (USE_GOOGLE_ANALYTICS){
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UI_Actions"
                                                              action:@"two_tap"
                                                               label:@"picture"
                                                               value:nil] build]];
    }

    
}




- (void)pushFinalPreview
{
    self.challengeTitle = self.previewTextField.text;
    [self.previewTextField resignFirstResponder];
    [self animateTextFieldUp:0];
    SenderPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"finalPreview"];
    
    vc.image = [UIImage imageCrop:self.previewOriginalSnapshot];
    vc.name = self.challengeTitle;
    vc.delegate = self;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController pushViewController:vc animated:YES];
        self.previewNextButton.userInteractionEnabled = YES;

    });
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)source
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    imgPicker.sourceType = source;
    imgPicker.delegate = self;
    
    if (source == UIImagePickerControllerSourceTypeCamera){
        //camera so show overlay
        imgPicker.showsCameraControls = NO;
        imgPicker.allowsEditing = NO;
        imgPicker.navigationBarHidden = YES;
        imgPicker.toolbarHidden = YES;
        
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1.70, 1.70);
        imgPicker.cameraViewTransform = transform;
        //load overlay
        OverlayView *overlay = [[OverlayView alloc] init];
        overlay.delegate = self;
        [imgPicker.view addSubview:overlay];
        //UIView *button = [overlay viewWithTag:1];
        //button.layer.backgroundColor = [[UIColor colorWithHexString:@"#e74c3c"] CGColor];
        imgPicker.cameraOverlayView = overlay;
        [self presentViewController:imgPicker animated:NO completion:nil];
        
    }
}

- (void)snapPhoto
{
    AVCaptureConnection *vc = [self.snapper connectionWithMediaType:AVMediaTypeVideo];
    [self.snapper captureStillImageAsynchronouslyFromConnection:vc
                                              completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                  NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                   self.previewOriginalSnapshot = [UIImage imageWithData:data];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      
                                                      [self setupImagePreviewScreen];
                                                      
                                                      
                                                      //[self.previewLayer removeFromSuperlayer];
                                                      //self.previewLayer = nil;
                                                      //[self.session stopRunning];
                                                  });
                                              }];
}

- (void)toggleCameraControls
{
    if (!self.snapPicButton.hidden && !self.topMenuButton.hidden && !self.cameraOptionsButton.hidden){
        self.snapPicButton.hidden = YES;
        self.topMenuButton.hidden = YES;
        self.cameraOptionsButton.hidden = YES;
    }
    else{
        self.snapPicButton.hidden = NO;
        self.topMenuButton.hidden = NO;
        self.cameraOptionsButton.hidden = NO;

    }
}


- (void)setupImagePreviewScreen
{
    [self toggleCameraControls];
    self.previewSnap = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.previewSnap.contentMode = UIViewContentModeScaleAspectFit;
    self.previewSnap.image = self.previewOriginalSnapshot;

    [self.view addSubview:self.previewBackground];
    [self.view addSubview:self.previewSnap];
    [self.view addSubview:self.previewControls];
    
    [self setupPreviewStylesAndMore];
    [self performSelector:@selector(animateTextFieldUp:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0f];
    
    self.showingPreview = YES;

    
    

}

- (void)cancelPreviewImage
{
    [self viewWillAppear:YES];
    
    [self toggleCameraControls];
    
    [self.previewControls removeFromSuperview];
    [self.previewSnap removeFromSuperview];
    [self.previewBackground removeFromSuperview];
    
    self.previewControls = nil;
    self.previewSnap = nil;
    self.previewOriginalSnapshot = nil;
    self.previewBackground = nil;
    self.previewNextButton = nil;
    self.previewCancelButton = nil;
    self.previewTextField = nil;
    self.previewOneFieldContainer = nil;
    
    self.showingPreview = NO;
    
}


- (void)animateTextFieldUp:(NSNumber *)up
{
    if (up){
        CGRect oneFrame = self.previewOneFieldContainer.frame;
        [UIView animateWithDuration:1.0f
                              delay:0
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                                              SCREENHEIGHT - 290,
                                                                              oneFrame.size.width,
                                                                              oneFrame.size.height);

                         } completion:^(BOOL finished) {
                             [self.previewTextField becomeFirstResponder];
                         }];
    }
    else{
        CGRect oneFrame = self.previewOneFieldContainer.frame;
        [UIView animateWithDuration:1.0f
                              delay:0
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                                              SCREENHEIGHT ,
                                                                              oneFrame.size.width,
                                                                              oneFrame.size.height);
                             
                         } completion:nil];

    }
    

}


- (void)toggleFlash
{
 
        if ([self.cameraDevice isFlashModeSupported:AVCaptureFlashModeOn]){
            NSError *error;
            if (self.cameraDevice.flashActive){
                // turn off
                 [self.cameraDevice lockForConfiguration:&error];
                 [self.cameraDevice setFlashMode:AVCaptureFlashModeOff];
                 [self.cameraDevice unlockForConfiguration];
                [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Off", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];


            }
            else{
                // turn on
                [self.cameraDevice lockForConfiguration:&error];
                [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
                [self.cameraDevice unlockForConfiguration];
                [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ On", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];

            
            }
        }
        else{
            [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Flash isn't supported on the front camera", nil)];
            [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Off", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];
            return;
        }
            
    
}


- (void)toggleCameraPosition
{
    
        [self.session beginConfiguration];
        NSError *error;
        [self.session removeInput:self.cameraInput];
        if ([self.cameraDevice position] == AVCaptureDevicePositionBack){
            // show front camera
            self.cameraDevice = [self frontCamera];
            self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
            if (self.cameraInput){
                [self.session addInput:self.cameraInput];
                [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Off", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];

            }
            

        }
        else{
            // show back camera
            self.cameraDevice = [self backCamera];
            self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
            if (self.cameraInput){
                [self.session addInput:self.cameraInput];
            }

        }
        
        [self.session commitConfiguration];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}


- (AVCaptureDevice *)backCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

- (void)focusAPoint:(CGPoint)point
{
    if ([self.cameraDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus] && [self.cameraDevice isFocusPointOfInterestSupported]){
        NSError *error;
        
        if ([self.cameraDevice lockForConfiguration:&error]){
    
            if (!CGRectContainsPoint(self.snapPicButton.frame, point)){
                if (!CGRectContainsPoint(self.topMenuButton.frame, point)){
                    if (!self.showingPreview){
                        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, 70, 70)];
                        circle.layer.cornerRadius = 35;
                        circle.backgroundColor = [UIColor clearColor];
                        circle.layer.borderColor = [[UIColor whiteColor] CGColor];
                        circle.layer.borderWidth = 2.f;
                        circle.alpha = 0.7;
                        [self.view addSubview:circle];
                        
                        [UIView animateKeyframesWithDuration:1
                                                       delay:.5
                                                     options:0
                                                  animations:^{
                                                     circle.alpha = 0;
                                                      CGRect closeFrame = CGRectMake(point.x, point.y, 20, 20);
                                                      circle.layer.cornerRadius = 10;
                                                      circle.frame = closeFrame;
                                                     
                                                      
                                                  } completion:^(BOOL finished) {
                                                      [circle removeFromSuperview];
                                                  }];
                    }
                }
            }
            
            [self.cameraDevice setFocusPointOfInterest:point];
            
            [self.cameraDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            
            [self.cameraDevice unlockForConfiguration];
        }
    }
}

/*
- (void)showFinalTextLabel
{
    // move text field off screen
    [UIView animateWithDuration:1.0f
                     animations:^{
                        CGRect oneFrame = self.previewOneFieldContainer.frame;
                         self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                                          SCREENHEIGHT ,
                                                                          oneFrame.size.width,
                                                                          oneFrame.size.height);
                         

                     } completion:^(BOOL finished) {
                         //show label text ontop of image
                         self.previewFinalPhraseLabel.text = self.finalPhrase;
                         self.previewFinalPhraseLabel.userInteractionEnabled = YES;
                         if ([self.finalPhrase length] > 15){
                             self.previewFinalPhraseLabel.numberOfLines = 0;
                             [self.previewFinalPhraseLabel sizeToFit];
                         }
                         self.previewFinalPhraseLabel.textAlignment = NSTextAlignmentCenter;
                         
                         self.previewFinalPhraseLabel.alpha = 0;
                         self.previewFinalPhraseLabel.hidden = NO;
                         [UIView animateWithDuration:1.0
                                          animations:^{
                                              self.previewFinalPhraseLabel.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              // add pulsating effect to next button arrow
                                              if  (![self.previewNextButton.layer animationForKey:@"previewNextButton"]){
                                                  
                                              
                                                  CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                                                  pulseAnimation.duration = .5;
                                                  pulseAnimation.toValue = [NSNumber numberWithFloat:1.3];
                                                  pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                  pulseAnimation.autoreverses = YES;
                                                  pulseAnimation.repeatCount = FLT_MAX;
                                                  [self.previewNextButton.layer addAnimation:pulseAnimation forKey:@"previewNextButton"];
                                              }

                                          }];

                     }];

}
 */


- (void)showMenu
{
   
      [self.sideMenuViewController openMenuAnimated:YES completion:nil];
    
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.cameraOptionsContainerView.hidden)
    {
        self.cameraOptionsContainerView.hidden = YES;
    }
    
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    // focus camera where user touces
    if (self.session.running){
        [self focusAPoint:touchLocation];
    }
}

#pragma -mark Overlay delegate

- (void)showMenuButtonClicked
{
    [self showMenu];
}

#pragma -mark Menu delegate

- (void)menuShowingAnotherScreen
{
    // use this to dispose of resources instead of
    // view did/will disappear so we dont mess up
    // preview screen
    
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
    [self.session stopRunning];
    self.session = nil;
    
    self.cameraDevice = nil;
    self.cameraInput = nil;
    self.snapper = nil;
    self.previewSnap = nil;
    self.previewControls = nil;
    self.snapPicButton = nil;
    self.topMenuButton = nil;
    self.flashButton = nil;
    self.previewCancelButton = nil;
    self.previewNextButton = nil;
    self.cameraOptionsButton = nil;
    self.cameraOptionsContainerView = nil;
    self.previewOneFieldContainer = nil;
    self.challengeTitle = nil;
    self.previewEditedSnapshot = nil;
    self.previewOriginalSnapshot = nil;
    
    
    
    
    
    if (self.navigationController.delegate == self){
        self.navigationController.delegate = nil;
    }
    
    MenuViewController *menu = (MenuViewController *) self.sideMenuViewController.menuViewController;
    if (menu.delegate == self){
        menu.delegate = nil;
    }
    

}


#pragma -mark SemderPreview delegate

- (void)previewscreenDidMoveBack
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)previewscreenFinished
{
    
    self.navigationController.navigationBarHidden = YES;
    [self cancelPreviewImage];
    self.showHistory = YES;
}

#pragma -mark Uialertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        
    if (alertView == self.makePhoneAlert){
        if (buttonIndex == 0){
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"phone_never"];
            [self showTooltip];
            return;
        }
        if (buttonIndex == 1){
            [self showTooltip];
            NSString *number = [alertView textFieldAtIndex:0].text;
            if ([number length] > 0){
                // save number
                [[NSUserDefaults standardUserDefaults] setValue:number forKey:@"phone_number"];
                [SocialFriends sendPhoneNumber:number
                                       forUser:[[NSUserDefaults standardUserDefaults]valueForKey:@"username"]
                                         block:^(BOOL wasSuccessful) {
                                             if (wasSuccessful){
                                                 DLog(@"success sending phone from home");
                                             }
                                         }];
              
                
            }
        }
    }
}


- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (alertView == self.makePhoneAlert){
        [alertView textFieldAtIndex:0].delegate = self;
        self.makePhoneTextField = [alertView textFieldAtIndex:0];
    }
}


#pragma -mark UItextfield delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.makePhoneTextField){
        
        NSUInteger length = [SocialFriends getLength:textField.text];
        if (length == 10){
            if (range.length == 0){
                return NO;
            }
        }
        
        if (length == 3){
            NSString *num = [SocialFriends formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@)",num];
            if (range.length > 0){
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
            }
        }
        else if (length == 6){
            NSString *num = [SocialFriends formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num substringToIndex:3],[num substringFromIndex:3]];
            if (range.length > 0){
                textField.text =  [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
            }
            return  YES;
        }
        
      
    }
    
    if ([textField.text length] <=1){
        [self.previewNextButton.layer removeAnimationForKey:@"previewNextButton"];
    }
    else{
        if  (![self.previewNextButton.layer animationForKey:@"previewNextButton"]){
            
            
            CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            pulseAnimation.duration = .5;
            pulseAnimation.toValue = [NSNumber numberWithFloat:1.3];
            pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            pulseAnimation.autoreverses = YES;
            pulseAnimation.repeatCount = CGFLOAT_MAX;
            [self.previewNextButton.layer addAnimation:pulseAnimation forKey:@"previewNextButton"];
        }
        
        
    }
    
    NSInteger stringCount = 0;
    
    if (![string isEqualToString:@""]){
        stringCount = [textField.text length] + 1;
    }
    else{
        stringCount = [textField.text length] - 1;
    }
    
    if (stringCount > 0){
        self.previewCountLabel.text = [NSString stringWithFormat:@"%d",TITLE_LIMIT - stringCount];
    }
    else{
        self.previewCountLabel.text = [NSString stringWithFormat:@"%d",TITLE_LIMIT];
    }



    if ([string isEqualToString:@""]){
        return YES;
    }
    
    if ([textField.text length] + 1< TITLE_LIMIT){
        return YES;
    }
    else{
        return NO;
    }
    


}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    self.previewNextButton.userInteractionEnabled = NO;
    if ([self.previewTextField.text length] == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Alert error title")
                                                        message:NSLocalizedString(@"Must enter challenge title before continuing", @"Alert error message")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        self.previewNextButton.userInteractionEnabled = YES;
        return NO;
    }

    [textField resignFirstResponder];
    self.challengeTitle = textField.text;
    [self pushFinalPreview];
    
    //[self showFinalTextLabel];
    
    //[self proceedToFinalPreview];
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
      textField.returnKeyType = UIReturnKeyNext;
}


#pragma -mark twtsidemenu delegate
- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    UIViewController *menu =  self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) setupColors];
    }
}

#pragma -mark UIImagepickercontroller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage]){
        self.previewOriginalSnapshot = [UIImage imageCrop:info[UIImagePickerControllerOriginalImage]];
        [self setupImagePreviewScreen];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark UINavigationController delegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[HomeViewController class]]){
        if ([fromVC isKindOfClass:[SenderPreviewViewController class]]){
            self.previewNextButton.hidden = NO;
            self.previewCancelButton.hidden = NO;
            self.challengeTitle = nil;
            CGRect oneFrame = self.previewOneFieldContainer.frame;
            self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                             SCREENHEIGHT - 290,
                                                             oneFrame.size.width,
                                                             oneFrame.size.height);

            return nil;
        }
        
        self.navigationController.navigationBarHidden = YES;
        if ([fromVC isKindOfClass:[ChallengeViewController class]]){
            UIView *remove = [self.navigationController.navigationBar viewWithTag:SENDERPICANDNAME_TAG];
            if (remove){
                [remove removeFromSuperview];
            }
            
        }
        return [GoHomeTransition new];
    }

    
    return nil;
}


- (AVCaptureVideoPreviewLayer *)previewLayer
{

    if (!_previewLayer){
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.view.frame;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (AVCaptureStillImageOutput *)snapper
{
    if (!_snapper){
        _snapper = [AVCaptureStillImageOutput new];
        _snapper.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG,
                                    AVVideoQualityKey:@0.6};

    }
    return _snapper;
}

- (AVCaptureDeviceInput *)cameraInput
{
    NSError *error;
    if (!_cameraInput){
        _cameraInput =  [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
    }
    
    
    return _cameraInput;
}
- (AVCaptureDevice *)cameraDevice
{
    if (!_cameraDevice){
        _cameraDevice = [self backCamera];
    }
    return _cameraDevice;
}

- (AVCaptureSession *)session
{
    if (!_session){

        _session = [AVCaptureSession new];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return  _session;
}

- (UIView *)mainControls
{
    if (!_mainControls){
        _mainControls = [[[NSBundle mainBundle] loadNibNamed:@"cameraControls" owner:self options:nil]lastObject];
    }
    return  _mainControls;
}

- (UIView *)previewControls
{
    if (!_previewControls){
        _previewControls = [[[NSBundle mainBundle] loadNibNamed:@"previewControls" owner:self options:nil]lastObject];

    }
    
    return _previewControls;
}

- (UIView *)previewBackground
{
    if (!_previewBackground){
        _previewBackground = [[UIView alloc] initWithFrame:self.view.frame];
        _previewBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    return _previewBackground;
}


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
