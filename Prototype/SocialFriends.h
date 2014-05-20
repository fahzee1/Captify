//
//  FacebookFriends.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>



typedef void (^FacebookFriendFetch) (BOOL wasSuccessful, NSArray *data);
typedef void (^FacebookFriendInvite) (BOOL wasSuccessful, FBWebDialogResult result);
typedef void (^FacebookPostStatus) (BOOL wasSuccessful);
typedef void (^FacebookCreateAlbum) (BOOL wasSuccessful, id albumID);
typedef void (^TwitterPostStatus) (BOOL wasSuccessful, BOOL isGranted);
typedef void (^FacebookFriendUsername) (BOOL wasSuccessful, id name);


@interface SocialFriends : NSObject




- (void)allFriends:(FacebookFriendFetch)block;


- (void)onlyFriendsUsingApp:(FacebookFriendFetch)block;


- (void)sendFriendMessgaeWithID:(NSString *)userID
                          block:(FacebookFriendInvite)block;

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

- (void)postImageToFacebookFeed:(UIImage *)image
                message:(NSString *)message
                caption:(NSString *)caption
                   name:(NSString *)name
                albumID:(NSString *)albumId
                   facebookUser:(BOOL)isFB
                      feedBlock:(FacebookPostStatus)fblock;


- (void)postImageToTwitterFeed:(UIImage *)image
                       caption:(NSString *)caption
                         block:(TwitterPostStatus)block;


- (void)postImage:(UIImage *)image
            block:(FacebookPostStatus)block;


+ (void)getFriendsUsernameWithID:(NSString *)ID
                           block:(FacebookFriendUsername)block;


// the methods below are used as phone number formatters
typedef void (^SendPhoneNumberBlock) (BOOL wasSuccessful);

+ (NSUInteger)getLength:(NSString*)mobileNumber;
+ (NSString *)formatNumber:(NSString *)mobileNumber;

+ (void)sendPhoneNumber:(NSString *)number
                forUser:(NSString *)user
                  block:(SendPhoneNumberBlock)block;

@end
