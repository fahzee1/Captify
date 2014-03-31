//
//  ChallengePicks.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/31/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Challenge, User;

@interface ChallengePicks : NSManagedObject

@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSNumber * is_chosen;
@property (nonatomic, retain) NSString * pick_id;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * first_open;
@property (nonatomic, retain) User *player;
@property (nonatomic, retain) Challenge *challenge;

@end
