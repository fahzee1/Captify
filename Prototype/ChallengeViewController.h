//
//  ChallengeViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ChallengeViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, retain)User *myUser; //get managedobjectcontext from myuser
@property (strong, nonatomic)NSString *answer;
@property (strong, nonatomic)NSString *hint;
@property NSInteger level;

@end
