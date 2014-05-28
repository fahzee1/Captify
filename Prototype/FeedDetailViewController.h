//
//  FeedDetailViewController.h
//  Captify
//
//  Created by CJ Ogbuehi on 5/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "AppDelegate.h"

@interface FeedDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSURL *facebookPicURL;
@property (strong, nonatomic) NSString *profileUsername;
@property (strong, nonatomic) NSNumber *facebookUser;
@property (strong, nonatomic) NSString *profileScore;
@property (strong, nonatomic)UIView *topLabel;

@property (strong, nonatomic)User *myUser;
@end
