//
//  HistoryViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

typedef void(^FetchRecentsBlock)();

@interface HistoryRecievedViewController : UIViewController


@property (nonatomic, retain)User *myUser;

- (void)fetchUpdatesWithBlock:(FetchRecentsBlock)block;

- (void)reloadMyTable;
@end