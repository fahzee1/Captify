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
#import "AppDelegate.h"


@implementation User (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
}

- (BOOL)isFacebookUser
{
    return self.facebook_user ? YES:NO;
}

- (BOOL)isPrivate
{
    return self.private ? YES:NO;
}


+ (User *)CreateOrGetUserWithParams:(NSDictionary *)params
  inManagedObjectContext:(NSManagedObjectContext *)context;
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"(super_user = 1) and (username = %@)",[params valueForKey:@"username"]];
    
    // check to see if we have this user (login)
    NSInteger gotUser = [self checkIfUserWithFetch:request
                                           context:context
                                             error:&error];
    if (gotUser)
    {
        // if we have user return user
        return [self getUserWithFetch:request
                              context:context
                                error:&error];
    }
    
    // else create a user, save, and return user (register)
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [user setValue:[params valueForKey:@"username"] forKey:@"username"];
    [user setValue:[params valueForKey:@"facebook_user"] forKey:@"facebook_user"];
    [user setValue:[params valueForKey:@"privacy"] forKey:@"private"];
    [user setValue:[NSNumber numberWithBool:YES] forKey:@"super_user"];
    [user setValue:[params valueForKey:@"timestamp"] forKey:@"timestamp"];
    if (![context save:&error]){
        NSLog(@"error saving");
    }
    return user;
}


+ (User *)getUserWithFetch:(NSFetchRequest *)fetch
                   context:(NSManagedObjectContext *)context
                     error:(NSError **)error
{
    NSArray *results = [context executeFetchRequest:fetch error:error];
    return [results firstObject];
    
}

+ (NSInteger)checkIfUserWithFetch:(NSFetchRequest *)fetch
                          context:(NSManagedObjectContext *)context
                            error:(NSError **)error
{
    NSInteger getUser = 0;
    getUser = [context countForFetchRequest:fetch error:error];
    return getUser;
}


+ (NSURLSessionDataTask *)loginWithUsernameAndPassword:(NSDictionary *)params
                                              callback:(AwesomeAPICompleteBlock)block
{
    
    return [[AwesomeAPICLient sharedClient] POST:AwesomeAPILoginUrlString
                                      parameters:params
                                         success:^(NSURLSessionDataTask *task, id responseObject) {
                                             // things went well
                                             if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                                 // get params from response
                                                 User *user = nil;
                                                NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                                                NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
                                                if (uri){
                                                     NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
                                                     NSError *error;
                                                     user = (id) [context existingObjectWithID:superuserID error:&error];
                                                 }

                                                 NSString *username = [responseObject valueForKeyPath:@"user.username"];
                                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                 [defaults setValue:username forKey:@"username"];
                                                 [defaults setBool:YES forKey:@"logged"];
                                                 [defaults synchronize];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(YES,context, user, NO);
                                                 });                                             }
                                             // things did not go well because of user
                                             if ([[responseObject valueForKey:@"code"] intValue] == -1){
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(NO,responseObject, nil,NO);
                                                 });
                                                 
                                             }
                                             // things did not go well because of me
                                             if ([[responseObject valueForKey:@"code"] intValue] == -10){
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(NO,responseObject, nil, NO);
                                                 });
                                                 
                                             }
                                             
                                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                             // something very unexpected happened
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 block(NO,error,nil,YES);
                                             });
                                             
                                             
                                         }];
}

+ (NSURLSessionDataTask *)registerWithParams:(NSDictionary *)params
                                    callback:(AwesomeAPICompleteBlock)block;
{
    return [[AwesomeAPICLient sharedClient] POST:AwesomeAPIRegisterUrlString
                                      parameters:params
                                         success:^(NSURLSessionDataTask *task, id responseObject) {
                                              // things went well
                                             if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                                 // get params from response
                                                 NSString *username = [responseObject valueForKeyPath:@"username"];
                                                 NSNumber *score = [NSNumber numberWithInt:0];
                                                 NSNumber *facebook = [NSNumber numberWithBool:[[responseObject valueForKey:@"facebook_user"] boolValue]];
                                                 NSNumber *privacy = [NSNumber numberWithInt:0];
                                                 NSDate *date = [NSDate date];
                                                 NSNumber *super_user = [NSNumber numberWithInt:1]; //is a super user
                                                 
                                                // prepare to get or create a user
                                                 NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                                                 NSDictionary *gcParams = @{@"username": username,
                                                                            @"score": score,
                                                                            @"facebook_user":facebook,
                                                                            @"privacy":privacy,
                                                                            @"super_user":super_user,
                                                                            @"timestamp":date};
                                                 
                                                 User *user = [self CreateOrGetUserWithParams:gcParams inManagedObjectContext:context];
                                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                 [defaults setValue:username forKey:@"username"];
                                                 [defaults setBool:YES forKey:@"logged"];
                                                 [defaults setURL:user.objectID.URIRepresentation forKey:@"superuser"];
                                                 [defaults synchronize];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(YES,context,user ,NO);
                                                 });

                                                 
                                             }
                                             
                                             // things did not go well because of user
                                             if ([[responseObject valueForKey:@"code"] intValue] == -1){
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(NO,responseObject, nil, NO);
                                                 });
                                                 
                                             }
                                             
                                             // things did not go well because of me
                                             if ([[responseObject valueForKey:@"code"] intValue] == -10){
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(NO,responseObject, nil, NO);
                                                 });
                                             }
                                         }
                                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                                             // something very unexpected happened
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 block(NO,error, nil, YES);
                                             });

                                         }];
}

@end
