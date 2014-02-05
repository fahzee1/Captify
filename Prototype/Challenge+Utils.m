//
//  Challenge+Utils.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "Challenge+Utils.h"
#import "AwesomeAPICLient.h"

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
                       inManagedObjectContext:(NSManagedObjectContext *)context;
{
    NSParameterAssert(context);
    NSAssert([params objectForKey:@"challenge_id"], @"challenge id required");
    NSAssert([params objectForKey:@"username"], @"username required");
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Challenge"];
    request.predicate = [NSPredicate predicateWithFormat:@"(challenge_id = %@) and (sender.username = %@)",[params valueForKey:@"challenge_id"],[params valueForKey:@"username"]];
    
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
    
    // get user
    User *user = nil;
    NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
    if (uri){
        NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
        user = (id) [context existingObjectWithID:superuserID error:&error];
    }
    
    // no challenge create one
    Challenge *challenge = [NSEntityDescription insertNewObjectForEntityForName:@"Challenge" inManagedObjectContext:context];
    challenge.type = [params valueForKey:@"level"];
    challenge.answer = [params valueForKey:@"answer"];
    challenge.hint = [params valueForKey:@"hint"];
    challenge.challenge_id = [params valueForKey:@"challenge_id"];
    challenge.sender = [params valueForKey:@"theUser"];
    if (![challenge.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();

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
                        //challenge.active = [NSNumber numberWithBool:NO];
                    }
                    
                    if (code == -10){
                        // 500 issue on our end
                        NSLog(@"we're not all good here");
                        challenge.active = [NSNumber numberWithBool:YES];
                    }
                    
                }
                failure:^(NSURLSessionDataTask *task, NSError *error) {
                    //something bad happened
                    // find ways to handle this. maybe set it for retry
                    [client stopNetworkActivity];
                    NSLog(@"definitely not all good here");
                    challenge.active = [NSNumber numberWithBool:YES];

                }];
    
    NSError *error;
    if ([challenge.managedObjectContext hasChanges]){
        if(![challenge.managedObjectContext save:&error]){
            NSLog(@"error saving active status of challenge");
        }
    }
}

@end
