//
//  ShareViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/4/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge+Utils.h"
#import "ChallengePicks+Utils.h"

@interface ShareViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;
@property (strong, nonatomic)UIImage *shareImage;
@property (strong, nonatomic)NSString *selectedUsername;
@property (strong, nonatomic)NSString *selectedCaption;


@property (nonatomic, retain)Challenge *myChallenge;
@property (nonatomic, retain)ChallengePicks *myPick;

@end
