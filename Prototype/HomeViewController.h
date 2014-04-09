//
//  HomeViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//
// Root controller. If not authenticated performs segue to login screen
// else let user use app.

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "TWTSideMenuViewController.h"
#import "OverlayView.h"


@protocol showingMenu <NSObject>

@optional
- (void)showingMenuFromHome;

@end

@interface HomeViewController : UIViewController


@property (nonatomic, retain)User *myUser; //get managedobjectcontext from myuser
@property (nonatomic, assign)BOOL showResults;
@property (nonatomic,assign)BOOL success;
@property (nonatomic,assign)BOOL goToLogin;

@end
