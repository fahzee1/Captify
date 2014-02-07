//
//  Challenge+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "Challenge.h"

@interface Challenge (Utils)

+ (Challenge *)GetOrCreateChallengeWithParams:(NSDictionary *)params
             inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)sendChallengeResults:(NSDictionary *)params
                                     challenge:(Challenge *)challenge;

+ (NSArray *)getChallengesWithUsername:(NSString *)username
                           fromFriends:(BOOL)FF
                                getAll:(BOOL)all
                               context:(NSManagedObjectContext *)context;

@end
