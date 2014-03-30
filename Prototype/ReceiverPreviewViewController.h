//
//  ReceiverPreviewViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Challenge+Utils.h"
#import "User+Utils.h"

@interface ReceiverPreviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *previewCaption;
@property (weak, nonatomic) IBOutlet UILabel *previewChallengeName;


@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *challengeName;

@property (nonatomic, retain)Challenge *myChallenge;
@property (nonatomic, retain)User *myUser;


@end
