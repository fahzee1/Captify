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
#import "AwesomeAPICLient.h"
#import "CJPopup.h"
#import "ReceiverPreviewViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIColor+HexValue.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "FAImageView.h"

#define TEST 1

@interface ChallengeViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic)CJPopup *successPop;
@property (strong, nonatomic)CJPopup *failPop;


@property (weak, nonatomic) IBOutlet UIView *captionContainerView;
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
    self.captionField.returnKeyType = UIReturnKeyDone;
    [self setupStylesAndMore];
    
    // so the scroll view positions right
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    
    [self setupTopLabel];
    
    
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
          [self.captionField becomeFirstResponder];
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
    
    self.challengeNameLabel.text = self.name;
    self.challengeNameLabel.textAlignment = NSTextAlignmentCenter;
    self.challengeNameLabel.numberOfLines = 0;
    [self.challengeNameLabel sizeToFit];
    
    CGRect frame = self.challengeNameLabel.frame;
    self.challengeNameLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, 300, 40);
    
    
    

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

#pragma -mark UIscrollview delegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.captionField resignFirstResponder];
}





@end
