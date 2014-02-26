//
//  User.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/26/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Challenge, ChallengePicks, FriendsAddedMe, FriendsIAdded;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * facebook_id;
@property (nonatomic, retain) NSNumber * facebook_user;
@property (nonatomic, retain) NSNumber * guid;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSNumber * is_friend;
@property (nonatomic, retain) NSString * pic_url;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * super_user;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *sent_challenges;
@property (nonatomic, retain) FriendsAddedMe *friends_added_me;
@property (nonatomic, retain) FriendsIAdded *friends_i_added;
@property (nonatomic, retain) ChallengePicks *picks;
@property (nonatomic, retain) Challenge *received_challenges;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addSent_challengesObject:(Challenge *)value;
- (void)removeSent_challengesObject:(Challenge *)value;
- (void)addSent_challenges:(NSSet *)values;
- (void)removeSent_challenges:(NSSet *)values;

@end
