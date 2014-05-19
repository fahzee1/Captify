//
//  HistoryViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

#ifdef USE_GOOGLE_ANALYTICS
    #import "GAITrackedViewController.h"
#endif

typedef void(^FetchRecentsBlock)();

#ifdef USE_GOOGLE_ANALYTICS
    @interface HistoryRecievedViewController : GAITrackedViewController
#else
    @interface HistoryRecievedViewController : UIViewController
#endif



@property (nonatomic, retain)User *myUser;

- (void)fetchUpdates;

- (void)reloadMyTable;
@end