//
//  User.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/21/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * super_user;
@property (nonatomic, retain) NSNumber * facebook_user;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * private;

@end
