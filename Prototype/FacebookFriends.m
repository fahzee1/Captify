//
//  FacebookFriends.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "FacebookFriends.h"

@interface FacebookFriends()

@property (strong, nonatomic)NSMutableArray *tempFriendList;
@property (strong, nonatomic)NSMutableDictionary *friendsDict;


@property (strong, nonatomic)NSMutableArray *tempAppUserList;
@property (strong, nonatomic)NSMutableDictionary *appUserDict;

@end

@implementation FacebookFriends



- (void)allFriends:(FacebookFriendFetch)block;
{
    self.tempFriendList = [NSMutableArray array];
    FBRequest *friendRequest = [FBRequest requestWithGraphPath:@"me/friends"
                                                    parameters:nil
                                                    HTTPMethod:@"GET"];
    
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error){
            NSArray *friends = [result objectForKey:@"data"];
            for (NSDictionary<FBGraphUser>* friend in friends) {
                //NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                
                // get friends picture
                //NSString *picURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",friend.id];
                //NSURL *picData = [NSURL URLWithString:picURL];
                //NSData *data = [NSData dataWithContentsOfURL:picData];
                //UIImage *pic = [UIImage imageWithData:data];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                dict[@"name"] = friend.name;
                dict[@"fbook_id"] = friend.id;
                //dict[@"pic"] = pic;
                [self.tempFriendList addObject:dict];
            }

            //NSLog(@"Found: %i friends", friends.count);
            
            if (block){
                block(YES,self.tempFriendList);
            }
        }
        else{
            if (block){
                block(NO, nil);
            }
        }
        
    }];

}


- (void)onlyFriendsUsingApp:(FacebookFriendFetch)block
{
    self.tempAppUserList = [NSMutableArray array];
    FBRequest *friendRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=installed"
                                                    parameters:nil
                                                    HTTPMethod:@"GET"];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error){
            NSArray* friends = [result objectForKey:@"data"];
            for (NSDictionary<FBGraphUser>* friend in friends) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                dict[@"name"] = friend.name;
                dict[@"fbook_id"] = friend.id;
                [self.tempAppUserList addObject:dict];
                
            }
            
            if (block){
                block(YES, self.tempAppUserList);
            }
        }
        else{
            if (block){
                block(NO, nil);
            }
        }
    }];

}


- (void)inviteFriendWithID:(NSString *)userID
                     title:(NSString *)title
                   message:(NSString *)message
                     block:(FacebookFriendInvite)block
{
    if (FBSession.activeSession.isOpen){

        [FBWebDialogs
         presentRequestsDialogModallyWithSession:nil
         message:message
         title:title
         parameters:@{@"to":userID }
         handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (!error){
                 if (block){
                     block(YES, result);
                 }
             }
             else{
                 if (block){
                     block(NO,result);
                 }
             }
         }];
    }
    else{
        if (block){
            block(NO,FBWebDialogResultDialogNotCompleted);
        }
    }

}



- (void)postStatusWithText:(NSString *)status
                  andImage:(UIImage *)image
                      from:(UIViewController *)controller
                     block:(FacebookPostStatus)block
{

    if (!status){
        status = NSLocalizedString(@"Cool app made this pic!", nil);
    }
    

    if ([FBDialogs canPresentOSIntegratedShareDialogWithSession:FBSession.activeSession])
    {
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:controller
                                                 initialText:status
                                                       image:image
                                                         url:nil
                                                     handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                                                         NSLog(@"%u",result);
                                                         
                                                         if (error){
                                                             if (block){
                                                                 block(NO);
                                                             }
                                                             return;
                                                         }
                                                         
                                                         switch (result) {
                                                             case 0:
                                                             {
                                                                 /*! Indicates that the dialog action completed successfully. */
                                                                 if (block){
                                                                     block(YES);
                                                                 }
                                                             }
                                                                 break;
                                                                 
                                                             case 1:
                                                             {
                                                                  /*! Indicates that the dialog action was cancelled (either by the user or the system). */
                                                                 if (block){
                                                                     block(NO);
                                                                 }
                                                             }
                                                                 break;
                                                             case 2:
                                                             {
                                                                /*! Indicates that the dialog could not be shown (because not on ios6 or ios6 auth was not used). */
                                                                 if (block){
                                                                     block(NO);
                                                                 }
                                                             }
                                                                 break;
                                                             default:
                                                                 break;
                                                         }
                                                         
                                                     }];
    }
}



- (void)createAlbumWithName:(NSString *)name
                      block:(FacebookCreateAlbum)block
{
    if (!FBSession.activeSession.isOpen){
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (error){
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                 message:error.localizedDescription
                                                                                                delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                 
                                                 [alert show];
                                             }
                                             else if (session.isOpen){
                                                 [self createAlbumWithName:name
                                                                     block:block];
                                             }
                                         }];
        
        return;
    }
   
   FBRequest *request = [FBRequest requestWithGraphPath:@"me/albums"
                         parameters:@{@"name": name}
                         HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error){
            if (block){
                block(NO,nil);
            }
            return ;
        }
        
        if (block){
            
            block(YES,[result objectForKey:@"id"]);
        }
    }];

    
}


- (void)postImageToFeed:(UIImage *)image
                message:(NSString *)message
                caption:(NSString *)caption
                   name:(NSString *)name
                albumID:(NSString *)albumId
              feedBlock:(FacebookPostStatus)fblock
             albumBlock:(FacebookPostStatus)ablock

{
    if (!FBSession.activeSession.isOpen){
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (error){
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                 message:error.localizedDescription
                                                                                                delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                 
                                                 [alert show];
                                             }
                                             else if (session.isOpen){
                                                 [self postImageToFeed:image
                                                               message:message
                                                               caption:caption
                                                                  name:name
                                                               albumID:albumId
                                                                 feedBlock:fblock
                                                            albumBlock:ablock];
                                             }
                                         }];
        
        return;
    }
    
    
    NSDictionary *params1 = @{@"image": image,
                             @"message":message,
                             @"caption":caption,
                             @"name":name};
    
    NSDictionary *params2 = @{@"source": image};
    
   FBRequest *request = [FBRequest requestWithGraphPath:@"me/feed"
                         parameters:params1
                         HTTPMethod:@"POST"];
    
    NSString *albumPath = [NSString stringWithFormat:@"%@/photos",albumId];
    FBRequest *albumRequest = [FBRequest requestWithGraphPath:albumPath
                                                   parameters:params2
                                                   HTTPMethod:@"POST"];

    // first publish to feed
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error){
            if (fblock) {
                fblock(YES);
         
            
            }
            return;
        }
        
        if (fblock){
            NSLog(@"feed result %@",result);
            fblock(YES);
        }
        
        
    }];
    
    // second save to photo album
    [albumRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error){
            NSLog(@"Remember to get album id and add to user defaults with method createAlbumwithname in facebook friends");
            if (ablock){
                ablock(NO);
            }
            
            return;
        }
        
        if (ablock){
            NSLog(@"album result %@",result);
            ablock(YES);
        }
    }];

    
    
}

@end
