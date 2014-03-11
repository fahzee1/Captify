//
//  FacebookFriends.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SocialFriends.h"

@interface SocialFriends()

@property (strong, nonatomic)NSMutableArray *tempFriendList;
@property (strong, nonatomic)NSMutableDictionary *friendsDict;


@property (strong, nonatomic)NSMutableArray *tempAppUserList;
@property (strong, nonatomic)NSMutableDictionary *appUserDict;

@end

@implementation SocialFriends



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
    FBRequest *friendRequest = [FBRequest requestWithGraphPath:@"me/friends?fields=installed"
                                                    parameters:nil
                                                    HTTPMethod:@"GET"];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error){
            self.tempAppUserList = [NSMutableArray array];
            NSArray* friends = [result objectForKey:@"data"];
            if ([friends count] > 0){
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                for (NSDictionary<FBGraphUser>* friend in friends) {
                    dict[@"name"] = friend.name;
                    dict[@"fbook_id"] = friend.id;
                    [self.tempAppUserList addObject:dict];
                    
                }
                
                
                if (block){
                    block(YES, self.tempAppUserList);
                }
            }
            else{
                friends = nil;
            }
        }
        else{
            self.tempAppUserList = nil;
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


- (void)postImageToFacebookFeed:(UIImage *)image
                message:(NSString *)message
                caption:(NSString *)caption
                   name:(NSString *)name
                        albumID:(NSString *)albumId
                   facebookUser:(BOOL)isFB
              feedBlock:(FacebookPostStatus)fblock
             albumBlock:(FacebookPostStatus)ablock

{
    if (!isFB){
        // if user didnt sign in with fbook
        // then use facebook built into settings
        
        [self postImageToFacebookFeed:image
                              message:message
                              caption:caption
                                 name:name
                              albumID:albumId
                            feedBlock:fblock
                           albumBlock:ablock];
        return;
    }
    
    // user signed in with facebook so just use session
    // or open it
    
    if (!FBSession.activeSession.isOpen){
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_stream"]
                                           defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             if (error){
                                                 [self showAlertWithTitle:nil message:error.localizedDescription];
                                             }
                                             else if (session.isOpen){
                                                 [self postImageToFacebookFeed:image
                                                               message:message
                                                               caption:caption
                                                                  name:name
                                                               albumID:albumId
                                                                  facebookUser:isFB
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
                fblock(NO);
         
            
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
            NSLog(@"%@",error);
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



// this one will be called by the one above if the user
// didnt log in with facebook
- (void)postImageToFacebookFeed:(UIImage *)image
                        message:(NSString *)message
                        caption:(NSString *)caption
                           name:(NSString *)name
                        albumID:(NSString *)albumId
                      feedBlock:(FacebookPostStatus)fblock
                     albumBlock:(FacebookPostStatus)ablock
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    //specifiy APP id permissions
    NSDictionary *options = @{ACFacebookAppIdKey: @"0000",
                              ACFacebookPermissionsKey:@[@"publish_stream", @"publish_actions"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType
                                          options:options
                                       completion:^(BOOL granted, NSError *error) {
                                           if (granted){
                                               NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                                               ACAccount *facebookAccount = [accounts lastObject];
                                               
                                               NSDictionary *params1 = @{@"image": image,
                                                                         @"message":message,
                                                                         @"caption":caption,
                                                                         @"name":name};
                                               
                                               NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
                                               
                                               SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                           requestMethod:SLRequestMethodPOST
                                                                                                     URL:feedURL
                                                                                              parameters:params1];
                                               feedRequest.account = facebookAccount;
                                               [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                   if (error){
                                                       if (fblock){
                                                           fblock(NO);
                                                       }
                                                       return;
                                                   }
                                                   else{
                                                       if (fblock){
                                                           fblock(YES);
                                                           NSLog(@"%ld status code",(long)[urlResponse statusCode]);
                                                       }
                                                   }
                                               }];
                                               
                                               NSURL *albumURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/photos",albumId]];
                                               NSDictionary *params2 = @{@"source": image};
                                               
                                               SLRequest *albumRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                            requestMethod:SLRequestMethodPOST
                                                                                                      URL:albumURL
                                                                                               parameters:params2];
                                               [albumRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                   if (error){
                                                       if (ablock){
                                                           ablock(NO);
                                                       }
                                                       return;
                                                   }
                                                   else{
                                                       if (ablock){
                                                           ablock(YES);
                                                           NSLog(@"%ld status code",(long)[urlResponse statusCode]);
                                                       }
                                                   }
                                               }];
                                               
                                               
                                               
                                               
                                               
                                               
                                           }
                                           else{
                                               NSLog(@"Error occoured %@",[error localizedDescription] );
                                               [self showAlertWithTitle:nil message:@"Make sure you've allowed this app to use Facebook in iOS Settings > Privacy > Twitter"];
                                           }
                                           
                                       }];
    
}






- (void)postImageToTwitterFeed:(UIImage *)image
                       caption:(NSString *)caption
                         block:(TwitterPostStatus)block
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType
                                     options:nil
                                  completion:^(BOOL granted, NSError *error) {
                                      if (granted == YES){
                                          // communicate with twitter
                                          
                                          NSArray *listOfAccounts = [account accountsWithAccountType:accountType];
                                          if ([listOfAccounts count] > 0){
                                              ACAccount *twitterAccount = [listOfAccounts lastObject];
                                              NSDictionary *params = @{@"status": caption};
                                              
                                              NSURL *requestUrl = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update_with_media.json"];
                                              
                                              SLRequest *postRequest = [SLRequest
                                                                        requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST
                                                                        URL:requestUrl
                                                                        parameters:params];
                                              
                                              postRequest.account = twitterAccount;
                                              [postRequest addMultipartData:UIImageJPEGRepresentation(image, 1.f)
                                                                   withName:@"media[]" type:@"image/jpeg" filename:@"image.jpg"];
                                              
                                              [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                  if (error){
                                                      NSLog(@"%@",error);
                                                      if (block){
                                                          block(NO);
                                                      }
                                                      return ;
                                                  }
                                                  
                                                  NSLog(@"Twiiter response %ld",(long)[urlResponse statusCode]);
                                              }];
                                          }
                                      }
                                      else{
                                          NSLog(@"Error occoured %@",[error localizedDescription] );
                                          [self showAlertWithTitle:nil message:@"Make sure you've allowed this app to use Twitter in iOS Settings > Privacy > Twitter"];
                                          
                                      }
                                  }];
    
}






- (void)postImage:(UIImage *)image
            block:(FacebookPostStatus)block
{
    [self createAlbumWithName:@"stunner" block:^(BOOL wasSuccessful, id albumID) {
        if (wasSuccessful){
            
            NSString *albumPath = [NSString stringWithFormat:@"%@/photos",albumID];
            FBRequest *albumRequest = [FBRequest requestWithGraphPath:albumPath
                                                           parameters:@{@"source": image}
                                                           HTTPMethod:@"POST"];
            
            [albumRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (error){
                    NSLog(@"Remember to get album id and add to user defaults with method createAlbumwithname in facebook friends");
                    NSLog(@"%@",error);
                    if (block){
                        block(NO);
                    }
                    
                    return;
                }
                
                if (block){
                    NSLog(@"album result %@",result);
                    block(YES);
                }
            }];
            
            
        }
        else{
            NSLog(@"error");
        }
    }];
    
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
{
    if (!title){
        title = @"Error";
    }
    else if (!message){
        message = @"There was an error.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
