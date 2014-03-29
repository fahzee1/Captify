//
//  Challenge+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "Challenge.h"
#import "User.h"


typedef void (^ChallengeUpdateBlock) (BOOL wasSuccessful, NSString *message);
typedef void (^SendChallengeRequestBlock) (BOOL wasSuccessful,BOOL fail, NSString *message, id data);

@interface Challenge (Utils)

+ (NSString *)name;

+ (NSString *)baseUrl;

+ (NSString *)dateStringFromDate:(NSDate *)date;

+ (Challenge *)GetOrCreateChallengeWithParams:(NSDictionary *)params
                       inManagedObjectContext:(NSManagedObjectContext *)context
                                   skipCreate:(BOOL)skipCreate;


+ (void)updateChallengeWithParams:(NSDictionary *)params
                            block:(ChallengeUpdateBlock)block;

+ (Challenge *)getChallengeWithID:(NSString *)challenge_id
                        inContext:(NSManagedObjectContext *)context;

+ (void)sendChallengeResults:(NSDictionary *)params
                                     challenge:(Challenge *)challenge;

+ (NSArray *)getChallengesWithUsername:(NSString *)username
                           fromFriends:(BOOL)FF
                                getAll:(BOOL)all
                               context:(NSManagedObjectContext *)context;

+ (NSArray *)getHistoryChallengesInContext:(NSManagedObjectContext *)context
                                      sent:(BOOL)sent;


+ (NSURLSessionDataTask *)fetchChallengeWithUsernameAndID:(NSDictionary *)params;


+ (NSURLSessionDataTask *)sendCreateChallengeRequest:(NSDictionary *)params
                                               image:(NSData *)image;

//use this one not ^ 
+ (void)sendCreateChallengeRequestWithParams:(NSDictionary *)params
                                       block:(SendChallengeRequestBlock)block;
 

+ (Challenge *) createTestChallengeWithUser:(User *)user;

+ (Challenge *)createChallengeWithRecipientsWithParams:(NSDictionary *)params;

+ (NSString *)createChallengeIDWithUser:(NSString *)user;

+ (void)saveImage:(UIImage *)image
         filename:(NSString *)name;

+ (UIImage *)loadImagewithFileName:(NSString *)name;

@end
