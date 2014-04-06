//
//  ParseNotifications.h
//  Captify
//
//  Created by CJ Ogbuehi on 4/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef void (^ParseNotifBlock) (BOOL wasSuccessful);

@interface ParseNotifications : NSObject


- (void)sendNotification:(NSString *)message
               toFriends:(NSArray *)friends
                withData:(NSDictionary *) data
                   block:(ParseNotifBlock)block;

@end
