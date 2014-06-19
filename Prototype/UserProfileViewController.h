//
//  UserProfileViewController.h
//  Captify
//
//  Created by CJ Ogbuehi on 5/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *myProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *myUsername;
@property (weak, nonatomic) IBOutlet UILabel *myScore;

@property (strong, nonatomic) NSString *usernameString;
@property (strong, nonatomic) NSString *realUsernameString;
@property (strong, nonatomic) NSString *scoreString;
@property (strong, nonatomic) NSURL *profileURLString;
@property (strong, nonatomic) NSNumber *facebook_user;

@property float delaySetupWithTime;
@property BOOL fromExplorePage;

@end
