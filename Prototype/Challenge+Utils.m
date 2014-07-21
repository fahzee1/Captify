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
#import "JDStatusBarNotification.h"
#import "NSData+Format.h"


@implementation Challenge (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.timestamp = [NSDate date];
    self.success = [NSNumber numberWithBool:NO];
    self.active = [NSNumber numberWithBool:YES];
    self.sentPick = [NSNumber numberWithBool:NO];
    self.shared = [NSNumber numberWithBool:NO];
    self.first_open = [NSNumber numberWithInt:1];
    self.chose_own_caption = [NSNumber numberWithBool:NO];
    self.final_fetch = [NSNumber numberWithBool:NO];
    

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


+ (NSString *)fetchedHistoryKey
{
    return @"lastChallengeFetch";
}


+ (NSString *)baseUrl
{
    return [[AwesomeAPICLient sharedClient].baseURL absoluteString];
}

+ (NSString *)dateStringFromDate:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                                    dateStyle:NSDateFormatterLongStyle
                                                    timeStyle:NSDateFormatterShortStyle];
}

+ (Challenge *)GetOrCreateChallengeWithParams:(NSDictionary *)params
                       inManagedObjectContext:(NSManagedObjectContext *)context
                                   skipCreate:(BOOL)skip
{
    NSParameterAssert(context);
    NSAssert([params objectForKey:@"challenge_id"], @"challenge id required");
    NSAssert([params objectForKey:@"username"] || [params objectForKey:@"sender"], @"username required");
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Challenge name]];
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
        User *user = [User getOrCreateUserWithParams:smallParams
                              inManagedObjectContext:context
                                          skipCreate:YES];
        // no challenge create one
        challenge = [NSEntityDescription insertNewObjectForEntityForName:@"Challenge" inManagedObjectContext:context];

        challenge.sender = user;
        challenge.challenge_id = [self createChallengeIDWithUser:[params valueForKey:@"sender"]];
        challenge.active = [NSNumber numberWithBool:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *e;
            if (![challenge.managedObjectContext save:&e]){
                DLog(@"Unresolved error %@, %@", error, [error userInfo]);
                
                [Challenge showAlertWithTitle:@"Error" message:@"There was an unrecoverable error, the application will shut down now"];
                abort();
                
            }

        });
    }

    return  challenge;

}


+ (Challenge *)getChallengeWithID:(NSString *)challenge_id
                        inContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Challenge name]];
    request.predicate = [NSPredicate predicateWithFormat:@"challenge_id = %@",challenge_id];
    request.fetchLimit = 1;
    
    NSArray *challenges = [context executeFetchRequest:request error:&error];
    if (! challenges){
        DLog(@"%@",error);
        return nil;
    }
    
    return [challenges firstObject];
   
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
    
    DLog(@"%@",returnAll);
    return returnAll;

}


+ (NSArray *)getHistoryChallengesForUser:(User *)user
                                    sent:(BOOL)sent
{
    /*
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self name]];
    
    
    if (sent){
    request.predicate = [NSPredicate predicateWithFormat:@"(sender.super_user = 1) && (sender.username = %@)",user.username];
    }
    else{
        request.predicate = [NSPredicate predicateWithFormat:@"(sender.super_user != 1) && (sender.username != %@) && (recipients CONTAINS %@)",user.username, user];
    }
     */
    
   
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    
    if (sent){
        return [user.sent_challenges.allObjects sortedArrayUsingDescriptors:@[sortByDate]];
    }
    else{
        return [user.recipient_challenges.allObjects sortedArrayUsingDescriptors:@[sortByDate]];
    }
    

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
                        DLog(@"%@",responseObject);
                        int code = [[responseObject valueForKey:@"code"] intValue];
                        if (code == 1){
                            // we're good
                            DLog(@"we're all good here");
                            challenge.sync_status = [NSNumber numberWithBool:NO];
                        }
                        
                        if (code == -10){
                            // 500 issue on our end
                            DLog(@"we're not all good here");
                            challenge.sync_status = [NSNumber numberWithBool:YES];
                        }
                        
                    }
                    failure:^(NSURLSessionDataTask *task, NSError *error) {
                        //something bad happened
                        // find ways to handle this. maybe set it for retry
                        [client stopNetworkActivity];
                        DLog(@"definitely not all good here");
                        challenge.sync_status = [NSNumber numberWithBool:YES];
                        [JDStatusBarNotification showWithStatus:error.localizedDescription
                                                   dismissAfter:2.0
                                                      styleName:JDStatusBarStyleError];
                        if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                            [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
                        }


                        

                    } autoRetry:5];
        
        NSError *error;
        if ([challenge.managedObjectContext hasChanges]){
            if(![challenge.managedObjectContext save:&error]){
                DLog(@"error saving active status of challenge");
            }
        }
    }
    else{
        [Challenge showAlertWithTitle:@"Error" message:@"No internet connection detected"];
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
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }

    
    return challenge;
}


+ (Challenge *)createChallengeWithRecipientsWithParams:(NSDictionary *)params
{
    NSAssert([params valueForKey:@"sender"], @"Must include sender");
    NSAssert([params valueForKey:@"context"], @"Must include context");
    //NSAssert([params valueForKey:@"recipients"], @"Must include recipients");
    NSAssert([params valueForKey:@"recipients_count"], @"Must include recipients_count");
    NSAssert([params valueForKey:@"challenge_name"], @"Must include name for challenge");
    NSAssert([params valueForKey:@"active"], @"Must include active to create challenge");
    NSAssert([params valueForKey:@"sent"], @"Must include sent to create challenge");

    static int retrys = 0;
    Challenge *challenge;
    NSError *error;
    id sender = [NSString stringWithFormat:@"%@",[params valueForKey:@"sender"]];
    if ([sender isKindOfClass:[NSArray class]]){
        sender = sender[0][@"username"];
    }
    
    User *user = [User getUserWithUsername:sender inContext:[params valueForKey:@"context"] error:&error];
    // check if exists first
    AppDelegate *delegate = [[AppDelegate alloc] init];
    User *myUser = delegate.myUser;
    
    NSNumber *sent = params[@"sent"];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Challenge name]];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",[params valueForKey:@"challenge_name"]];
    NSUInteger exist = [user.managedObjectContext countForFetchRequest:request error:&error];
    
    if (exist == 0){
        if (user){
            challenge = [NSEntityDescription insertNewObjectForEntityForName:[Challenge name] inManagedObjectContext:user.managedObjectContext];
            
            challenge.name = [params valueForKey:@"challenge_name"];
            challenge.sender = user;
            challenge.recipients_count = [params valueForKey:@"recipients_count"];
            challenge.challenge_id = [params valueForKey:@"challenge_id"];
            if ([params valueForKey:@"created"]){
                challenge.timestamp = [params valueForKey:@"created"];
            }
            
            NSString *media_url = [params valueForKey:@"media_url"];
            NSString *local_url = [params valueForKey:@"local_media_url"];
            id active = [params valueForKey:@"active"];
            if ([active isKindOfClass:[NSString class]]){
                if ([active isEqualToString:@"True"]){
                    active = [NSNumber numberWithBool:YES];
                }
                else{
                    active = [NSNumber numberWithBool:NO];
                }
            }
            
            @try {
                if (![media_url isKindOfClass:[NSNull class]]){
                    challenge.image_path = media_url;
                }
                else{
                    challenge.image_path = @"";
                }
                
                if (![local_url isKindOfClass:[NSNull class]]){
                    challenge.local_image_path = local_url;
                }
                else{
                    challenge.local_image_path = @"";
                }
                challenge.active = active; //active ? active : [NSNumber numberWithBool:YES];
                
                
                /*
                for (NSString *friend in [params valueForKey:@"recipients"]){
                    User *uFriend = [User getUserWithUsername:friend inContext:user.managedObjectContext error:&error];
                    if (uFriend){
                        [challenge addRecipientsObject:uFriend];
                    }
                    else{
                         DLog(@"%@ is either not there, not afriend, or a super user",friend);
                    }
                    
                 
                    if (uFriend && uFriend.is_friend && !uFriend.super_user){
                        [challenge addRecipientsObject:uFriend];
                    }
                    else{
                        DLog(@"%@ is either not there, not afriend, or a super user",friend);
                        
                    }
                 
                }
            */
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error;
                    if ([challenge.recipients count] > 0){
                        if (![challenge.managedObjectContext save:&error]){
                            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            [Challenge showAlertWithTitle:@"Error" message:@"There was an unrecoverable error, the application will shut down now"];
                            
                            abort();
                            
                        }
                        
                    }
                    
                });



            }
            @catch (NSException *exception) {
                DLog(@"%@",exception);
            }
                        
            
        }
        // no user
        else{
            DLog(@"user %@ hasnt been created, so creating now",sender);
            
            if (retrys < 4){
                retrys += 1;
                
                
                NSMutableDictionary *params2 = [@{@"username":sender} mutableCopy];
                
                if (params[@"facebook_id"]){
                        params2[@"facebook_id"] = params[@"facebook_id"];
                        params2[@"facebook_user"] = params[@"facebook_user"];
                }
                
                User *newUser =[User createFriendWithParams:params2
                                      inMangedObjectContext:[params valueForKey:@"context"]];
                if (newUser){
                    [self createChallengeWithRecipientsWithParams:params];
                }
                
            }
        }

    }
    else{
        // fetch
        challenge = [self getChallengeWithID:[params valueForKey:@"challenge_id"] inContext:[params valueForKey:@"context"]];
        id active = [params valueForKey:@"active"];
        if ([active isKindOfClass:[NSString class]]){
            if ([active isEqualToString:@"True"]){
                active = [NSNumber numberWithBool:YES];
            }
            else{
                active = [NSNumber numberWithBool:NO];
            }
        }

        challenge.active = active;
        
        if (![challenge.recipients containsObject:myUser]){
            if ([sent intValue] == 0){
                [challenge addRecipientsObject:myUser];
            }
        }
    
        if (![challenge.managedObjectContext save:&error]){
            DLog(@"%@",error);
        }
        
        return challenge;
    }
    
    if (![challenge.recipients containsObject:myUser]){
        if ([sent intValue] == 0){
            [challenge addRecipientsObject:myUser];
            if (![challenge.managedObjectContext save:&error]){
                DLog(@"%@",error);
            }
        }

    }
    

    return challenge;
}


/*
+ (void)scheduleLocalNotifForChallenge:(Challenge *)challenge
{
    if ([challenge.active intValue] == 1){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        //notification.fireDate = [[NSDate date] dateByAddingTimeInterval:60*60*12];
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:60];
        notification.alertBody = [NSString stringWithFormat:@"Don't forget to send your caption for \"%@\"!",challenge.name];
        NSDictionary *payload = @{@"id": challenge.challenge_id};
        notification.userInfo = payload;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    
}
 */

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
                     DLog(@"success uploading");
                 }
                 else{
                     DLog(@"no success uploading");
                 }
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 [client stopNetworkActivity];
                 [JDStatusBarNotification showWithStatus:error.localizedDescription
                                            dismissAfter:2.0
                                               styleName:JDStatusBarStyleError];
                 if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                     [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
                 }


                 DLog(@"error %@",error);
             }];
    }
    else{
        [Challenge showAlertWithTitle:@"Error" message:@"No internet connection detected"];
        return nil;
    }
    
}
+ (void)deleteChallengeWithParams:(NSDictionary *)params
                            block:(DeleteChallengeBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    [client POST:AwesomeAPIChallengeDeleteString
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             int code = [[responseObject valueForKey:@"code"] intValue];
             if (code == 1){
                 if (block){
                     block(YES);
                 }
             }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [client stopNetworkActivity];
        [JDStatusBarNotification showWithStatus:error.localizedDescription
                                   dismissAfter:2.0
                                      styleName:JDStatusBarStyleError];
        if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
            [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
        }
        
        
        DLog(@"%@",error);
        if (block){
            block(NO);
        }

    }];
    
}

+ (void)updateChallengeWithParams:(NSDictionary *)params
                                block:(ChallengeUpdateBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    [client POST:AwesomeAPIChallengeUpdateString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             int code = [[responseObject valueForKey:@"code"] intValue];
             if (code == 1){
                 if (block){
                     NSString *url;
                     if (responseObject[@"media_url"]){
                         url = responseObject[@"media_url"];
                     }
                     block(YES, url);
                 }
             }
             
             if (code == -10){
                 DLog(@"%@",[responseObject valueForKey:@"message"]);
                 if (block){
                     block(NO,nil);
                 }
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             [JDStatusBarNotification showWithStatus:error.localizedDescription
                                        dismissAfter:2.0
                                           styleName:JDStatusBarStyleError];
             if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                 [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
             }


             DLog(@"%@",error);
             if (block){
                 block(NO, nil);
             }
       }];
}



+ (void)sendCreateChallengeRequestWithParams:(NSDictionary *)params
                                       block:(SendChallengeRequestBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    [client POST:AwesomeAPIChallengeCreateString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             /*
             NSString *media = responseObject[@"media"];
             // response is tastypie api automatic response
             // so just check if the media string was passed
             
             if (media){
                 if (block){
                     block(YES,NO,@"Success",responseObject);
                 }
             }
             else{
                 if (block){
                     block(NO,NO,@"Fail",nil);
                 }
             }
              */
             
             if (block){
                 block(YES,NO,@"Success",responseObject);
             }
        
        }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             [JDStatusBarNotification showWithStatus:error.localizedDescription
                                        dismissAfter:2.0
                                           styleName:JDStatusBarStyleError];
             if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                 [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
             }

             if (block){
                 block(NO,YES,error.localizedDescription,nil);
             }

        
      }];
}

+ (void)getCurrentChallengeFeedWithBlock:(GetChallengeFeedBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    [client GET:AwesomeAPIChallengeFeedString parameters:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            DLog(@"%@",responseObject);
            
            int code = [responseObject[@"code"]intValue];
            
            if (code == 1){
                if (block){
                    block(YES,responseObject);
                }
            }
            
            else if (code == -10){
                if (block){
                     NSString *message;
                    if (responseObject[@"message"]){
                        message = responseObject[@"message"];
                    }
                    block(NO,message);
                }
            }
        
        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
              [client stopNetworkActivity];
            [JDStatusBarNotification showWithStatus:error.localizedDescription
                                       dismissAfter:2.0
                                          styleName:JDStatusBarStyleError];
            if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
            }
            
            if (block){
                block(NO,nil);
            }

        }];

}


+ (NSString *)saveImage:(NSData *)image
               filename:(NSString *)name
{
    // filename can be /test/another/test.jpg
    if (image != nil)
    {
        NSError *e;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *challengeDirectory = [documentsDirectory stringByAppendingPathComponent:@"challenges"];
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:challengeDirectory withIntermediateDirectories:YES attributes:nil error:&e]){
            DLog(@"%@",e);
        }
        
        
        NSString* path = [challengeDirectory stringByAppendingPathComponent:name];
        if (![image writeToFile:path options:0 error:&e]){
            DLog(@"%@",e);
            
            return nil;
        }
        
        
        return path;
    }
    
    return nil;
}


+ (UIImage *)loadImagewithFileName:(NSString *)name
{
    return [UIImage imageWithContentsOfFile:name];
}




+ (NSString *)createChallengeIDWithUser:(NSString *)user
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSArray *uuidList = [uuid componentsSeparatedByString:@"-"];
    NSString *finalUuid = [uuidList lastObject];
    user = [user stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    return [NSString stringWithFormat:@"%@-%@",user,finalUuid];
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
