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
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "FAImageView.h"
#import "UIFont+FontAwesome.h"
#import "JDStatusBarNotification.h"


@implementation User (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here

    self.timestamp = [NSDate date];
    self.phone_number = nil;
    
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
}

+ (NSString *)name
{
    return @"User";
}

- (BOOL)isFacebookUser
{
    return self.facebook_user ? YES:NO;
}

- (BOOL)isPrivate
{
    return self.private ? YES:NO;
}


- (void)getCorrectProfilePicWithImageView:(UIImageView *)iV
{
    if (self.facebook_user){
        NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small",self.facebook_id];
        NSURL * fbUrl = [NSURL URLWithString:fbString];
        [iV setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];

    }
    
    else{
        iV.image = nil;
        FAImageView *imageView2 = (FAImageView *)iV;
        [imageView2 setDefaultIconIdentifier:@"fa-user"];

    }
}

+ (BOOL)validPhoneNumber:(NSString *)number
{
    if (number == nil || [number length] < 2){
        return NO;
    }
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    NSRange inputRange = NSMakeRange(0, [number length]);
    NSArray *matches = [detector matchesInString:number options:0 range:inputRange];
    
    //if no matches
    if ([matches count] == 0){
        return NO;
    }
    
    // found match but need to check if it matched whole string
    NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
    if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length){
        // matched whole string
        return YES;
    }
    else{
        // it only matched partial string
        return NO;
    }
}

+ (BOOL)createContactsWithParams:(NSDictionary *)params
           inMangedObjectContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@",[params valueForKey:@"username"]];
    NSInteger gotUser = [self checkIfUserWithFetch:request
                                           context:context
                                             error:&error];
    if (gotUser){
        NSLog(@"cant create cause we have %@",[params valueForKey:@"username"]);
        return NO;
    }
    
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:context];
    user.username = [params valueForKey:@"username"];
    user.facebook_user = [params valueForKey:@"facebook_user"];
    user.facebook_id = [params valueForKey:@"facebook_id"];
    user.email = [params valueForKey:@"email"];
    user.private = [NSNumber numberWithBool:NO];
    user.super_user = [NSNumber numberWithBool:NO];
    user.is_friend = [NSNumber numberWithBool:YES];
    
    if (![user.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    return YES;

}

+ (User *)getUserWithUsername:(NSString *)username
                    inContext:(NSManagedObjectContext *)context
                        error:(NSError **)error
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[User name]];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@",username];
    
    NSArray *results = [context executeFetchRequest:request error:error];
    if (results){
        return [results firstObject];
    }
    else{
        NSLog(@"theres no user %@ created",username);
        return nil;
    }

}


+ (User *)GetOrCreateUserWithParams:(NSDictionary *)params
             inManagedObjectContext:(NSManagedObjectContext *)context
                         skipCreate:(BOOL)skip

{
    NSParameterAssert(context);
    NSAssert([params objectForKey:@"username"], @"username required");

    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[User name]];
    request.predicate = [NSPredicate predicateWithFormat:@"(super_user = 1) and (username = %@)",[params valueForKey:@"username"]];
    request.fetchLimit = 1;
    
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
    
    User *user = nil;
    if (!skip){
        // else create a user, save, and return user (register)
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.username = [params valueForKey:@"username"];
        user.facebook_user = [params valueForKey:@"facebook_user"];
        user.private = [params valueForKey:@"privacy"];
        user.email = [params valueForKey:@"email"];
        user.super_user = [NSNumber numberWithBool:YES];
        user.facebook_id = [params valueForKey:@"fbook_id"];
        user.is_friend = [NSNumber numberWithBool:NO];
        //user.timestamp = [params valueForKey:@"timestamp"];
        
           if (![user.managedObjectContext save:&error]){
               NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
               abort();

        }
        
        NSAssert([user isKindOfClass:[User class]], @"Didnt return a core data user");
    }
    return user;
}


+ (User *)getUserWithFetch:(NSFetchRequest *)fetch
                   context:(NSManagedObjectContext *)context
                     error:(NSError **)error
{
    NSParameterAssert(fetch);
    NSParameterAssert(context);
    NSArray *results = [context executeFetchRequest:fetch error:error];
    return [results firstObject];
    
}


+ (NSInteger)checkIfUserWithFetch:(NSFetchRequest *)fetch
                          context:(NSManagedObjectContext *)context
                            error:(NSError **)error
{
    NSParameterAssert(fetch);
    NSParameterAssert(context);
    NSInteger getUser = 0;
    getUser = [context countForFetchRequest:fetch error:error];
    return getUser;
}


+ (NSURLSessionDataTask *)loginWithUsernameAndPassword:(NSDictionary *)params
                                              callback:(AwesomeAPICompleteBlock)block
{
    NSAssert([params count] == 2, @"2 parameters not being passed. Dict passed was %@",params);
    
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPILoginUrlString
                          parameters:params
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                  [client stopNetworkActivity];
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
                                     BOOL facebook_user = [[responseObject valueForKey:@"facebook_user"]boolValue];
                                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                     [defaults setValue:username forKey:@"username"];
                                     [defaults setBool:YES forKey:@"logged"];
                                     [defaults setBool:facebook_user forKey:@"facebook_user"];
                                     [defaults setValue:[responseObject valueForKey:@"api_key"] forKey:@"api_key"];
                                     if ([user.username isEqualToString:username]){
                                           [defaults setURL:user.objectID.URIRepresentation forKey:@"superuser"];
                                     }else{
                                         user = [self GetOrCreateUserWithParams:@{@"username": username}
                                                         inManagedObjectContext:context
                                                                     skipCreate:YES];
                                         NSLog(@"%@",user.username);
                                         [defaults setURL:user.objectID.URIRepresentation forKey:@"superuser"];

                                     }
                                    
                                     [defaults synchronize];
                                     
                                     if (block){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             block(YES,context, user, NO);
                                         });
                                     }}
                                 // things did not go well because of user
                                 if ([[responseObject valueForKey:@"code"] intValue] == -1){
                                     if (block){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             block(NO,responseObject, nil,NO);
                                         });
                                     }
                                 }
                                 // things did not go well because of me
                                 if ([[responseObject valueForKey:@"code"] intValue] == -10){
                                     if (block){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             block(NO,responseObject, nil, NO);
                                         });
                                     }
                                 }
                                 
                             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  [client stopNetworkActivity];
                                 // something very unexpected happened
                                 if (block){
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         block(NO,error,nil,YES);
                                         [JDStatusBarNotification showWithStatus:error.localizedDescription
                                                                    dismissAfter:2.0
                                                                       styleName:JDStatusBarStyleError];

                                     });
                                 }
                                 
                             }];
}


+ (NSURLSessionDataTask *)registerWithParams:(NSDictionary *)params
                                    callback:(AwesomeAPICompleteBlock)block;
{
    NSParameterAssert(params);
    NSAssert([params count] == 4, @"4 parameters not being passed. Dict passed was %@",params);
    
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPIRegisterUrlString
                          parameters:params
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                  [client stopNetworkActivity];
                                  // things went well
                                 if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                     // get params from response
                                     NSString *username = [responseObject valueForKeyPath:@"username"];
                                     NSString *email = [responseObject valueForKeyPath:@"user.email"];
                                     NSString *phone_number = [responseObject valueForKeyPath:@"phone_number"];
                                     NSNumber *score = [NSNumber numberWithInt:[[responseObject valueForKey:@"score"]intValue]];
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
                                                                @"timestamp":date,
                                                                @"email":email,
                                                                @"phone_number":phone_number};
                                     
                                     User *user = nil;
                                     if (context){
                                         user = [self GetOrCreateUserWithParams:gcParams
                                                         inManagedObjectContext:context
                                                                     skipCreate:NO];
                                     }

                                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                     [defaults setValue:username forKey:@"username"];
                                     [defaults setBool:YES forKey:@"logged"];
                                     [defaults setURL:user.objectID.URIRepresentation forKey:@"superuser"];
                                     [defaults setValue:[responseObject valueForKey:@"api_key"] forKey:@"api_key"];
                                     
                                     NSString *apiString = [NSString stringWithFormat:@"ApiKey %@:%@",username,[responseObject valueForKey:@"api_key"]];
                                     [defaults setValue:apiString forKey:@"apiString"];

                                     [defaults synchronize];
                                     
                                     if (block){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             block(YES,context,user ,NO);
                                         });
                                     }

                                     
                                 }
                                 
                                 // things did not go well because of user
                                 if ([[responseObject valueForKey:@"code"] intValue] == -1){
                                     if (block){
                                         dispatch_async(dispatch_get_main_queue(), ^{

                                             block(NO,responseObject, nil, NO);
                                         });
                                     }
                                 }
                                 
                                 // things did not go well because of me
                                 if ([[responseObject valueForKey:@"code"] intValue] == -10){
                                     if (block){
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             block(NO,responseObject, nil, NO);
                                         });
                                     }
                                 }
                             }
                             failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  [client stopNetworkActivity];
                                 // something very unexpected happened
                                 if (block){
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         block(NO,error, nil, YES);
                                         [JDStatusBarNotification showWithStatus:error.localizedDescription
                                                                    dismissAfter:2.0
                                                                       styleName:JDStatusBarStyleError];

                                     });
                                 }

                             }];
  }

+ (NSURLSessionDataTask *)registerFacebookWithParams:(NSDictionary *)params
                                            callback:(AwesomeAPICompleteBlock)block;
{
    NSAssert([params count] == 7, @"7 parameters not being passed. Dict sent was %@",params);
    
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPIFacebookUrlString
                                      parameters:params
                                         success:^(NSURLSessionDataTask *task, id responseObject) {
                                              [client stopNetworkActivity];
                                             NSLog(@"%@",responseObject);
                                             // things went well
                                             if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                                 NSString *username = [responseObject valueForKeyPath:@"user.username"];
                                                 NSString *email = [responseObject valueForKeyPath:@"user.email"];
                                                 NSString *phone_number = [responseObject valueForKeyPath:@"phone_number"];
                                                 NSNumber *score = [NSNumber numberWithInt:[[responseObject valueForKey:@"score"]intValue]];
                                                 NSNumber *facebook = [NSNumber numberWithBool:[[responseObject valueForKey:@"facebook_user"] boolValue]];
                                                 NSNumber *privacy = [NSNumber numberWithInt:0];
                                                 NSNumber *super_user = [NSNumber numberWithInt:1]; //is a super user
                                                 NSNumber *facebook_id = [NSNumber numberWithInt:[[responseObject valueForKey:@"facebook_id"] intValue]];
                                                 // prepare to get or create a user
                                                 NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                                                 NSDictionary *gcParams = @{@"username": username,
                                                                            @"score": score,
                                                                            @"facebook_user":facebook,
                                                                            @"privacy":privacy,
                                                                            @"super_user":super_user,
                                                                            @"fbook_id":facebook_id,
                                                                            @"email":email,
                                                                            @"phone_number":phone_number};
                                                 User *user = nil;
                                                 if (context){
                                                      user = [self GetOrCreateUserWithParams:gcParams
                                                                      inManagedObjectContext:context
                                                                                  skipCreate:NO];
                                                 }
            
                                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                 [defaults setValue:username forKey:@"username"];
                                                 [defaults setBool:YES forKey:@"logged"];
                                                 [defaults setBool:YES forKey:@"facebook_user"];
                                                 [defaults setValue:[responseObject valueForKey:@"api_key"] forKey:@"api_key"];
                                                 
                                                 NSString *apiString = [NSString stringWithFormat:@"ApiKey %@:%@",username,[responseObject valueForKey:@"api_key"]];

                                                 [defaults setValue:apiString forKey:@"apiString"];
                                                 [defaults setURL:user.objectID.URIRepresentation forKey:@"superuser"];
                                                 [defaults setBool:YES forKey:@"fbServerSuccess"];
                                                 
                                                 if (facebook){
                                                     [defaults setBool:YES forKey:@"facebook_user"];
                                                 }
                                                 [defaults synchronize];
                                                 if (block){
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         block(YES,context,user ,NO);
                                                     });
                                                 }

                                                 
                                             }
                                             
                                             // things did not go well because of user
                                             if ([[responseObject valueForKey:@"code"] intValue] == -1){
                                                  NSLog(@" not success");
                                                 if (block){
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         block(NO,responseObject, nil, NO);
                                                     });
                                                 }
                                                 
                                             }
                                             // things did not go well because of me
                                             if ([[responseObject valueForKey:@"code"] intValue] == -10){
                                                  NSLog(@"not me success");
                                                 if (block){
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         block(NO,responseObject, nil, NO);
                                                     });
                                                 }
                                             }


                                             
                                         }
                                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                                              [client stopNetworkActivity];
                                             // something very unexpected happened
                                             if (block){
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     block(NO,error, nil, YES);
                                                     [JDStatusBarNotification showWithStatus:error.localizedDescription
                                                                                dismissAfter:2.0
                                                                                   styleName:JDStatusBarStyleError];

                                                 });
                                             }

                                        }];
}

+ (void)getFacebookPicWithUser:(User *)user
                     imageview:(UIImageView *)iv
{
    //NSParameterAssert(user);
    NSParameterAssert(iv);
    
    // sizes are small, large, and
    NSString *picUrlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",user.facebook_id];
    NSURL *picURLData = [NSURL URLWithString:picUrlString];
    [iv setImageWithURL:picURLData
       placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
    
     
}


+ (void)updateDeviceTokenWithParams:(NSDictionary *)params
                           callback:(DeviceTokenSendBlock)block
{
    NSAssert([params objectForKey:@"username"], @"need username to update device token");
    NSAssert([params objectForKey:@"action"], @"need action to update device token");
    NSAssert([params objectForKey:@"content"], @"need content to update device token");
    
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    if ([client connected]){
        [client startNetworkActivity];
        [client POST:AwesomeAPISettingsString parameters:params
             success:^(NSURLSessionDataTask *task, id responseObject){
                 [client stopNetworkActivity];
                 if ([[responseObject valueForKey:@"code"]intValue] == 1){
                     if (block){
                         block(YES);
                     }
                 }
                 else{
                     if (block){
                         block(NO);
                     }
                 }
             }
             failure:^(NSURLSessionDataTask *task, NSError *error) {
                 [client stopNetworkActivity];
                 if (block){
                     block(NO);
                 }
                 
             }
           autoRetry:3];
    }
    else{
        [JDStatusBarNotification showWithStatus:@"No internet connection detected"
                                   dismissAfter:2.0
                                      styleName:JDStatusBarStyleError];

    }

}

+ (NSArray *)fetchFriendsInContext:(NSManagedObjectContext *)context
                       getContacts:(BOOL)contacts
{
    NSFetchRequest *firstRequest;
    if (contacts){
        NSString *contactFriendsFilter = @"(super_user = 0) and (is_friend = 1) and (facebook_user = 0)";
        
        firstRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        firstRequest.predicate = [NSPredicate predicateWithFormat:contactFriendsFilter];
    }
    else{
        NSString *contactFriendsFilter = @"(super_user = 0) and (is_friend = 1) and (facebook_user = 1)";
        
        firstRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        firstRequest.predicate = [NSPredicate predicateWithFormat:contactFriendsFilter];

    }
    
     NSError *error;

    
    return [context executeFetchRequest:firstRequest error:&error];
    
}


+ (void)fetchUserBlobWithParams:(NSDictionary *)params
                          block:(BlobFetchBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    BOOL busy = [AwesomeAPICLient requestInProgress:client];
    if (! busy){
        [client startNetworkActivity];
        [client POST:AwesomeAPIFetchString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [client stopNetworkActivity];
            int code = [[responseObject valueForKey:@"code"] intValue];
            if (code == 1){
                NSLog(@"success");
                if (block){
                    block(YES,responseObject,@"success");
                }
            }
            
            else if (code == -10){
                NSLog(@"success but not quite");
                if (block){
                    block(NO,nil,[responseObject valueForKey:@"message"]);
                }
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            if (block){
                block(NO,nil,error.localizedDescription);
                [JDStatusBarNotification showWithStatus:error.localizedDescription
                                           dismissAfter:2.0
                                              styleName:JDStatusBarStyleError];

            }
        }];
    }
    
}

+ (void)fetchMediaBlobWithParams:(NSDictionary *)params
                          block:(BlobFetchBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    BOOL busy = [AwesomeAPICLient requestInProgress:client];
    if (!busy){
        [client startNetworkActivity];
        [client POST:AwesomeAPIChallengeMediaString parameters:params
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 [client stopNetworkActivity];
                 int code = [[responseObject valueForKey:@"code"] intValue];
                 if (code == 1){
                     NSLog(@"success");
                     if (block){
                         block(YES,responseObject,@"success");
                     }
                 }
                 else if (code == -10){
                     NSLog(@"success but not really");
                     if (block){
                         block(NO,nil,[responseObject valueForKey:@"message"]);
                     }
                 }
                 
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [client stopNetworkActivity];
            if (block){
                block(NO,nil,error.localizedDescription);
                [JDStatusBarNotification showWithStatus:error.localizedDescription
                                           dismissAfter:2.0
                                              styleName:JDStatusBarStyleError];
            }
        }];
    }
}


+ (void)sendProfileUpdatewithParams:(NSDictionary *)params
                              block:(BlobFetchBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    [client POST:AwesomeAPISettingsString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             int code = [[responseObject valueForKey:@"code"] intValue];
             
             if (code == 1){
                 NSDictionary *data = @{@"username": responseObject[@"username"],
                                        @"email":responseObject[@"email"],
                                        @"phone":responseObject[@"phone"],
                                        @"changes":responseObject[@"changes"]};
                 if (block){
                     block(YES,data,@"Success");
                 }
             }
             
             if (code == -1){
                 if (block){
                     block(NO,nil,responseObject[@"message"]);
                 }
             }
      
        }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             if (block){
                 block(NO,nil,error.localizedDescription);
             }
      
        }];

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
