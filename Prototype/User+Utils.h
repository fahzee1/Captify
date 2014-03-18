//
//  User+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "User.h"

typedef void (^AwesomeAPICompleteBlock) (BOOL wasSuccessful, id data, User *user, BOOL failure);
typedef void (^DeviceTokenSendBlock) (BOOL wasSuccessful);

@interface User (Utils)



- (BOOL)isFacebookUser;
- (BOOL)isPrivate;

+ (BOOL)validPhoneNumber:(NSString *)number;

+ (BOOL)createContactsWithParams:(NSDictionary *)params
           inMangedObjectContext:(NSManagedObjectContext *)context;

+ (User *)GetOrCreateUserWithParams:(NSDictionary *)params
             inManagedObjectContext:(NSManagedObjectContext *)context
                         skipCreate:(BOOL)skip;


+ (NSURLSessionDataTask *)loginWithUsernameAndPassword:(NSDictionary *)params
                                              callback:(AwesomeAPICompleteBlock)block;

+ (NSURLSessionDataTask *)registerWithParams:(NSDictionary *)params
                                              callback:(AwesomeAPICompleteBlock)block;

+ (NSURLSessionDataTask *)registerFacebookWithParams:(NSDictionary *)params
                                    callback:(AwesomeAPICompleteBlock)block;

+ (void)getFacebookPicWithUser:(User *)user
                     imageview:(UIImageView *)iv;

+ (User *)createTestFriendWithName:(NSString *)name
                            context:(NSManagedObjectContext *)context;

+ (void)updateDeviceTokenWithParams:(NSDictionary *)params
                           callback:(DeviceTokenSendBlock)block;

+ (NSArray *)fetchFriendsInContext:(NSManagedObjectContext *)context;

@end
