//
//  AwesomeUser.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AwesomeAPICompleteBlock) (BOOL wasSuccessful, id data, BOOL failure);

@interface AwesomeUser : NSObject

@property(nonatomic, assign, getter = isLogged) BOOL logged;



+ (instancetype)sharedClient;


+ (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                 password:(NSString *)password
                                 callback:(AwesomeAPICompleteBlock)block;

@end
