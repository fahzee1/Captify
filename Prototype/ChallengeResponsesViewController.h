//
//  ChallengeResponsesViewController.h
//  Captify
//
//  Created by CJ Ogbuehi on 5/15/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Challenge+Utils.h"
#import "MZFormSheetController.h"

@interface ChallengeResponsesViewController : UIViewController

@property (nonatomic, retain)Challenge *myChallenge;
@property (strong,nonatomic) MZFormSheetController *controller;

@property (nonatomic, strong) NSString *myFriend;
@end
