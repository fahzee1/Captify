//
//  TestDataCreator.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User+Utils.h"
#import "Challenge+Utils.h"
#import "ChallengePicks+Utils.h"

@interface TestDataCreator : NSObject

+ (User *)createTestFriendWithName:(NSString *)name
                          facebook:(BOOL)facebook
                              fbID:(NSString *)fbID
                         inContext:(NSManagedObjectContext*)context;

+ (Challenge *)createTestChallengeWithName:(NSString *)name
                                    byUser:(User *)sender
                                 toFriends:(NSArray *)friends
                                    withID:(NSString *)cID;

+ (ChallengePicks *)addChallengePickToChallenge:(Challenge *)challenge
                                     withPlayer:(User *)player
                                        caption:(NSString *)caption;



+ (NSArray *)createTestFriendsBatch:(int)count
                           facebook:(BOOL)facebook
                          inContext:(NSManagedObjectContext*)context;

+ (NSArray *)createTestChallengeBatch:(int)count
                             fromUser:(User *)sender
                            toFriends:(NSArray *)friends
                               withID:(NSString *)cID;







@end
