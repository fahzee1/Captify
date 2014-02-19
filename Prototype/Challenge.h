//
//  Challenge.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/19/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChallengePicks, ChallengeSend, User;

@interface Challenge : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * selected_answer;
@property (nonatomic, retain) NSString * challenge_id;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * success;
@property (nonatomic, retain) NSNumber * sync_status;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * fields_count;
@property (nonatomic, retain) NSString * original_answer;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) ChallengeSend *sends;
@property (nonatomic, retain) ChallengePicks *picks;

@end
