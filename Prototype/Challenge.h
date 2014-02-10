//
//  Challenge.h
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

@class ChallengeSend, User;

@interface Challenge : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSString * challenge_id;
@property (nonatomic, retain) NSString * hint;
@property (nonatomic, retain) NSNumber * success;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) ChallengeSend *sends;

@end
