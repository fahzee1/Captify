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
typedef void (^BlobFetchBlock) (BOOL wasSuccessful, id data, NSString* message);

@interface User (Utils)

+ (NSString *)name;

- (BOOL)isFacebookUser;
- (BOOL)isPrivate;

- (void)getCorrectProfilePicWithImageView:(UIImageView *)iV;


+ (BOOL)validPhoneNumber:(NSString *)number;

+ (BOOL)createContactsWithParams:(NSDictionary *)params
           inMangedObjectContext:(NSManagedObjectContext *)context;

+ (User *)getUserWithUsername:(NSString *)username
                    inContext:(NSManagedObjectContext *)context
                        error:(NSError **)error;

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


+ (void)updateDeviceTokenWithParams:(NSDictionary *)params
                           callback:(DeviceTokenSendBlock)block;

+ (NSArray *)fetchFriendsInContext:(NSManagedObjectContext *)context
                       getContacts:(BOOL)contacts;

+ (void)fetchUserBlobWithParams:(NSDictionary *)params
                          block:(BlobFetchBlock)block;

@end
