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
typedef void (^FacebookFriendInvite) (BOOL wasSuccessful, FBWebDialogResult result);
typedef void (^FacebookPostStatus) (BOOL wasSuccessful);
typedef void (^FacebookCreateAlbum) (BOOL wasSuccessful, id albumID);

@interface FacebookFriends : NSObject




- (void)allFriends:(FacebookFriendFetch)block;


- (void)onlyFriendsUsingApp:(FacebookFriendFetch)block;


- (void)inviteFriendWithID:(NSString *)userID
                     title:(NSString *)title
                   message:(NSString *)message
                     block:(FacebookFriendInvite)block;


- (void)postStatusWithText:(NSString *)status
                  andImage:(UIImage *)image
                      from:(UIViewController *)controller
                     block:(FacebookPostStatus)block;


- (void)createAlbumWithName:(NSString *)name
                      block:(FacebookCreateAlbum)block;

- (void)postImageToFeed:(UIImage *)image
                message:(NSString *)message
                caption:(NSString *)caption
                   name:(NSString *)name
                albumID:(NSString *)albumId
                  feedBlock:(FacebookPostStatus)fblock
             albumBlock:(FacebookPostStatus)ablock;

- (void)postImage:(UIImage *)image
            block:(FacebookPostStatus)block;

@end
