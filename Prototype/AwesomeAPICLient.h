//
//  AwesomeAPICLient.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager+AutoRetry.h"
#import "AFNetworkReachabilityManager.h"
#import "User.h"

//static NSString * const AwesomeAPIBaseUrlString = @"http://127.0.0.1:8000";

static NSString * const AwesomeAPIBaseUrlString = @"http://192.168.1.72:8000";

//static NSString * const AwesomeAPIBaseUrlString = @"http://209.86.112.72:8000";

// live urls http and https versions

//static NSString * const AwesomeAPIBaseUrlString = @"http://api.gocaptify.com";

static NSString * const AwesomeAPILoginUrlString = @"api/v1/profile/login";
static NSString * const AwesomeAPIRegisterUrlString = @"api/v1/register";
static NSString * const AwesomeAPIFacebookUrlString = @"api/v1/register/facebook";
static NSString * const AwesomeAPISettingsString = @"/api/v1/profile/settings";
static NSString * const AwesomeAPIFriendsString = @"/api/v1/profile/friends";
static NSString * const AwesomeAPIFetchString = @"/api/v1/profile/fetch";
static NSString * const AwesomeAPIProfileString = @"/api/v1/profile/get_profile";


// challenge urls
static NSString * const AwesomeAPIChallengeResultsString = @"api/v1/challenge/results";
static NSString * const AwesomeAPIChallengeCreateString = @"api/v1/challenge";
static NSString * const AwesomeAPIChallengeMediaString = @"api/v1/challenge/media";
static NSString * const AwesomeAPIChallengeUpdateString = @"api/v1/challenge/update";
static NSString * const AwesomeAPIChallengeCreatePickString = @"api/v1/challenge/picks";
static NSString * const AwesomeAPIChallengeFeedString = @"api/v1/challenge/feed";
static NSString * const AwesomeAPIChallengeDeleteString = @"api/v1/challenge/delete";

@interface AwesomeAPICLient : AFHTTPSessionManager

@property BOOL apiKeyFound;

+ (instancetype)sharedClient;


- (BOOL)connected;

- (void)startMonitoringConnection;

- (void)stopMonitoringConnection;

- (void)startNetworkActivity;

- (void)stopNetworkActivity;

+ (void)cancelCurrentRequest:(AwesomeAPICLient *)client;

+ (BOOL)requestInProgress:(AwesomeAPICLient *)client;

+ (User *)myUser;



@end
