//
//  AwesomeAPICLient.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AwesomeAPICLient.h"

static NSString * const AwesomeAPIBaseUrlString = @"127.0.0.1:8000";
static NSString * const AwesomeAPILoginUrlString = @"api/v1/profile/login";

@implementation AwesomeAPICLient

+ (instancetype)sharedClient
{
    static AwesomeAPICLient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[AwesomeAPICLient alloc] initWithBaseURL:[NSURL URLWithString:AwesomeAPIBaseUrlString]];
        client.responseSerializer = [AFJSONResponseSerializer serializer];
        
        
        
    });
    
    return client;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password withCallback:(AwesomeAPICompleteBlock)block
{
    NSDictionary *params = @{@"username": username,
                             @"password": password};
    
    [self POST:AwesomeAPILoginUrlString parameters:params
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSLog(@" the task was: %@ and the response was %@", task, responseObject);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"the task was %@ and the error is %@", task, error);
       }];
}
@end
