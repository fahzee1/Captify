//
//  Challenge.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/26/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChallengePicks, User;

@interface Challenge : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * challenge_id;
@property (nonatomic, retain) NSNumber * fields_count;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * original_phrase;
@property (nonatomic, retain) NSString * selected_phrase;
@property (nonatomic, retain) NSNumber * success;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) ChallengePicks *picks;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) NSSet *recipients;
@end

@interface Challenge (CoreDataGeneratedAccessors)

- (void)addRecipientsObject:(User *)value;
- (void)removeRecipientsObject:(User *)value;
- (void)addRecipients:(NSSet *)values;
- (void)removeRecipients:(NSSet *)values;

@end
