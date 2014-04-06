//
//  ParseNotifications.m
//  Captify
//
//  Created by CJ Ogbuehi on 4/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ParseNotifications.h"


@implementation ParseNotifications

- (void)sendNotification:(NSString *)message
               toFriends:(NSArray *)friends
                withData:(NSDictionary *)data
                   block:(ParseNotifBlock)block
{
    // list of friends
    // user who sent
    // notification message
    // challenge name
    // challenge id
    
    PFQuery *pushQuery = [PFInstallation query];
    
    [pushQuery whereKey:@"username" containsAllObjectsInArray:friends];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    PFPush *push = [PFPush new];
    [push setQuery:pushQuery];
    
    NSDictionary *payload = @{@"alert":message,
                              @"badge": @"Increment",
                              @"challenge":data[@"challenge_name"],
                              @"type":[NSNumber numberWithInt:100]};
    
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
