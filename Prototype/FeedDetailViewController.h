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

#ifdef USE_GOOGLE_ANALYTICS
#import "GAITrackedViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#endif

#ifdef USE_GOOGLE_ANALYTICS
@interface FeedDetailViewController : GAITrackedViewController
#else

@interface FeedDetailViewController : UIViewController
#endif


@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSURL *facebookPicURL;
@property (strong, nonatomic) NSString *profileUsername;
@property (strong, nonatomic) NSString *winnerUsername;
@property (strong, nonatomic) NSNumber *facebookUser;
@property (strong, nonatomic) NSString *profileScore;
@property (strong, nonatomic)UIView *topLabel;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic)UIButton *winnerLabelButton;
@property (strong, nonatomic)UILabel *winnerLabel;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic)User *myUser;
@property BOOL showTopLabel;
@property float delaySetupWithTime;

@end
