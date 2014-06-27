//
//  FeedDetailViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 5/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexValue.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "UserProfileViewController.h"
#import "ParseNotifications.h"

#define NOTIFICATION_CREATE_TAG 112
#define NOTIFICATION_ERROR_TAG 111
#define NOTIFICATION_LIKE_BUTTON_TAG 110
#define NOTFICATION_TEXT_LIMIT 10

@interface FeedDetailViewController ()<UITextFieldDelegate,UIAlertViewDelegate>

@end

@implementation FeedDetailViewController

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
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popScreen)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;

    
    if (self.image){
        self.myImageView.image = self.image;
    }
    else{
        [self.myImageView sd_setImageWithURL:[NSURL URLWithString:self.urlString]
                            placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if (!image){
                                           DLog(@"%@",error);
                                       }

                                   }];
    }
    
    self.view.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];

    [self.likeButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    [self.likeButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateHighlighted];
    [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"] forState:UIControlStateNormal];
    self.likeButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    
    //CGRect likeFrame = self.likeButton.frame;
    //likeFrame.origin.y += 150;
    self.likeButton.frame = CGRectMake(self.myImageView.frame.size.width/2, self.view.frame.size.height - 40, self.likeButton.frame.size.width, self.likeButton.frame.size.height);
    
    
    if (!IS_IPHONE5){
        CGRect imageFrame = self.myImageView.frame;
        imageFrame.origin.y += 10;
        self.myImageView.frame = imageFrame;
    }
    
    
 

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.showTopLabel){
        [self setupTopAndBottomLabel];
        [self animateTopLabels];
        self.navigationController.navigationBarHidden = YES;

    }
    else{
        self.navigationItem.title = NSLocalizedString(@"Photo", nil);
        self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
        self.navigationController.navigationBarHidden = NO;
        self.likeButton.hidden = YES;
    }

   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:1
                     animations:^{
                          self.view.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
                     }];
  

    
    DLog(@"%@ selected this caption", self.winnerUsername);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)animateTopLabels
{
    self.topLabel.hidden = YES;
    self.topLabel.alpha = 0;
    CGRect topFrame = self.topLabel.frame;
    int cusion = 20;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(topFrame.origin.x +cusion, topFrame.origin.y +15, topFrame.size.width, topFrame.size.height)];
    nameLabel.text = [self.name capitalizedString];
    nameLabel.numberOfLines = 0;
    [nameLabel sizeToFit];
    nameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
    nameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nameLabel];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1
                         animations:^{
                             nameLabel.alpha = 0;
                             nameLabel.hidden = YES;
                             [nameLabel removeFromSuperview];
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:1
                                              animations:^{
                                                  self.topLabel.hidden = NO;
                                                  self.topLabel.alpha = 1;
                                              } completion:nil];
                         }];
    });
    
    
    
}


- (void)setupTopAndBottomLabel
{
    if (!self.topLabel){
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        view.backgroundColor = [UIColor clearColor];
        CGRect navFrameBase = CGRectMake(50, 4, 40, 40);
        
        UIImageView *image = [[UIImageView alloc] init];
        
        
        if ([self.facebookUser intValue] == 1){
            [image sd_setImageWithURL:self.facebookPicURL
                     placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]];
                
        }
        
        else{
            image.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
            
            
        }
        
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 20.0f;
        image.frame = navFrameBase;
        
        UIButton *friendName = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect buttonFrame = CGRectMake(navFrameBase.origin.x + image.frame.size.width + 10, navFrameBase.origin.y, navFrameBase.size.width+200, navFrameBase.size.height);
        friendName.frame = buttonFrame;
        [friendName setTitle:[[self.profileUsername stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString] forState:UIControlStateNormal];
        [friendName setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
        [friendName setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateHighlighted];
        friendName.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:16];
        friendName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [friendName addTarget:self action:@selector(tappedUsernameLabel) forControlEvents:UIControlEventTouchUpInside];
        
        
        if ([friendName.titleLabel.text length] >= 16){
            NSString *newString = [friendName.titleLabel.text substringToIndex:15];
            friendName.titleLabel.text = [NSString stringWithFormat:@"%@...",newString];
        }
        
        
        [view addSubview:image];
        [view addSubview:friendName];
        view.userInteractionEnabled = YES;
        view.tag = SENDERPICANDNAME_TAG;
        self.topLabel = view;
    }
    
    if (self.winnerUsername){
        CGRect imageRect = self.myImageView.frame;
        if (!self.winnerLabel){
            self.winnerLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageRect.origin.x + 10, imageRect.size.height + 50, 100, 40)];
            self.winnerLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:13];
            self.winnerLabel.textColor = [UIColor whiteColor];
            self.winnerLabel.text = NSLocalizedString(@"Captified by:", nil);
        }
        
        if (!self.winnerLabelButton){
            CGRect labelFrame = self.winnerLabel.frame;
            self.winnerLabelButton = [UIButton buttonWithType:UIButtonTypeSystem];
            self.winnerLabelButton.frame = CGRectMake(labelFrame.size.width - 5, labelFrame.origin.y, imageRect.size.width, 40);
            self.winnerLabelButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:16];
            [self.winnerLabelButton setTitle:[[self.winnerUsername stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString] forState:UIControlStateNormal];
            //[self.winnerLabelButton setTitle:@"Mary Lou Rettin" forState:UIControlStateNormal];
            [self.winnerLabelButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
            self.winnerLabelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [self.winnerLabelButton addTarget:self action:@selector(tappedWinnerLabel) forControlEvents:UIControlEventTouchUpInside];
            

            
        }
        

        
        [self.view addSubview:self.winnerLabel];
        [self.view addSubview:self.winnerLabelButton];
    }
    [self.view addSubview:self.topLabel];

    
    
}

- (void)removeTopLabel
{
    self.topLabel.hidden = YES;
    self.winnerLabelButton.hidden = YES;
}


- (void)tappedUsernameLabel
{
    // show user profile
    
    [User showProfileOnVC:self
             withUsername:self.profileUsername
               usingMZHud:NO
          fromExplorePage:YES
          showCloseButton:NO
        delaySetupWithTme:0.8];
    
}

- (void)tappedWinnerLabel
{
    // show user profile
    
    [User showProfileOnVC:self
             withUsername:self.winnerUsername
               usingMZHud:NO
          fromExplorePage:YES
          showCloseButton:NO
        delaySetupWithTme:0.8];
    
}


- (void)savePicToLiked
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *myLiked = [[defaults valueForKey:@"likedPics"] mutableCopy];
    if ([myLiked count] > 0){
        [myLiked addObject:self.urlString];
        [defaults setObject:[[NSSet setWithArray:myLiked] allObjects] forKey:@"likedPics"];
        
    }
    else{
        [defaults setObject:@[self.urlString] forKey:@"likedPics"];
    }
}


- (IBAction)tappedLikeButton:(UIButton *)sender
{
    /*
    [self showAlertWithTitle:NSLocalizedString(@"Show Love", nil)
                     message:NSLocalizedString(@"I think this photo is.. (one word)",nil)
             forNotification:YES];
    sender.tag = NOTIFICATION_LIKE_BUTTON_TAG;
     */
    
    [self sendNotificationWithMessage:nil andButton:sender];
    
    
}

- (void)sendNotificationWithMessage:(NSString *)message
                          andButton:(UIButton *)button
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *allLikes = [defaults objectForKey:@"allLikes"];
    
    if (![allLikes containsObject:self.urlString]){
        
        /*
        
        ParseNotifications *p = [ParseNotifications new];
        
        // notify chosen captions sender
        [p sendNotification:message
                   toFriend:self.profileUsername
                   withData:nil
           notificationType:ParseNotificationNotifySelectedCaptionSender
                      block:^(BOOL wasSuccessful) {
                          if (wasSuccessful){
                              button.hidden = YES;
                              [self showAlertWithTitle:NSLocalizedString(@"Success", nil)
                                               message:NSLocalizedString(@"Notification sent", nil)
                                       forNotification:NO];
                          }
                      }];
         */
        
        [self savePicToLiked];
        
        [self showAlertWithTitle:NSLocalizedString(@"Success", nil)
                         message:NSLocalizedString(@"Saved to liked photos", nil)
                 forNotification:NO];
        button.hidden = YES;
        
    }
    else{
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil)
                         message:NSLocalizedString(@"Already liked photo", nil)
                 forNotification:NO];
    }
    
    
    if (!allLikes){
        allLikes = [NSMutableArray array];
        [allLikes addObject:self.urlString];
    }
    else if ([allLikes count] > 10){
        [allLikes removeLastObject];
        
    }
    
    [defaults setObject:allLikes forKey:@"allLikes"];

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
           forNotification:(BOOL)notif

{
    UIAlertView *a;
    if (!notif){
        a = [[UIAlertView alloc]
             initWithTitle:title
             message:message
             delegate:nil
             cancelButtonTitle:NSLocalizedString(@"Ok", nil)
             otherButtonTitles:nil];
        a.tag = NOTIFICATION_ERROR_TAG;

    }
    else{
        
        a = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:self
                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                             otherButtonTitles:NSLocalizedString(@"Send", nil), nil];
        a.alertViewStyle = UIAlertViewStylePlainTextInput;
        a.tag = NOTIFICATION_CREATE_TAG;
        UITextField *alertTextField = [a textFieldAtIndex:0];
        alertTextField.delegate = self;
        [alertTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
        alertTextField.placeholder = NSLocalizedString(@"Enter 10 letters max", nil);
        
    }

    [a show];
}


#pragma -mark uitextfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@" "]){
        return  NO;
    }
    
    if ([textField.text length] >= 10){
        if ([string isEqualToString:@""]){
            return YES;
        }

        return NO;
    }
    
    if ([string isEqualToString:@""]){
        return YES;
    }

    
    
    return YES;
    
}


#pragma -mark uialertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NOTIFICATION_CREATE_TAG){
        if (alertView.delegate == self){
            alertView.delegate = nil;
        }
        
        if (buttonIndex == 1){
            UIView *buttonView = [self.view viewWithTag:NOTIFICATION_LIKE_BUTTON_TAG];
            if ([buttonView isKindOfClass:[UIButton class]]){
                UIButton *button = (UIButton *)buttonView;
                UITextField *alertTextField = [alertView textFieldAtIndex:0];
                if (alertTextField.delegate == self){
                    alertTextField.delegate = nil;
                }
                NSString *message = [NSString stringWithFormat:@"%@ thinks your photo is \"%@\"",[self.myUser displayName],alertTextField.text];
                
                [self sendNotificationWithMessage:message andButton:button];
                [self savePicToLiked];

            }
        }
        
    }
}










@end
