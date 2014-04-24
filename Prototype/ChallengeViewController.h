//
//  ChallengeViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//
// Controller that encapsulates all game logic and displays
// custom keyboard, buttons, and pic/video 

#import <UIKit/UIKit.h>
#import "User.h"
#import "Challenge.h"
#import "HomeViewController.h"

#ifdef USE_GOOGLE_ANALYTICS
    #import "GAITrackedViewController.h"
#endif


#ifdef USE_GOOGLE_ANALYTICS
    @interface ChallengeViewController : GAITrackedViewController
#else
    @interface ChallengeViewController : UIViewController
#endif

@property (nonatomic, retain)User *myUser; //get managedobjectcontext from myuser
@property (strong, nonatomic)NSString *myFriend; //temp for testing
@property (nonatomic, retain)Challenge *myChallenge;
@property (strong, nonatomic)NSString *answer;
@property (strong, nonatomic)NSString *name;
@property (nonatomic, retain)NSString *sender;
@property (weak, nonatomic) IBOutlet UIImageView *challengeImage;
@property (weak, nonatomic) IBOutlet UILabel *challengeNameLabel;
@property (strong, nonatomic)UIView *topLabel;
@property (strong, nonatomic)UIImage *image;
@property (strong, nonatomic)NSURL *mediaURL;
- (void)setupTopLabel;
@end
