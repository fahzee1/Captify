//
//  UploaderAPIClient.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UploaderAPIClient.h"
#import "AppDelegate.h"

@implementation UploaderAPIClient

+ (instancetype)sharedClient
{
    static UploaderAPIClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *apiString = [NSString stringWithFormat:@"ApiKey %@:%@",[UploaderAPIClient myUser].username,[[NSUserDefaults standardUserDefaults] valueForKey:@"api_key" ]];
        [[NSUserDefaults standardUserDefaults] setValue:apiString forKey:@"apiString"];
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


+ (User *)myUser
{
    NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
    NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
    NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    NSError *error;
    return  (id) [context existingObjectWithID:superuserID error:&error];
    
}





@end
