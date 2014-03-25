//
//  TestDataCreator.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "TestDataCreator.h"

@interface TestDataCreator()

@end


@implementation TestDataCreator

+ (NSArray *)createTestFriendsBatch:(int)count
                           facebook:(BOOL)facebook
                          inContext:(NSManagedObjectContext*)context;
{
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    for (int i=0; i < count; i++){
        if (facebook){
        User *user = [self createTestFriendWithName:@"Jolly"
                                           facebook:YES
                                               fbID:@111
                                          inContext:context];
            
        [friends addObject:user];
        }
        else{
            User *user = [self createTestFriendWithName:@"Jolly"
                                               facebook:NO
                                                   fbID:Nil
                                              inContext:context];
            
            [friends addObject:user];

        }
    }
    
    return friends;
}


+ (User *)createTestFriendWithName:(NSString *)name
                          facebook:(BOOL)facebook
                              fbID:(NSNumber *)fbID
                         inContext:(NSManagedObjectContext *)context
{
    NSError *error;
    User *user = nil;
    user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    user.username = name;
    if (facebook){
        user.facebook_user = [NSNumber numberWithBool:YES];
        user.facebook_id = fbID;
    }
    
    user.private = [NSNumber numberWithBool:NO];
    user.super_user = [NSNumber numberWithBool:NO];
    user.is_friend = [NSNumber numberWithBool:YES];
    
    if (![user.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    
    return  user;
    
}


+ (NSArray *)createTestChallengeBatch:(int)count
                             fromUser:(User *)sender
                            toFriends:(NSArray *)friends
                               withID:(NSString *)cID
{
    NSMutableArray *challenges = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++){
        Challenge *challenge = [self createTestChallengeWithName:@"Test this long ass name here"
                                   byUser:sender
                                toFriends:friends
                                   withID:cID];
        [challenges addObject:challenge];
    }
    
    
    return challenges;
    
}

+ (Challenge *)createTestChallengeWithName:(NSString *)name
                                    byUser:(User *)sender
                                 toFriends:(NSArray *)friends
                                    withID:(NSString *)cID
{
    NSError *error;
    Challenge *challenge = nil;
    challenge = [NSEntityDescription insertNewObjectForEntityForName:[Challenge name] inManagedObjectContext:sender.managedObjectContext];
    challenge.challenge_id = cID;
    challenge.sender = sender;
    challenge.recipients_count = @25;
    challenge.name = name;
    [challenge addRecipients:[NSSet setWithArray:friends]];
    challenge.active = [NSNumber numberWithBool:YES];
    if (![challenge.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        
    }
    
    
    return challenge;
    
    return challenge;
}


+ (ChallengePicks *)addChallengePickToChallenge:(Challenge *)challenge
                                     withPlayer:(User *)player
                                        caption:(NSString *)caption
{
    
    NSError *error;
    ChallengePicks *pick;
    pick = [NSEntityDescription insertNewObjectForEntityForName:[ChallengePicks name] inManagedObjectContext:player.managedObjectContext];
    pick.answer = caption;
    pick.player = player;
    if (![pick.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [challenge addPicksObject:pick];
    
    if (![challenge.managedObjectContext save:&error]){
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();

    }
    
    return pick;
}

@end
