//
//  FriendsAddedMe.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/19/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface FriendsAddedMe : NSManagedObject

@property (nonatomic, retain) User *friend;

@end
