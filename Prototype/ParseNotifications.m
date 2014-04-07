//
//  ParseNotifications.m
//  Captify
//
//  Created by CJ Ogbuehi on 4/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ParseNotifications.h"


@implementation ParseNotifications

- (NSString *)channelsKey
{
    return @"channels";
}

- (BOOL)checkForChannelAndRemove:(NSString *)name
{
    NSArray *channels = [PFInstallation currentInstallation].channels;
    BOOL removed;
    for (id channel in channels){
        if ([name isEqualToString:channel]){
            [self removeChannelWithChallengeName:name];
            removed = YES;
        }
    }
    
    
    return removed;
}

- (NSString *)formatChannelNameForParse:(NSString *)name
{
    return [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
}

- (void)addChannelWithChallengeName:(NSString *)name
{
    
    NSString *newName = [self formatChannelNameForParse:name];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:newName forKey:[self channelsKey]];
    [currentInstallation saveInBackground];
}



- (void)removeChannelWithChallengeName:(NSString *)name
{
    NSString *newName = [self formatChannelNameForParse:name];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:newName forKey:[self channelsKey]];
    [currentInstallation saveInBackground];

}

- (void)sendNotification:(NSString *)message
                toFriend:(NSString *)friend
                withData:(NSDictionary *) data
        notificationType:(ParseNotificationTypes)type
                   block:(ParseNotifBlock)block
{
    
    PFQuery *pushQuery = [PFInstallation query];
    
    [pushQuery whereKey:@"username" equalTo:friend];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    PFPush *push = [PFPush new];
    [push setQuery:pushQuery];
    
    NSMutableDictionary *payload = [@{@"alert":message,
                                      @"badge": @"Increment",
                                      @"type":[NSNumber numberWithInt:type]} mutableCopy];
    
    if (data[@"challenge_name"]){
        payload[@"challenge"] = data[@"challenge_name"];
    }
    
    
    [push setData:payload];
    
    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block (YES);
                }
            });
        }
        else{
            NSLog(@"%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block (NO);
                }
            });
            
        }
    }];

}



- (void)sendNotification:(NSString *)message
               toFriends:(NSArray *)friends
                withData:(NSDictionary *)data
        notificationType:(ParseNotificationTypes)type
                   block:(ParseNotifBlock)block
{
  
    
    PFQuery *pushQuery = [PFInstallation query];
    
    [pushQuery whereKey:@"username" containsAllObjectsInArray:friends];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    PFPush *push = [PFPush new];
    [push setQuery:pushQuery];
    
    NSMutableDictionary *payload = [@{@"alert":message,
                              @"badge": @"Increment",
                              @"type":[NSNumber numberWithInt:type]} mutableCopy];
    
    if (data[@"challenge_name"]){
        payload[@"challenge"] = data[@"challenge_name"];
    }
    
    
    [push setData:payload];

    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                     block (YES);
                }
            });
        }
        else{
            NSLog(@"%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block (NO);
                }
            });

        }
    }];
}


- (void)sendTestNotification:(NSString *)message
                withData:(NSDictionary *)data
        notificationType:(ParseNotificationTypes)type
                   block:(ParseNotifBlock)block
{
    
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"username" equalTo:@"cj.ogbuehi"];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    PFPush *push = [PFPush new];
    [push setQuery:pushQuery];
    
    NSMutableDictionary *payload = [@{@"alert":message,
                                      @"badge": @"Increment",
                                      @"type":[NSNumber numberWithInt:type]} mutableCopy];
    
    if (data[@"challenge_name"]){
        payload[@"challenge"] = data[@"challenge_name"];
    }
    
    [push setData:payload];
    
    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block (YES);
                }
            });
        }
        else{
            NSLog(@"%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block (NO);
                }
            });
            
        }
    }];
}


- (void)sendNotification:(NSString *)message
               toChannel:(NSString *)channel
                withData:(NSDictionary *)data
        notificationType:(ParseNotificationTypes)type
                   block:(ParseNotifBlock)block
{
    NSString *newName = [self formatChannelNameForParse:channel];
    PFPush *push = [PFPush new];
    
    [push setChannel:newName];
    NSMutableDictionary *payload = [@{@"alert":message,
                                      @"badge": @"Increment",
                                      @"type":[NSNumber numberWithInt:type]} mutableCopy];
    
    if (data[@"challenge_name"]){
        payload[@"challenge"] = data[@"challenge_name"];
    }

    [push setData:payload];
    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block (YES);
                }
            });
        }
        else{
            NSLog(@"%@",error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block){
                    block (NO);
                }
            });
            
        }
    }];
    
}


@end
