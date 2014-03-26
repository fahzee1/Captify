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


+ (NSString *)name
{
    return @"Challenge";
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
        NSAssert([params valueForKey:@"original_phrase"], @"must supply 'original answer' when creating challenge");
        
        NSDictionary *smallParams = @{@"username": [params valueForKey:@"sender"]};
        User *user = [User GetOrCreateUserWithParams:smallParams
                              inManagedObjectContext:context
                                          skipCreate:YES];
        // no challenge create one
        challenge = [NSEntityDescription insertNewObjectForEntityForName:@"Challenge" inManagedObjectContext:context];

        challenge.sender = user;
        challenge.challenge_id = [self createChallengeIDWithUser:[params valueForKey:@"sender"]];
        challenge.active = [NSNumber numberWithBool:YES];
        if (![challenge.managedObjectContext save:&error]){
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            [Challenge showAlertWithTitle:@"Error" message:@"There was an unrecoverable error, the application will shut down now"];
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
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
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


+ (NSArray *)getHistoryChallengesInContext:(NSManagedObjectContext *)context
                                      sent:(BOOL)sent
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Challenge"];
    
    if (sent){
    request.predicate = [NSPredicate predicateWithFormat:@"(sender.super_user = 1) && (sender.username = %@)",[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
    }
    else{
        request.predicate = [NSPredicate predicateWithFormat:@"(sender.super_user != 1) && (sender.is_friend = 1)"];
    }
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    request.sortDescriptors = @[sortByDate];
    
    
    return [context executeFetchRequest:request error:&error];
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
    if ([client connected]){
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
    else{
        [Challenge showAlertWithTitle:@"Error" message:@"No internet connection detected"];
    }
}

+ (NSURLSessionDataTask *)fetchChallengeWithUsernameAndID:(NSDictionary *)params
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    if ([client connected]){
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
    else{
        [Challenge showAlertWithTitle:@"Error" message:@"No internet connection detected"];
        return nil;
    }
}




+ (Challenge *) createTestChallengeWithUser:(User *)user
{
    NSError *error;
    Challenge *challenge = nil;
    challenge = [NSEntityDescription insertNewObjectForEntityForName:@"Challenge" inManagedObjectContext:user.managedObjectContext];
    challenge.challenge_id = @"0002";
    challenge.sender = user;
    challenge.recipients_count = @25;
    challenge.name = @"make her go bananas...hanna!";
    challenge.active = [NSNumber numberWithBool:YES];
    if (![challenge.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }

    
    return challenge;
}


+ (Challenge *)createChallengeWithRecipientsWithParams:(NSDictionary *)params
{
    NSAssert([params valueForKey:@"sender"], @"Must include sender");
    NSAssert([params valueForKey:@"context"], @"Must include context");
    NSAssert([params valueForKey:@"recipients"], @"Must include recipients");
    NSAssert([params valueForKey:@"recipients_count"], @"Must include recipients_count");
    NSAssert([params valueForKey:@"challenge_name"], @"Must include name for challenge");
    
    
    
    Challenge *challenge;
    NSError *error;
    User *user = [User getUserWithUsername:[params valueForKey:@"sender"] inContext:[params valueForKey:@"context"] error:&error];
    // check if exists first
                  
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Challenge name]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",[params valueForKey:@"challenge_name"]];
    int exist = [user.managedObjectContext countForFetchRequest:request error:&error];
    if (exist == 0){
        if (user){
            challenge = [NSEntityDescription insertNewObjectForEntityForName:[Challenge name] inManagedObjectContext:user.managedObjectContext];
            
            challenge.name = [params valueForKey:@"challenge_name"];
            challenge.sender = user;
            challenge.recipients_count = [params valueForKey:@"recipients_count"];
            challenge.challenge_id = [params valueForKey:@"challenge_id"];
            
            NSNumber *active = [params valueForKey:@"active"];
            challenge.active = active ? active : [NSNumber numberWithBool:YES];

            
            for (NSString *friend in [params valueForKey:@"recipients"]){
                User *uFriend = [User getUserWithUsername:friend inContext:user.managedObjectContext error:&error];
                if (uFriend && uFriend.is_friend && !uFriend.super_user){
                    [challenge addRecipientsObject:uFriend];
                }
            }
            
            
            NSError *error;
            if (![challenge.managedObjectContext save:&error]){
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [Challenge showAlertWithTitle:@"Error" message:@"There was an unrecoverable error, the application will shut down now"];

                abort();
                
            }
        }
        else{
            NSLog(@"user %@ hasnt been created, so challenge not created",[params valueForKey:@"sender"]);
        }
    }
    else{
        NSLog(@"'%@' is already created",[params valueForKey:@"challenge_name"]);
    }

    
    return challenge;
}


+ (NSURLSessionDataTask *)sendCreateChallengeRequest:(NSDictionary *)params
                                               image:(NSData *)image
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    if ([client connected]){
    [client startNetworkActivity];
    return [client POST:AwesomeAPIChallengeCreateString
             parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 
                 NSString *filename = @"test.jpg";
                 NSString *name = @"test";
                 [formData appendPartWithFileData:image name:name fileName:filename mimeType:@"image/jpeg"];
                  
                 
             } success:^(NSURLSessionDataTask *task, id responseObject) {
                 [client stopNetworkActivity];
                 int code = [[responseObject valueForKey:@"code"] intValue];
                 if (code == 1){
                     NSLog(@"success uploading");
                 }
                 else{
                     NSLog(@"no success uploading");
                 }
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 [client stopNetworkActivity];
                 NSLog(@"error %@",error);
             }];
    }
    else{
        [Challenge showAlertWithTitle:@"Error" message:@"No internet connection detected"];
        return nil;
    }
    
}





+ (void)saveImage:(UIImage *)image
         filename:(NSString *)name
{
    // filename can be /test/another/test.jpg
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
        NSData* data = UIImageJPEGRepresentation(image, 0.9);
        [data writeToFile:path atomically:YES];
    }
}


+ (UIImage *)loadImagewithFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}


+ (NSString *)createChallengeIDWithUser:(NSString *)user
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [NSString stringWithFormat:@"%@-%@",user,uuid];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    UIAlertView *a = [[UIAlertView alloc]
                      initWithTitle:title
                      message:message
                      delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    [a show];
}

@end
