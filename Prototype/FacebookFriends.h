//
//  FacebookFriends.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

typedef void (^FacebookFriendFetch) (BOOL wasSuccessful, NSArray *data);

@interface FacebookFriends : NSObject




- (void)allFriends:(FacebookFriendFetch)block;
- (void)onlyFriendsUsingApp:(FacebookFriendFetch)block;
@end
