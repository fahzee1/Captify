//
//  HistorySentViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/7/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

#ifdef USE_GOOGLE_ANALYTICS
    #import "GAITrackedViewController.h"
#endif


typedef void(^FetchRecentsBlock2)();

#ifdef USE_GOOGLE_ANALYTICS
    @interface HistorySentViewController : GAITrackedViewController
#else
    @interface HistorySentViewController : UIViewController
#endif


@property (strong, nonatomic) NSString *challenge_id;
@property (nonatomic, retain)User *myUser;


- (void)fetchUpdates;
- (void)reloadMyTable;

@end
