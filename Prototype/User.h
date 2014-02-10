//
//  User.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/10/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


// sync status codes
// 0 means no changes
// 1 means queued to be synchroized with the server
// 2 means its a temporary object that can be purged


@class Challenge, ChallengeSend;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * facebook_id;
@property (nonatomic, retain) NSNumber * facebook_user;
@property (nonatomic, retain) NSNumber * is_friend;
@property (nonatomic, retain) NSString * pic_url;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * super_user;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSNumber * guid;
@property (nonatomic, retain) NSSet *challenges;
@property (nonatomic, retain) ChallengeSend *sends;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addChallengesObject:(Challenge *)value;
- (void)removeChallengesObject:(Challenge *)value;
- (void)addChallenges:(NSSet *)values;
- (void)removeChallenges:(NSSet *)values;

@end
