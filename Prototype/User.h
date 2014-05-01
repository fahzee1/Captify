//
//  User.h
//  Captify
//
//  Created by CJ Ogbuehi on 4/30/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Challenge, ChallengePicks;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSNumber * facebook_user;
@property (nonatomic, retain) NSNumber * guid;
@property (nonatomic, retain) NSNumber * is_contactFriend;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSNumber * is_friend;
@property (nonatomic, retain) NSString * phone_number;
@property (nonatomic, retain) NSString * pic_url;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * super_user;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *picks;
@property (nonatomic, retain) NSSet *recipient_challenges;
@property (nonatomic, retain) NSSet *sent_challenges;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPicksObject:(ChallengePicks *)value;
- (void)removePicksObject:(ChallengePicks *)value;
- (void)addPicks:(NSSet *)values;
- (void)removePicks:(NSSet *)values;

- (void)addRecipient_challengesObject:(Challenge *)value;
- (void)removeRecipient_challengesObject:(Challenge *)value;
- (void)addRecipient_challenges:(NSSet *)values;
- (void)removeRecipient_challenges:(NSSet *)values;

- (void)addSent_challengesObject:(Challenge *)value;
- (void)removeSent_challengesObject:(Challenge *)value;
- (void)addSent_challenges:(NSSet *)values;
- (void)removeSent_challenges:(NSSet *)values;

@end
