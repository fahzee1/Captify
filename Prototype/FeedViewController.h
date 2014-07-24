//
//  FeedViewController.h
//  Captify
//
//  Created by CJ Ogbuehi on 5/8/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef USE_GOOGLE_ANALYTICS
#import "GAITrackedViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#endif

#ifdef USE_GOOGLE_ANALYTICS
@interface FeedViewController : GAITrackedViewController
#else

@interface FeedViewController : UIViewController
#endif


@property (strong,nonatomic)UIImage *latestImage;
@property (strong,nonatomic)NSString *lastestJson;

@end
