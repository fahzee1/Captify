//
//  SettingsEditViewController.h
//  Captify
//
//  Created by CJ Ogbuehi on 6/9/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "MZFormSheetController.h"

@interface SettingsEditViewController : UIViewController


@property (strong, nonatomic) User *myUser;
@property (strong, nonatomic) MZFormSheetController *controller;
@property (strong, nonatomic) UITableView *myTable;
@end
