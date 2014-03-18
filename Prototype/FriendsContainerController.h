//
//  FriendsContainerController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface FriendsContainerController : UIViewController


@property (strong, nonatomic)NSArray *facebookFriendsArray;
@property (nonatomic, retain)User *myUser;

@end
