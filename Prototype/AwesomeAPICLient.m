//
//  AwesomeAPICLient.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AwesomeAPICLient.h"

static NSString * const AwesomeAPIBaseUrlString = @"http://127.0.0.1:8000";
static NSString * const AwesomeAPILoginUrlString = @"api/v1/profile/login";

@implementation AwesomeAPICLient

+ (instancetype)sharedClient
{
    static AwesomeAPICLient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[AwesomeAPICLient alloc] initWithBaseURL:[NSURL URLWithString:AwesomeAPIBaseUrlString]];
        client.responseSerializer = [AFJSONResponseSerializer serializer];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        [client.requestSerializer setValue:@"ApiKey square:9c20d19987ecd0c396d06fc58981588ba88f91bc"
                        forHTTPHeaderField:@"Authorization"];
        
        
    });
    
    return client;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password withCallback:(AwesomeAPICompleteBlock)block
{
    NSDictionary *params = @{@"username": username,
                             @"password": password};
    
    [self POST:AwesomeAPILoginUrlString parameters:params
       success:^(NSURLSessionDataTask *task, id responseObject) {
           // things went well
           if ([[responseObject valueForKey:@"code"] intValue] == 1){
               block(YES,responseObject);
            
           }
           // things did not go well because of user
           if ([[responseObject valueForKey:@"code"] intValue] == -1){
               block(NO,responseObject);
           }
           // things did not go well because of me
           if ([[responseObject valueForKey:@"code"] intValue] == -10){
               block(NO,responseObject);
           }

           

       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           // something very unexpected happened
           block(NO, error);
       }];
}
@end
