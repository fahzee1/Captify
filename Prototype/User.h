//
//  User.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * facebook_user;
@property (nonatomic, retain) NSDate * last_activity;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSNumber * is_logged;
@property (nonatomic, retain) NSNumber * super_user;

@end
