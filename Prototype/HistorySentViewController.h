//
//  HistorySentViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/7/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

typedef void(^FetchRecentsBlock2)();

@interface HistorySentViewController : UIViewController

@property (nonatomic, retain)User *myUser;


- (void)fetchUpdatesWithBlock:(FetchRecentsBlock2)block;
- (void)reloadMyTable;

@end
