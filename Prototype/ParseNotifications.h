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

typedef enum {
    ParseNotificationCreateChallenge = 100,
    ParseNotificationSendCaptionPick,
    ParseNotificationSenderChoseCaption,
    ParseNotificationNotifySelectedCaptionSender
    
    
} ParseNotificationTypes;


@interface ParseNotifications : NSObject

- (NSString *)formatChannelNameForParse:(NSString *)name;

- (void)addChannelWithChallengeName:(NSString *)name;

- (void)removeChannelWithChallengeName:(NSString *)name;

- (void)sendNotification:(NSString *)message
               toFriends:(NSArray *)friends
                withData:(NSDictionary *) data
        notificationType:(ParseNotificationTypes)type
                   block:(ParseNotifBlock)block;

- (void)sendTestNotification:(NSString *)message
                withData:(NSDictionary *)data
        notificationType:(ParseNotificationTypes)type
                       block:(ParseNotifBlock)block;
@end
