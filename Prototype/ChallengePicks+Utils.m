//
//  ChallengePicks+Utils.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengePicks+Utils.h"
#import "User+Utils.h"
#import "AwesomeAPICLient.h"
#import "JDStatusBarNotification.h"

@implementation ChallengePicks (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.timestamp = [NSDate date];
    self.first_open = [NSNumber numberWithInt:1];
    self.is_deleted = [NSNumber numberWithBool:NO];

}


- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
}


+ (NSString *)name
{
    return @"ChallengePicks";
}

+ (NSString *)dateStringFromDate:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterLongStyle
                                          timeStyle:NSDateFormatterShortStyle];
}



+ (ChallengePicks *)createChallengePickWithParams:(NSDictionary *)params
{
    NSAssert([params valueForKey:@"answer"], @"Must include answer");
    NSAssert([params valueForKey:@"is_chosen"], @"Must include is_chosen");
    NSAssert([params valueForKey:@"player"], @"Must include player");
    NSAssert([params valueForKey:@"context"], @"Must include context");
    NSAssert([params valueForKey:@"pick_id"], @"Must include pick_id");
    
    static int retrys = 0;
   NSError *error;
   ChallengePicks *pick;
    User *user = [User getUserWithUsername:[params valueForKey:@"player"] inContext:[params valueForKey:@"context"] error:&error];
    
    // check if exists first
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[ChallengePicks name]];
    request.predicate = [NSPredicate predicateWithFormat:@"pick_id = %@",[params valueForKey:@"pick_id"]];
    NSUInteger exist = [user.managedObjectContext countForFetchRequest:request error:&error];
    if (exist == 0){
        if (user){
           pick = [NSEntityDescription insertNewObjectForEntityForName:[ChallengePicks name] inManagedObjectContext:user.managedObjectContext];
            
            pick.answer = [params valueForKey:@"answer"];
            pick.is_chosen = [params valueForKey:@"is_chosen"];
            pick.pick_id = [params valueForKey:@"pick_id"];
            pick.player = user;
            
            if ([params valueForKey:@"created"]){
                pick.timestamp = [params valueForKey:@"created"];
            }

            
            NSError *error;
            if (![pick.managedObjectContext save:&error]){
                DLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [ChallengePicks showAlertWithTitle:@"Error" message:@"There was an unrecoverable error, the application will shut down now"];
                
                abort();
                
            }
            
        }
        // create user
        else{
            DLog(@"user %@ hasnt been created, so creating now for pick",[params valueForKey:@"player"]);
            NSDictionary *params2 = @{@"username":[params valueForKey:@"player"],
                                     @"facebook_user":[params valueForKey:@"is_facebook"],
                                     @"facebook_id":[params valueForKey:@"facebook_id"]};
            
            NSDictionary *userDict = [User createFriendWithParams:params2
                                            inMangedObjectContext:[params valueForKey:@"context"]];
            User *newUser = userDict[@"user"];
            
            if (newUser){
                retrys += 1;
                if (retrys < 4){
                    [self createChallengePickWithParams:params];
                }
            }

        }

    }
    else{
        // fetch and update
        NSNumber *is_chosen = [params valueForKey:@"is_chosen"];
        pick = [self getPicksWithID:[params valueForKey:@"pick_id"]
                                          inContext:[params valueForKey:@"context"]];
        pick.is_chosen = is_chosen ? is_chosen : [NSNumber numberWithBool:NO];
        
        
    }
    
    
    return pick;
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


+ (ChallengePicks *)getPicksWithID:(NSString *)picID
                        inContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[ChallengePicks name]];
    request.predicate = [NSPredicate predicateWithFormat:@"(pick_id = %@)",picID];
    request.fetchLimit = 1;
    
    NSArray *picks = [context executeFetchRequest:request error:&error];
    if (! picks){
        DLog(@"%@",error);
        return nil;
    }
    
    return [picks firstObject];
    
}


+ (NSString *)createPickID
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [NSString stringWithFormat:@"pick-%@",uuid];
}


+ (void)sendCreatePickRequestWithParams:(NSDictionary *)params
                                  block:(CreatePickUpdateBlock)block
{
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    [client startNetworkActivity];
    [client POST:AwesomeAPIChallengeCreatePickString parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [client stopNetworkActivity];
             int code = [[responseObject valueForKey:@"code"] intValue];
             if (code == 1){
                 if (block){
                     block(YES, NO, @"Success",responseObject[@"pick_id"]);
                 }
                 return;
             }
             
             else if (code == -12 || code == 437){
                 if (block){
                     block(NO,YES,responseObject[@"message"],nil);
                 }
                 return;
             }
             
             else if (code == -10){
                 if (block){
                     block(NO, NO, @"There was an error",nil);
                 }
                 return;
             }
             else{
                 if (block){
                     block(NO, NO, @"There was an error",nil);
                 }
                 return;

             }
        
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [client stopNetworkActivity];
             DLog(@"%@",error);
             if (block){
                 block(NO, YES, error.localizedDescription, nil);
                 [JDStatusBarNotification showWithStatus:error.localizedDescription
                                            dismissAfter:2.0
                                               styleName:JDStatusBarStyleError];

             }
        
        }];

    
    
}


@end
