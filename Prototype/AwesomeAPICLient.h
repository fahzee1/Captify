//
//  AwesomeAPICLient.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"

//static NSString * const AwesomeAPIBaseUrlString = @"http://127.0.0.1:8000";
static NSString * const AwesomeAPIBaseUrlString = @"http://192.168.1.72:8000";
static NSString * const AwesomeAPILoginUrlString = @"api/v1/profile/login";


@interface AwesomeAPICLient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (BOOL)connected;

- (void)startMonitoringConnection;

- (void)stopMonitoringConnection;

- (void)startNetworkActivity;

- (void)stopNetworkActivity;



@end
