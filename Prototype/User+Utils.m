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
#import "SettingsViewController.h"
#import "UserProfileViewController.h"


@implementation User (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here

    self.timestamp = [NSDate date];
    self.phone_number = nil;
    self.is_deleted = [NSNumber numberWithBool:NO];
    
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

- (NSString *)displayName
{
    NSString *name = [[self.username stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    return name;
}

- (NSString *)firstName
{
 
    if ([self.facebook_user intValue] == 1){
        NSArray *splitName = [self.username componentsSeparatedByString:@"-"];
        return [splitName firstObject];
        
    }
    else if ([self.is_teamCaptify intValue] == 1){
        NSArray *splitName = [self.username componentsSeparatedByString:@"-"];
        return [splitName lastObject];
    }
    else{
        return self.username;
    }
}

- (NSString *)lastName
{
    if ([self.facebook_user intValue] == 1 || [self.is_teamCaptify intValue] == 1){
        NSArray *splitName = [self.username componentsSeparatedByString:@"-"];
        return [splitName lastObject];
        
    }
    else{
        return self.username;
    }

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
    if ([self.facebook_user intValue] == 1){
        NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",self.facebook_id];
        NSURL * fbUrl = [NSURL URLWithString:fbString];
        [iV sd_setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]];

    }
    
    else if ([self.is_teamCaptify intValue] == 1 || [self.username isEqualToString:@"Team-Captify"]){
        iV.image = [UIImage imageNamed:CAPTIFY_LOGO];
    }

    
    else{
        iV.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC_BIG];
        /*
        iV.image = nil;
        FAImageView *imageView2 = (FAImageView *)iV;
        [imageView2 setDefaultIconIdentifier:@"fa-user"];
         */

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

+ (NSDictionary *)createFriendWithParams:(NSDictionary *)params
           inMangedObjectContext:(NSManagedObjectContext *)context
{
    User *user;
    
    NSString *username = params[@"username"];
    NSNumber *facebook_user = params[@"facebook_user"];
    NSNumber *private = [NSNumber numberWithBool:NO];
    NSNumber *super_user = [NSNumber numberWithBool:NO];
    NSNumber *is_friend = [NSNumber numberWithBool:YES];
    
    NSString *facebook_id = @"0";
    if (params[@"facebook_id"]){
        facebook_id = params[@"facebook_id"];
    }
    
    NSString *email;
    if (params[@"email"]){
        email = params[@"email"];
    }
    
    NSString *phone_number;
    if (params[@"phone_number"]){
        phone_number = params[@"phone_number"];
    }
    NSNumber *is_contact;
    if (params[@"is_contact"]){
        is_contact = params[@"is_contact"];
    }
    
    NSString *score = @"0";
    if (params[@"score"]){
        score = params[@"score"];
    }
    
    NSNumber *is_teamCaptify = [NSNumber numberWithBool:NO];
    if (params[@"is_teamCaptify"]){
        is_teamCaptify = params[@"is_teamCaptify"];
    }
    
    NSString *display_name;
    if (params[@"display_name"]){
        display_name = params[@"display_name"];
        
    }
    
    
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@",[params valueForKey:@"username"]];
    
    NSInteger gotUser = [self checkIfUserWithFetch:request
                                           context:context
                                             error:&error];
    if (gotUser == 1){
        //DLog(@"cant create cause we have %@",[params valueForKey:@"username"]);
        user = [self getUserWithFetch:request
                              context:context
                                error:&error];
        
        if (!user.facebook_id || [user.facebook_id isEqualToString:@"0"]){
            user.facebook_user = facebook_user;
            user.facebook_id = facebook_id;
            user.is_teamCaptify = is_teamCaptify;
        }
        
        user.display_name = display_name;
        NSError *error;
        [user.managedObjectContext save:&error];

        
        NSDictionary *returnData = @{@"user": user,
                                     @"created":[NSNumber numberWithBool:NO]};
        return returnData;
    }
    

    
    user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                               inManagedObjectContext:context];

    user.username = [username stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    user.facebook_user = facebook_user;
    user.facebook_id = facebook_id;
    user.phone_number = phone_number;
    user.email = email;
    user.private = private;
    user.super_user = super_user;
    user.is_friend = is_friend;
    user.is_contactFriend = is_contact;
    user.score = score;
    user.is_teamCaptify = is_teamCaptify;
    user.display_name = display_name;
    
    if (![user.managedObjectContext save:&error]){
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    NSDictionary *returnData = @{@"user": user,
                                 @"created":[NSNumber numberWithBool:YES]};

    
    return returnData;

}




+ (User *)getUserWithUsername:(NSString *)username
                    inContext:(NSManagedObjectContext *)context
                        error:(NSError **)error
{
    
    username = [username stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[User name]];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"username = %@",username];
    
    NSArray *results = [context executeFetchRequest:request error:error];
    if ([results count] > 0){
        return [results firstObject];
    }
    else{
        DLog(@"theres no user %@ created",username);
        return nil;
    }

}


+ (User *)getOrCreateUserWithParams:(NSDictionary *)params
             inManagedObjectContext:(NSManagedObjectContext *)context
                         skipCreate:(BOOL)skip

{
    NSParameterAssert(context);
    NSAssert([params objectForKey:@"username"], @"username required");

    User *user = nil;
    NSError *error;
    NSString *username = params[@"username"];
    NSNumber *facebook_user = params[@"facebook_user"];
    NSString *facebook_id = params[@"facebook_id"];
    NSString *email = params[@"email"];
    NSNumber *private = [NSNumber numberWithBool:NO];
    NSNumber *super_user = [NSNumber numberWithBool:YES];
    NSNumber *is_friend = [NSNumber numberWithBool:YES];
    NSString *phone_number;
    if (params[@"phone_number"]){
        phone_number = params[@"phone_number"];
    }
    
    NSString *score = @"0";
    if (params[@"score"]){
        score = params[@"score"];
        if ([score isKindOfClass:[NSNumber class]]){
            score = [NSString stringWithFormat:@"%@",(NSNumber *)score];
        }
    }

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[User name]];
    request.predicate = [NSPredicate predicateWithFormat:@"(username = %@)",[params valueForKey:@"username"]];
    request.fetchLimit = 1;
    
    // check to see if we have this user (login)
    NSInteger gotUser = [self checkIfUserWithFetch:request
                                           context:context
                                             error:&error];
    
    if (gotUser > 0)
    {
        // if we have user return user
    
        
        user = [self getUserWithFetch:request
                              context:context
                                error:&error];
        
        user.facebook_id = facebook_id;
        user.facebook_user = facebook_user;
        user.username = username;
        user.email = email;
        user.phone_number = phone_number;
        user.score = score;
        
        if (![user.managedObjectContext save:&error]){
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
            
        }
        
        return user;
    }
    
    if (!skip){
        // else create a user, save, and return user (register)
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.username = username;
        user.facebook_user = facebook_user;
        user.private = private;
        user.email = email;
        user.super_user = super_user;
        user.facebook_id = facebook_id;
        user.is_friend = is_friend;
        user.score = score;
        if (phone_number){
            user.phone_number = phone_number;
        }
        //user.timestamp = [params valueForKey:@"timestamp"];
        
           if (![user.managedObjectContext save:&error]){
               DLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
                                    else{
                                        NSString *username;
                                        NSString *email;
                                        NSString *phone_number;
                                        NSString *score;
                                        NSNumber *facebook;
                                        NSNumber *privacy;
                                        NSDate *date;
                                        NSNumber *super_user; //is a super user
                                        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:9];

                                        @try {
                                            username = responseObject[@"username"];
                                            email = [responseObject valueForKeyPath:@"user.email"];
                                            phone_number = responseObject[@"phone_number"];
                                            score = responseObject[@"score"];
                                            facebook = [NSNumber numberWithBool:[responseObject[@"facebook_user"] boolValue]];
                                            privacy = [NSNumber numberWithInt:0];
                                            date = [NSDate date];
                                            super_user = [NSNumber numberWithInt:1]; //is a super user

                                        }
                                        @catch (NSException *exception) {
                                            DLog(@"%@",exception);
                                        }
                                        @finally {
                                            if (username){
                                                params[@"username"] = username;
                                            }
                                            if (score){
                                                params[@"score"] = score;
                                                if ([score isKindOfClass:[NSNumber class]]){
                                                    score = [NSString stringWithFormat:@"%@",(NSNumber *)score];
                                                }
                                            }
                                            if (facebook){
                                                params[@"facebook_user"] = facebook;
                                            }
                                            if (privacy){
                                                params[@"privacy"] = privacy;
                                            }
                                            if (super_user){
                                                params[@"super_user"] = super_user;
                                            }
                                            if (date){
                                                params[@"timestamp"] = date;
                                            }
                                            
                                            if (email){
                                                params[@"email"] = email;
                                            }
                                            
                                            if (phone_number){
                                                params[@"phone_number"] = phone_number;
                                            }
                                        }
                                        
                                        // prepare to get or create a user
                                        NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                                        
                                        if (context){
                                            NSDictionary *userDict = [self createFriendWithParams:params
                                                                            inMangedObjectContext:context];
                                            user = userDict[@"user"];
                                        }

                                    }
                                     
                                     NSString *username;
                                     NSString *apiKey;
                                     BOOL facebook_user;
                                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                     

                                     @try {
                                        username = responseObject[@"username"];
                                        facebook_user = [responseObject[@"facebook_user"]boolValue];
                                         apiKey = responseObject[@"api_key"];

                                     }
                                     @catch (NSException *exception) {
                                         DLog(@"%@",exception);
                                     }
                                     @finally {
                                         if (username){
                                            [defaults setValue:username forKey:@"username"];
                                         }
                                         
                                         if (apiKey){
                                            [defaults setValue:apiKey forKey:@"api_key"];
                                            NSString *apiString = [NSString stringWithFormat:@"ApiKey %@:%@",username,[responseObject valueForKey:@"api_key"]];
                                             
                                             [defaults setValue:apiString forKey:@"apiString"];

                                         }
                                         
                                         
                                         [defaults setBool:YES forKey:@"logged"];
                                         [defaults setBool:facebook_user forKey:@"facebook_user"];
                                     }
                                     
                                     
                        
                                     if ([user.username isEqualToString:username]){
                                           [defaults setURL:user.objectID.URIRepresentation forKey:@"superuser"];
                                     }else{
                                         user = [self getOrCreateUserWithParams:@{@"username": username}
                                                         inManagedObjectContext:context
                                                                     skipCreate:YES];
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
                                         if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                                             [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
                                         }


                                     });
                                 }
                                 
                             }];
}


+ (NSURLSessionDataTask *)registerWithParams:(NSDictionary *)params
                                    callback:(AwesomeAPICompleteBlock)block;
{
    
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPIRegisterUrlString
                          parameters:params
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                  [client stopNetworkActivity];
                                  // things went well
                                 if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                     // get params from response
                                     //NSLog(@"%@",responseObject);
                                     NSString *username;
                                     NSString *email;
                                     NSNumber *facebook;
                                     NSNumber *privacy;
                                     NSDate *date;
                                     NSNumber *super_user; //is a super user
                                     NSString *apiKey;
                                     NSString *phoneNumber;
                                     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:8];
                                     
                                     @try {
                                         username = responseObject[@"username"];
                                         email = responseObject[@"email"];
                                         facebook = [NSNumber numberWithBool:[responseObject[@"fbook_user"] boolValue]];
                                         privacy = [NSNumber numberWithBool:NO];
                                         date = [NSDate date];
                                         super_user = [NSNumber numberWithBool:YES]; //is a super user
                                         apiKey = responseObject[@"api_key"];
                                         phoneNumber = responseObject[@"phone_number"];

                                     }
                                     @catch (NSException *exception) {
                                         DLog(@"%@",exception);
                                     }
                                     @finally {
                                         if (username){
                                             params[@"username"] = username;
                                         }
                                         if (facebook){
                                             params[@"facebook_user"] = facebook;
                                         }
                                         
                                         if (privacy){
                                             params[@"privacy"] = privacy;
                                         }
                                         
                                         if (super_user){
                                             params[@"super_user"] = super_user;
                                         }
                                         
                                         if (date){
                                             params[@"timestamp"] = date;
                                         }
                                         
                                         if (email){
                                             params[@"email"] = email;
                                         }
                                         
                                         if (phoneNumber){
                                             params[@"phone_number"] = phoneNumber;
                                         }
                                         
                                         
                                     }
        
                                     
                                    // prepare to get or create a user
                                     NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                                     
                                    User *user = nil;
                                     if (context){
                                         user = [self getOrCreateUserWithParams:params
                                                         inManagedObjectContext:context
                                                                     skipCreate:NO];
                                     }

                                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                     [defaults setValue:username forKey:@"username"];
                                     [defaults setBool:YES forKey:@"logged"];
                                     [defaults setURL:user.objectID.URIRepresentation forKey:@"superuser"];
                                     [defaults setValue:apiKey forKey:@"api_key"];
                                     
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
                                         if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                                             [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
                                         }


                                     });
                                 }

                             }];
  }

+ (NSURLSessionDataTask *)registerFacebookWithParams:(NSDictionary *)params
                                            callback:(AwesomeAPICompleteBlock)block;
{
    NSAssert([params count] == 8 || [params count] == 9, @"8 parameters not being passed. Dict sent was %@",params);
    
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    return [client POST:AwesomeAPIFacebookUrlString
                                      parameters:params
                                         success:^(NSURLSessionDataTask *task, id responseObject) {
                                              [client stopNetworkActivity];
                                             DLog(@"%@",responseObject);
                                             // things went well
                                             if ([[responseObject valueForKey:@"code"] intValue] == 1){
                                                 NSString *username;
                                                 NSString *email;
                                                 NSNumber *facebook;
                                                 NSNumber *privacy;
                                                 NSString *score;
                                                 NSNumber *super_user; //is a super user
                                                 NSString *facebook_id;
                                                 NSString *phone_number;
                                                 NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:9];
                                                 @try {
                                                     username = [responseObject valueForKeyPath:@"user.username"];
                                                     email = [responseObject valueForKeyPath:@"user.email"];
                                                     score = responseObject[@"score"];
                                                     facebook = [NSNumber numberWithBool:YES];
                                                     privacy = [NSNumber numberWithInt:0];
                                                     super_user = [NSNumber numberWithInt:1]; //is a super user
                                                     facebook_id = responseObject[@"facebook_id"];
                                                     phone_number = responseObject[@"phone_number"];

                                                 }
                                                 @catch (NSException *exception) {
                                                     DLog(@"%@",exception);
                                                 }
                                                 @finally {
                                                     if (username){
                                                         params[@"username"] = username;
                                                     }
                                                     if (facebook){
                                                         params[@"facebook_user"] = facebook;
                                                     }
                                                     
                                                     if (facebook_id){
                                                         params[@"facebook_id"] = facebook_id;
                                                     }
                                                     
                                                     if (privacy){
                                                         params[@"privacy"] = privacy;
                                                     }
                                                     
                                                     if (super_user){
                                                         params[@"super_user"] = super_user;
                                                     }
                                                     
                                                     if (email){
                                                         params[@"email"] = email;
                                                     }
                                                     
                                                     if (score){
                                                         params[@"score"] = score;
                                                     }
                                                     
                                                     if (phone_number){
                                                         params[@"phone_number"] = phone_number;
                                                     }

                                                 }
                                                
                                                 
                                                 // prepare to get or create a user
                                                 NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                                                 
                                                 User *user = nil;
                                                 if (context){
                                                      user = [self getOrCreateUserWithParams:params
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
                                                  DLog(@" not success");
                                                 if (block){
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         block(NO,responseObject, nil, NO);
                                                     });
                                                 }
                                                 
                                             }
                                             // things did not go well because of me
                                             if ([[responseObject valueForKey:@"code"] intValue] == -10){
                                                  DLog(@"not me success");
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
                                                     if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                                                         [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
                                                     }


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
    [iv sd_setImageWithURL:picURLData placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]];
    
     
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
        NSString *contactFriendsFilter = @"(super_user = 0) and (is_friend = 1) and (is_contactFriend = 1) and (is_deleted = 0)";
        
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
                DLog(@"success");
                if (block){
                    block(YES,responseObject,@"success");
                }
            }
            
            else if (code == -10){
                DLog(@"success but not quite");
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
                
                if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                    [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out and logging back in"];
                    
                    
                }

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
                     DLog(@"success");
                     if (block){
                         block(YES,responseObject,@"success");
                     }
                 }
                 else if (code == -10){
                     DLog(@"success but not really");
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
                if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                    [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
                }

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
                 [JDStatusBarNotification showWithStatus:error.localizedDescription
                                            dismissAfter:2.0
                                               styleName:JDStatusBarStyleError];
                 if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                     [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
                 }

                 

             }
      
        }];

}

+ (void)fetchUserProfileWithData:(NSDictionary *)params
                           block:(ProfileFetchBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];

    [client POST:AwesomeAPIProfileString
      parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
         [client stopNetworkActivity];
          
          DLog(@"%@",responseObject);
          if ([responseObject[@"code"] intValue] == 1){
              if (block){
                  block(YES,responseObject[@"json"],responseObject);
              }
          }
          else{
              if (block){
                  block(NO,NO,nil);
              }
          }
    }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
         [client stopNetworkActivity];
          if (block){
              block(NO,NO,nil);
              
              [JDStatusBarNotification showWithStatus:error.localizedDescription
                                         dismissAfter:2.0
                                            styleName:JDStatusBarStyleError];
              if ([error.localizedDescription isEqualToString:CAPTIFY_UNAUTHORIZED]){
                  [self showAlertWithTitle:@"Error" message:@"You're currently unauthorized. Try logging out then logging back in."];
              }

          }
    }];
}


+ (void)showProfileOnVC:(UIViewController *)controller
           withUsername:(NSString *)name
             usingMZHud:(BOOL)usingHud
        fromExplorePage:(BOOL)explorePage
        showCloseButton:(BOOL)showCloseButton
      delaySetupWithTme:(float)delay
{
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
     UIViewController *profile = [mainBoard instantiateViewControllerWithIdentifier:@"profileScreen"];
    
    if ([profile isKindOfClass:[UserProfileViewController class]]){
        ((UserProfileViewController *)profile).usernameString = name;
        ((UserProfileViewController *)profile).delaySetupWithTime = delay;
        ((UserProfileViewController *)profile).fromExplorePage = explorePage;
        ((UserProfileViewController *)profile).showCloseButton = showCloseButton;
        
    }
    
    if (usingHud){
        UIViewController *vcForHUD;
        
        if (showCloseButton){
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:profile];
            vcForHUD = nav;
        }
        else{
            vcForHUD = profile;
        }
        
        MZFormSheetController *formSheet;
        if (!IS_IPHONE5){
            formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 380) viewController:vcForHUD];
            CGPoint point = formSheet.formSheetWindow.frame.origin;
            point.y -= 30;
            formSheet.formSheetWindow.frame = CGRectMake(point.x, point.y, formSheet.formSheetWindow.frame.size.width, formSheet.formSheetWindow.frame.size.height);
        }
        else{
            formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 400) viewController:vcForHUD];
            //formSheet = [[MZFormSheetController alloc] initWithSize:self.view.frame.size viewController:profile];
        }
        
        ((UserProfileViewController *)profile).controller = formSheet;
        
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        
        [[MZFormSheetController sharedBackgroundWindow] setBackgroundBlurEffect:YES];
        [[MZFormSheetController sharedBackgroundWindow] setBlurRadius:5.0];
        [[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor clearColor]];
        
        [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            //
        }];

    }
    else{
        [controller.navigationController pushViewController:profile animated:YES];
    }
    
   
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
