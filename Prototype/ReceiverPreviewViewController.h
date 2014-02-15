//
//  ReceiverPreviewViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiverPreviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *previewPhrase;
@property (weak, nonatomic) IBOutlet UILabel *previewChallengeName;


@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *phrase;
@property (strong, nonatomic) NSString *challengeName;


@end
