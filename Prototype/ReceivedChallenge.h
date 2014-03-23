//
//  ReceivedChallenge.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/23/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChallengePicks, User;

@interface ReceivedChallenge : NSManagedObject

@property (nonatomic, retain) NSString * challenge_id;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * selected_phrase;
@property (nonatomic, retain) NSNumber * is_chosen;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSString * image_path;
@property (nonatomic, retain) NSNumber * recipients_count;
@property (nonatomic, retain) NSSet *picks;
@property (nonatomic, retain) User *sender;
@end

@interface ReceivedChallenge (CoreDataGeneratedAccessors)

- (void)addPicksObject:(ChallengePicks *)value;
- (void)removePicksObject:(ChallengePicks *)value;
- (void)addPicks:(NSSet *)values;
- (void)removePicks:(NSSet *)values;

@end
