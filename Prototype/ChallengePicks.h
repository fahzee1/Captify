//
//  ChallengePicks.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/19/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Challenge, User;

@interface ChallengePicks : NSManagedObject

@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSNumber * is_chosen;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) Challenge *challenge;
@property (nonatomic, retain) User *player;

@end
