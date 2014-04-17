//
//  FriendsViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/12/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"


@class ContactsViewController;

@protocol ContactsControllerDelegate <NSObject>

- (void)ContactViewControllerPressedDone:(ContactsViewController *)controller;
- (void)ContactViewControllerPressedCancel:(ContactsViewController *)controller;

@optional;
#warning implement this method
- (void)ContactViewControllerDataChanged:(ContactsViewController *)controller;

@end



@interface ContactsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (weak)id<ContactsControllerDelegate>delegate;
@property (nonatomic, retain)User *myUser;
@property (strong, nonatomic)NSArray *myFriends;
@property (strong,nonatomic)NSArray *selection;

@end


