//
//  User.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/23/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Challenge, ChallengePicks, ReceivedChallenge;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * facebook_id;
@property (nonatomic, retain) NSNumber * facebook_user;
@property (nonatomic, retain) NSNumber * guid;
@property (nonatomic, retain) NSNumber * is_contactFriend;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSNumber * is_friend;
@property (nonatomic, retain) NSString * pic_url;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * super_user;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) ChallengePicks *picks;
@property (nonatomic, retain) Challenge *recipient_challenges;
@property (nonatomic, retain) NSSet *sent_challenges;
@property (nonatomic, retain) ReceivedChallenge *received_challenges;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addSent_challengesObject:(Challenge *)value;
- (void)removeSent_challengesObject:(Challenge *)value;
- (void)addSent_challenges:(NSSet *)values;
- (void)removeSent_challenges:(NSSet *)values;

@end
