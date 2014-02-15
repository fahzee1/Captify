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

@interface ChallengeViewController : UIViewController 

@property (nonatomic, retain)User *myUser; //get managedobjectcontext from myuser
@property (nonatomic, retain)User *myFriend; 
@property (nonatomic, retain)Challenge *myChallenge;
@property (strong, nonatomic)NSString *answer;
@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSString *challengeId;
@property (nonatomic, assign) NSInteger numberOfFields;
@property (weak, nonatomic) IBOutlet UIImageView *challengeImage;
@property (weak, nonatomic) IBOutlet UILabel *challengeNameLabel;

@end
