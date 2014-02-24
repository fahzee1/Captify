//
//  Challenge+Utils.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "Challenge+Utils.h"
#import "AwesomeAPICLient.h"
#import "AppDelegate.h"
#import "User+Utils.h"

@implementation Challenge (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.timestamp = [NSDate date];
    self.success = [NSNumber numberWithBool:NO];
    self.active = [NSNumber numberWithBool:YES];
}


- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
}



+ (Challenge *)GetOrCreateChallengeWithParams:(NSDictionary *)params
                       inManagedObjectContext:(NSManagedObjectContext *)context
                                   skipCreate:(BOOL)skip
{
    NSParameterAssert(context);
    NSAssert([params objectForKey:@"challenge_id"], @"challenge id required");
    NSAssert([params objectForKey:@"username"] || [params objectForKey:@"sender"], @"username required");
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Challenge"];
    request.predicate = [NSPredicate predicateWithFormat:@"challenge_id = %@",[params valueForKey:@"challenge_id"]];
    
    // check to see if we have the challenge already
    NSInteger gotChallenge = [self checkIfChallengeWithFetch:request
                                           context:context
                                             error:&error];
    if (gotChallenge)
    {
        // if we have challenge return challenge
        return [self getChallengeWithFetch:request
                              context:context
                                error:&error];
    }
    
    /*
    // get user
    User *user = nil;
    NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
    if (uri){
        NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        user = (id) [context existingObjectWithID:superuserID error:&error];
    }
     */
    Challenge *challenge = nil;
    
    if (!skip){
        NSAssert([params valueForKey:@"original_answer"], @"must supply 'original answer' when creating challenge");
        NSAssert([params valueForKey:@"fields_count"], @"must supply 'fields count' when creating challenge");

        
        NSDictionary *smallParams = @{@"username": [params valueForKey:@"sender"]};
        User *user = [User GetOrCreateUserWithParams:smallParams
                              inManagedObjectContext:context
                                          skipCreate:YES];
        // no challenge create one
        challenge = [NSEntityDescription insertNewObjectForEntityForName:@"Challenge" inManagedObjectContext:context];

        challenge.original_answer = [params valueForKey:@"original_answer"];
        challenge.fields_count = [params valueForKey:@"fields_count"];
        challenge.challenge_id = [params valueForKey:@"challenge_id"];
        challenge.sender = user;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        challenge.challenge_id = [NSString stringWithFormat:@"%@-%@",[params valueForKey:@"sender"],uuid];
        challenge.active = [NSNumber numberWithBool:YES];
        if (![challenge.managedObjectContext save:&error]){
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();

        }
    }

    return  challenge;

}


+ (Challenge *)getChallengeWithFetch:(NSFetchRequest *)fetch
                   context:(NSManagedObjectContext *)context
                     error:(NSError **)error
{
    NSParameterAssert(fetch);
    NSParameterAssert(context);
    NSArray *results = [context executeFetchRequest:fetch error:error];
    return [results firstObject];
    
}

+ (NSArray *)getChallengesWithUsername:(NSString *)username
                           fromFriends:(BOOL)FF
                                getAll:(BOOL)all
                               context:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Challenge"];
    if (all){
        return [context executeFetchRequest:request error:&error];
    }
    
    if (!all && FF){
        request.predicate = [NSPredicate predicateWithFormat:@"(sender.username != %@) && (sender.is_friend = %@)",username,[NSNumber numberWithBool:YES]];
    }
    
    if (!all && !FF){
        request.predicate = [NSPredicate predicateWithFormat:@"sender.username = %@",username];
    }
    
    NSArray *returnAll;
    
    NSLog(@"%@",returnAll);
    return returnAll;

}


+ (NSArray *)fetchUsersHistoryInContext:(NSManagedObjectContext *)context
{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Challenge"];
    request.shouldRefreshRefetchedObjects = YES;
    request.fetchLimit = 20;
    request.predicate = [NSPredicate predicateWithFormat:@"(sender.super_user = 1) && (sender.is_friend = 0)"];
    NSError *error;
    
    return [context executeFetchRequest:request error:&error];
}


+ (NSInteger)checkIfChallengeWithFetch:(NSFetchRequest *)fetch
                          context:(NSManagedObjectContext *)context
                            error:(NSError **)error
{
    NSParameterAssert(fetch);
    NSParameterAssert(context);
    NSInteger getChallenge = 0;
    getChallenge = [context countForFetchRequest:fetch error:error];
    return getChallenge;
}


+ (void)sendChallengeResults:(NSDictionary *)params
                                     challenge:(Challenge *)challenge
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    challenge.active = [NSNumber numberWithBool:NO];
    [client startNetworkActivity];
    [client POST:AwesomeAPIChallengeResultsString
             parameters:params
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [client stopNetworkActivity];
                    NSLog(@"%@",responseObject);
                    int code = [[responseObject valueForKey:@"code"] intValue];
                    if (code == 1){
                        // we're good
                        NSLog(@"we're all good here");
                        challenge.sync_status = [NSNumber numberWithBool:NO];
                    }
                    
                    if (code == -10){
                        // 500 issue on our end
                        NSLog(@"we're not all good here");
                        challenge.sync_status = [NSNumber numberWithBool:YES];
                    }
                    
                }
                failure:^(NSURLSessionDataTask *task, NSError *error) {
                    //something bad happened
                    // find ways to handle this. maybe set it for retry
                    [client stopNetworkActivity];
                    NSLog(@"definitely not all good here");
                    challenge.sync_status = [NSNumber numberWithBool:YES];
                    

                } autoRetry:5];
    
    NSError *error;
    if ([challenge.managedObjectContext hasChanges]){
        if(![challenge.managedObjectContext save:&error]){
            NSLog(@"error saving active status of challenge");
        }
    }
}

+ (NSURLSessionDataTask *)fetchChallengeWithUsernameAndID:(NSDictionary *)params
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPIChallengeFetchString
             parameters:params
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [client stopNetworkActivity];
                    int code = [[responseObject valueForKey:@"code"] intValue];
                    if (code == 1){
                         NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                        NSDictionary *params = @{@"level": [responseObject valueForKey:@"challenge_type"],
                                                 @"answer": [responseObject valueForKey:@"answer"],
                                                 @"hint": [responseObject valueForKey:@"hint"],
                                                 @"challenge_id": [responseObject valueForKey:@"challenge_id"],
                                                 @"sender": [responseObject valueForKeyPath:@"sender.username"]};
                        
                        Challenge *ch = [self GetOrCreateChallengeWithParams:params
                                      inManagedObjectContext:context
                                                  skipCreate:NO];
                        if (ch){
                            ch = nil;
                        }
                    }
                }
                failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [client stopNetworkActivity];
                    NSLog(@"failure fetching challenge");
                } autoRetry:5];
}




+ (Challenge *) createTestChallengeWithUser:(User *)user
{
    NSError *error;
    Challenge *challenge = nil;
    challenge = [NSEntityDescription insertNewObjectForEntityForName:@"Challenge" inManagedObjectContext:user.managedObjectContext];
    challenge.fields_count = [NSNumber numberWithInt:1];
    challenge.selected_answer = @"cj";
    challenge.challenge_id = @"0001";
    challenge.sender = user;
    if (![challenge.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }

    
    return challenge;
}


@end
