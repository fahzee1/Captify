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
typedef void (^ProfileFetchBlock) (BOOL wasSuccessful, NSNumber *json, id data);
typedef void (^SearchBlock) (BOOL wasSuccessful,NSArray *data);

@interface User (Utils)

+ (NSString *)name;

- (NSString *)displayName;
- (NSString *)firstName;
- (NSString *)lastName;

- (BOOL)isFacebookUser;
- (BOOL)isPrivate;

- (void)getCorrectProfilePicWithImageView:(UIImageView *)iV;


+ (BOOL)validPhoneNumber:(NSString *)number;

+ (NSDictionary *)createFriendWithParams:(NSDictionary *)params
           inMangedObjectContext:(NSManagedObjectContext *)context;

+ (User *)getUserWithUsername:(NSString *)username
                    inContext:(NSManagedObjectContext *)context
                        error:(NSError **)error;

+ (User *)getOrCreateUserWithParams:(NSDictionary *)params
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

+ (void)fetchMediaBlobWithParams:(NSDictionary *)params
                           block:(BlobFetchBlock)block;

+ (void)sendProfileUpdatewithParams:(NSDictionary *)params
                              block:(BlobFetchBlock)block;

+ (void)fetchUserProfileWithData:(NSDictionary *)params
                              block:(ProfileFetchBlock)block;

+ (void)searchForUserWithData:(NSDictionary *)params
                           block:(SearchBlock)block;


+(void)showProfileOnVC:(UIViewController *)controller
          withUsername:(NSString *)name
               usingMZHud:(BOOL)usingHud
       fromExplorePage:(BOOL)explorePage
       showCloseButton:(BOOL)showCloseButton
     delaySetupWithTme:(float)delay;



@end
