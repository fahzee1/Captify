//
//  Challenge+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "Challenge.h"
#import "User.h"

@interface Challenge (Utils)

+ (Challenge *)GetOrCreateChallengeWithParams:(NSDictionary *)params
                       inManagedObjectContext:(NSManagedObjectContext *)context
                                   skipCreate:(BOOL)skipCreate;

+ (void)sendChallengeResults:(NSDictionary *)params
                                     challenge:(Challenge *)challenge;

+ (NSArray *)getChallengesWithUsername:(NSString *)username
                           fromFriends:(BOOL)FF
                                getAll:(BOOL)all
                               context:(NSManagedObjectContext *)context;

+ (NSArray *)getSentChallengesInContext:(NSManagedObjectContext *)context;


+ (NSURLSessionDataTask *)fetchChallengeWithUsernameAndID:(NSDictionary *)params;

+ (NSURLSessionDataTask *)sendCreateChallengeRequest:(NSDictionary *)params
                                               image:(NSData *)image;;

+ (Challenge *) createTestChallengeWithUser:(User *)user;

+ (Challenge *)createChallengeWithParams:(NSDictionary *)params;

+ (NSString *)createChallengeIDWithUser:(NSString *)user;

+ (void)saveImage:(UIImage *)image
         filename:(NSString *)name;

+ (UIImage *)loadImagewithFileName:(NSString *)name;

@end
