//
//  ChallengePicks+Utils.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengePicks+Utils.h"
#import "User+Utils.h"

@implementation ChallengePicks (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.timestamp = [NSDate date];

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


+ (ChallengePicks *)createChallengePickWithParams:(NSDictionary *)params
{
    NSAssert([params valueForKey:@"answer"], @"Must include answer");
    NSAssert([params valueForKey:@"is_chosen"], @"Must include is_chosen");
    NSAssert([params valueForKey:@"player"], @"Must include player");
    NSAssert([params valueForKey:@"context"], @"Must include context");
    
    
   NSError *error;
   ChallengePicks *pick;
    User *user = [User getUserWithUsername:[params valueForKey:@"player"] inContext:[params valueForKey:@"context"] error:&error];
    
    // check if exists first
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[ChallengePicks name]];
    request.predicate = [NSPredicate predicateWithFormat:@"(answer = %@)",[params valueForKey:@"answer"]];
    int exist = [user.managedObjectContext countForFetchRequest:request error:&error];
    if (exist == 0){
        if (user){
           pick = [NSEntityDescription insertNewObjectForEntityForName:[ChallengePicks name] inManagedObjectContext:user.managedObjectContext];
            
            pick.answer = [params valueForKey:@"answer"];
            pick.is_chosen = [params valueForKey:@"is_chosen"];
            pick.player = user;
        
            
            NSError *error;
            if (![pick.managedObjectContext save:&error]){
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [ChallengePicks showAlertWithTitle:@"Error" message:@"There was an unrecoverable error, the application will shut down now"];
                
                abort();
                
            }
        }
        else{
            NSLog(@"user %@ hasnt been created, so challenge not created",[params valueForKey:@"player"]);
        }

    }
    else{
        NSLog(@"pick by %@ already created",[params valueForKey:@"player"]);
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



@end
