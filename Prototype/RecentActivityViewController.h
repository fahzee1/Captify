//
//  RecentActivityViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//
// Controller that will display other controllers such
// as sent challenges and recieved challenges

#import <UIKit/UIKit.h>
#import "User.h"
#import "MyChallengesViewController.h"
#import "FriendsChallengeViewController.h"

@interface RecentActivityViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain)User *myUser;
@property (nonatomic, retain)UIViewController *currentController;

@end
