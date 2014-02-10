//
//  RecentActivityViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//
// Container Controller that will display other controllers such
// as sent challenges and recieved challenges

#import <UIKit/UIKit.h>
#import "User.h"
#import "MyChallengesViewController.h"
#import "FriendsChallengeViewController.h"

@interface RecentActivityViewController : UIViewController

@property (nonatomic, retain)User *myUser;
@property (nonatomic, retain)UIViewController *currentController;
@property UIViewController *friendsChallengeController;
@property UIViewController *myChallengeController;


- (instancetype)initWithMyViewController:(UIViewController *)myVC
                    andFriendsController:(UIViewController *)friendVC;
@end
