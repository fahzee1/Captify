//
//  AwesomeAPICLient.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AwesomeAPICLient.h"


@implementation AwesomeAPICLient

+ (instancetype)sharedClient
{
    static AwesomeAPICLient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[AwesomeAPICLient alloc] initWithBaseURL:[NSURL URLWithString:AwesomeAPIBaseUrlString]];
        client.responseSerializer = [AFJSONResponseSerializer serializer];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *apiString = [NSString stringWithFormat:@"ApiKey %@:%@",[defaults valueForKey:@"username"],[defaults valueForKey:@"api_key"]];
        [client.requestSerializer setValue:apiString
                        forHTTPHeaderField:@"Authorization"];
        
        
    });
    
    return client;
}

- (BOOL)connected
{
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

- (void)startMonitoringConnection
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"No Internet connection");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                break;
            default:
                NSLog(@"Unknown network");
                break;
        }
    }];
    
}

- (void)stopMonitoringConnection
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)startNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}





@end
