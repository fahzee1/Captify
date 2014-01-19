//
//  AwesomeUser.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AwesomeUser.h"
#import "AwesomeAPICLient.h"

NSString * const kUserLoggedOutNotification = @"kUserLoggedOutNotification";

@interface AwesomeUser()
//private properties

@end
@implementation AwesomeUser

- (void)setLogged:(BOOL)logged
{
    _logged = logged;
    
    if (_logged == NO){
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedOutNotification
                                                            object:self];
    }
}

+ (instancetype)sharedClient
{
    static id sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    
    return sharedClient;
}



+ (NSURLSessionDataTask *)loginWithUsername:(NSString *)username password:(NSString *)password callback:(AwesomeAPICompleteBlock)block
{
    NSDictionary *params = @{@"username": username,
                             @"password": password};
    
    return [[AwesomeAPICLient sharedClient] POST:AwesomeAPILoginUrlString
                                      parameters:params
                                         success:^(NSURLSessionDataTask *task, id responseObject) {
                                             // things went well 
                                             if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                                 NSString *username = [responseObject valueForKeyPath:@"user.username"];
                                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                 [defaults setValue:username forKey:@"username"];
                                                 [defaults setInteger:[[responseObject valueForKey:@"score"] intValue] forKey:@"score"];
                                                 [defaults setInteger:[[responseObject valueForKey:@"privacy"] intValue] forKey:@"privacy"];
                                                 [defaults setBool:[[responseObject valueForKey:@"facebook_user"] boolValue] forKey:@"facebook_user"];
                                                 [defaults setBool:1 forKey:@"logged"];
                                                 AwesomeUser *user = [self sharedClient];
                                                 user.logged = YES;
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                          block(YES,responseObject, NO);
                                                 });
                                             }
                                             // things did not go well because of user
                                             if ([[responseObject valueForKey:@"code"] intValue] == -1){
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(NO,responseObject, NO);
                                                 });

                                             }
                                             // things did not go well because of me
                                             if ([[responseObject valueForKey:@"code"] intValue] == -10){
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(NO,responseObject, NO);
                                                 });

                                             }

                                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                             // something very unexpected happened
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 block(NO,error, YES);
                                             });


                                         }];
}

@end
