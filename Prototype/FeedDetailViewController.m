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

@interface FeedDetailViewController ()

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
    
    
    [self.myImageView setImageWithURL:[NSURL URLWithString:self.urlString]
                     placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                if (!image){
                                    DLog(@"%@",error);
                                }
                            }];
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];

    [self.likeButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
    [self.likeButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateHighlighted];
    [self.likeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"] forState:UIControlStateNormal];
    self.likeButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
    
    //CGRect likeFrame = self.likeButton.frame;
    //likeFrame.origin.y += 150;
    self.likeButton.frame = CGRectMake(self.myImageView.frame.size.width/2, self.view.frame.size.height - 50, self.likeButton.frame.size.width, self.likeButton.frame.size.height);
    
    
    [self setupTopLabel];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupTopLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupTopLabel
{
    if (!self.topLabel){
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        view.backgroundColor = [UIColor clearColor];
        CGRect navFrameBase = CGRectMake(50, 4, 40, 40);
        
        UIImageView *image = [[UIImageView alloc] init];
        
        
        if ([self.facebookUser intValue] == 1){
            [image setImageWithURL:self.facebookPicURL
                  placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
            
        }
        
        else{
            image.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
            
            
        }
        
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 20.0f;
        image.frame = navFrameBase;
        
        UIButton *friendName = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect buttonFrame = CGRectMake(navFrameBase.origin.x - 5, navFrameBase.origin.y, navFrameBase.size.width+200, navFrameBase.size.height);
        friendName.frame = buttonFrame;
        [friendName setTitle:[[self.profileUsername stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString] forState:UIControlStateNormal];
        [friendName setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [friendName setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateHighlighted];
        friendName.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:16];
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
    [self.navigationController.navigationBar addSubview:self.topLabel];

    
    
}


- (void)tappedUsernameLabel
{
    // show user profile
    
    UIViewController *profile = [self.storyboard instantiateViewControllerWithIdentifier:@"profileScreen"];
    if ([profile isKindOfClass:[UserProfileViewController class]]){
        ((UserProfileViewController *)profile).scoreString = self.profileScore;
        ((UserProfileViewController *)profile).usernameString = self.profileUsername;
        ((UserProfileViewController *)profile).profileURLString = self.facebookPicURL;
        ((UserProfileViewController *)profile).facebook_user = self.facebookUser;
        
        [self.topLabel removeFromSuperview];
        
        [self.navigationController pushViewController:profile animated:YES];
        
        
    }
}


- (IBAction)tappedLikeButton:(UIButton *)sender
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *allLikes = [defaults objectForKey:@"allLikes"];
    
    if (![allLikes containsObject:self.urlString]){
        
        NSString *alert;
        if (![self.myUser.username isEqualToString:self.profileUsername]){
            alert = @"You liked your Captify pic!";
        }
        else{
            alert = [NSString stringWithFormat:@"%@ likes your Captify pic!", [self.myUser displayName]];
        }
        
        ParseNotifications *p = [ParseNotifications new];
        
        // notify chosen captions sender
        [p sendNotification:alert
                   toFriend:self.profileUsername
                   withData:nil
           notificationType:ParseNotificationNotifySelectedCaptionSender
                      block:^(BOOL wasSuccessful) {
                          if (wasSuccessful){
                              sender.hidden = YES;
                              [self showAlertWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Notification sent", nil)];
                          }
                      }];

        
        
    }
    else{
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Already sent notification", nil)];
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
