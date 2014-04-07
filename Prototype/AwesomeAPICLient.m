//
//  AwesomeAPICLient.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AwesomeAPICLient.h"
#import "AppDelegate.h"


@implementation AwesomeAPICLient

+ (instancetype)sharedClient
{
    static AwesomeAPICLient *client = nil;
    
    
    NSString *apiString;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"]){
        apiString =  [NSString stringWithFormat:@"ApiKey %@:%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"username"],[[NSUserDefaults standardUserDefaults] valueForKey:@"api_key" ]];
         [[NSUserDefaults standardUserDefaults] setValue:apiString forKey:@"apiString"];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[AwesomeAPICLient alloc] initWithBaseURL:[NSURL URLWithString:AwesomeAPIBaseUrlString]];
        client.responseSerializer = [AFJSONResponseSerializer serializer];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        [client.requestSerializer setValue:apiString forHTTPHeaderField:@"Authorization"];
        client.apiKeyFound = YES;
    });
    
    [client.requestSerializer setValue:apiString forHTTPHeaderField:@"Authorization"];
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


+ (User *)myUser
{
        NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
        NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
        NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        NSError *error;
        return  (id) [context existingObjectWithID:superuserID error:&error];

}



@end
