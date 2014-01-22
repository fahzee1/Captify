//
//  HomeViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

@interface HomeViewController : UIViewController

@property (nonatomic, retain)NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain)User *myUser;

@end
