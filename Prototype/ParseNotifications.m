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


- (NSString *)formatChannelNameForParse:(NSString *)name
{
    return [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
}

- (void)addChannelWithChallengeName:(NSString *)name
{
    
    NSString *newName = [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:newName forKey:[self channelsKey]];
    [currentInstallation saveInBackground];
}



- (void)removeChannelWithChallengeName:(NSString *)name
{
    NSString *newName = [name stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:newName forKey:[self channelsKey]];
    [currentInstallation saveInBackground];

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



@end
