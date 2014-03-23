//
//  UploaderAPIClient.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UploaderAPIClient.h"

@implementation UploaderAPIClient

+ (instancetype)sharedClient
{
    static UploaderAPIClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *apiString = [defaults valueForKey:@"apiString"];
        client = [[UploaderAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AwesomeAPIBaseUrlString]];
        client.responseSerializer = [AFJSONResponseSerializer serializer];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        [client.requestSerializer setHTTPMethodsEncodingParametersInURI:[NSSet setWithObject:@"POST"]];
        [client.requestSerializer setValue:apiString forHTTPHeaderField:@"Authorization"];
        
        
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
            {
                UIAlertView *a = [[UIAlertView alloc]
                                  initWithTitle:@"Oops!"
                                  message:@"There doesn't seem to be an internet connection"
                                  delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil];
                [a show];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //NSLog(@"WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //NSLog(@"3G");
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
