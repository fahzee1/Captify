//
//  RecentActivityViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface RecentActivityViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain)User *myUser;

@end
