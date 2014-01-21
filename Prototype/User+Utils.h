//
//  User+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "User.h"

typedef void (^AwesomeAPICompleteBlock) (BOOL wasSuccessful, id data, BOOL failure);

@interface User (Utils)



- (BOOL)isFacebookUser;
- (BOOL)isPrivate;

+ (User *)CreateUserWithParams:(NSDictionary *)params
        inManagedObjectContext:(NSManagedObjectContext *)context;


+ (NSURLSessionDataTask *)loginWithUsernameAndPassword:(NSDictionary *)params
                                              callback:(AwesomeAPICompleteBlock)block;
@end
