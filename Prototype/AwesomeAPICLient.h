//
//  AwesomeAPICLient.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

typedef void (^AwesomeAPICompleteBlock) (BOOL wasSuccessful, id data);

@interface AwesomeAPICLient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)loginWithUsername:(NSString *)username
                 password:(NSString*)password
             withCallback:(AwesomeAPICompleteBlock)block;

@end
