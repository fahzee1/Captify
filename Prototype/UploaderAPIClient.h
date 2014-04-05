//
//  UploaderAPIClient.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "AFNetworkReachabilityManager.h"
#import "User.h"

//static NSString * const AwesomeAPIBaseUrlString = @"http://127.0.0.1:8000";
static NSString * const AwesomeAPIBaseUrlString = @"http://192.168.1.72:8000";
//static NSString * const AwesomeAPIBaseUrlString = @"http://209.86.112.66:8000";
static NSString * const AwesomeAPILoginUrlString = @"api/v1/profile/login";
static NSString * const AwesomeAPIRegisterUrlString = @"api/v1/register";
static NSString * const AwesomeAPIFacebookUrlString = @"api/v1/register/facebook";
static NSString * const AwesomeAPISettingsString = @"/api/v1/profile/settings";
static NSString * const AwesomeAPIFriendsString = @"/api/v1/profile/friends";
static NSString * const AwesomeAPIFetchString = @"/api/v1/profile/fetch";

// challenge urls
static NSString * const AwesomeAPIChallengeResultsString = @"api/v1/challenge/results";
static NSString * const AwesomeAPIChallengeSendString = @"api/v1/challenge/send";
static NSString * const AwesomeAPIChallengeCreateString = @"api/v1/challenge";
static NSString * const AwesomeAPIChallengeFetchString = @"api/v1/challenge/blob";

@interface UploaderAPIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

- (BOOL)connected;

- (void)startMonitoringConnection;

- (void)stopMonitoringConnection;

- (void)startNetworkActivity;

- (void)stopNetworkActivity;

+ (User *)myUser;

@end
