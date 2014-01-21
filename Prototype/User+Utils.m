//
//  User+Utils.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "User+Utils.h"
#import "AwesomeAPICLient.h"
#import "HomeViewController.h"


@implementation User (Utils)

- (BOOL)isFacebookUser
{
    return self.facebook_user ? YES:NO;
}

- (BOOL)isPrivate
{
    return self.private ? YES:NO;
}


+ (User *)CreateUserWithParams:(NSDictionary *)params
  inManagedObjectContext:(NSManagedObjectContext *)context;
{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(User.super_user = 1) and (User.username = %@)",[params valueForKey:@"username"]];
    
    NSError *error;
    NSArray *fetch = [context executeFetchRequest:request error:&error];
    if (fetch)
    {
        return [fetch firstObject];
    }
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [user setValue:[params valueForKey:@"username"] forKey:@"username"];
    [user setValue:[NSNumber numberWithInt:0] forKey:@"score"];
    [user setValue:[params valueForKey:@"facebook_user"] forKey:@"facebook_user"];
    [user setValue:[params valueForKey:@"privacy"] forKey:@"private"];
    [user setValue:[NSNumber numberWithBool:YES] forKey:@"super_user"];
    //[user setValue:[params valueForKey:@"last_activity"] forKey:@"last_activity"];
    return user;
}




+ (NSURLSessionDataTask *)loginWithUsernameAndPassword:(NSDictionary *)params
                                              callback:(AwesomeAPICompleteBlock)block
{
    
    return [[AwesomeAPICLient sharedClient] POST:AwesomeAPILoginUrlString
                                      parameters:params
                                         success:^(NSURLSessionDataTask *task, id responseObject) {
                                             // things went well
                                             if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                                 NSString *username = [responseObject valueForKeyPath:@"user.username"];
                                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                 [defaults setValue:username forKey:@"username"];
                                                 [defaults setBool:YES forKey:@"logged"];
                                                 //[defaults setInteger:[[responseObject valueForKey:@"score"] intValue] forKey:@"score"];
                                                 //[defaults setInteger:[[responseObject valueForKey:@"privacy"] intValue] forKey:@"privacy"];
                                                 //[defaults setBool:[[responseObject valueForKey:@"facebook_user"] boolValue] forKey:@"facebook_user"];
                                                 //[defaults setBool:1 forKey:@"logged"];
                                                 //[defaults synchronize];
                                                 
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
