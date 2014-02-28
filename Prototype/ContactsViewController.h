//
//  FriendsViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/12/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@interface ContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>



@property (nonatomic, retain)User *myUser;
@property (strong, nonatomic)NSArray *myFriends;

@end
