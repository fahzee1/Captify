//
//  Challenge.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChallengeSend, User;

@interface Challenge : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * challenge_id;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * answer;
@property (nonatomic, retain) NSString * hint;
@property (nonatomic, retain) NSNumber * success;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) User *sender;
@property (nonatomic, retain) ChallengeSend *sends;

@end
