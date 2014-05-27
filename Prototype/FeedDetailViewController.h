//
//  FeedDetailViewController.h
//  Captify
//
//  Created by CJ Ogbuehi on 5/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSURL *facebookPicURL;
@property (strong, nonatomic) NSString *profileUsername;
@property (strong, nonatomic) NSNumber *facebookUser;

@property (strong, nonatomic)UIView *topLabel;
@end
