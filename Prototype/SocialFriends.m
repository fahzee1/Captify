//
//  FacebookFriends.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SocialFriends.h"
#import "AwesomeAPICLient.h"

@interface SocialFriends()

@property (strong, nonatomic)NSMutableArray *tempFriendList;
@property (strong, nonatomic)NSMutableDictionary *friendsDict;


@property (strong, nonatomic)NSMutableArray *tempAppUserList;
@property (strong, nonatomic)NSMutableDictionary *appUserDict;

@property BOOL twitterAccess;
@property BOOL facebookAccess;

@end

@implementation SocialFriends



- (void)hasFacebookAccess:(FacebookPostStatus)block
{
    // only use with users who didnt log in with fbook
    
    self.facebookAccess = NO;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    //specifiy APP id permissions
    NSDictionary *options = @{ACFacebookAppIdKey:CAPTIFY_FACEBOOK_ID,
                              ACFacebookPermissionsKey:@[@"publish_stream", @"publish_actions"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType
                                          options:options
                                       completion:^(BOOL granted, NSError *error) {
                                           if (granted){
                                               self.facebookAccess = YES;
                                               if (block){
                                                   block(YES);
                                               }
                                           }
                                           else{
                                               if (block){
                                                   block(NO);
                                               }
                                           }
                                       }];
    
  
    
}


- (void)hasTwitterAccess:(FacebookPostStatus)block;
{
    self.twitterAccess = NO;
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType
                                     options:nil
                                  completion:^(BOOL granted, NSError *error) {
                                      if (granted){
                                          self.twitterAccess = YES;
                                          if (block){
                                              block(YES);
                                          }
                                      }
                                      else{
                                          if (block){
                                              block(NO);
                                          }
                                      }
                                  }];
    

}



- (BOOL)hasPinterestAccess
{
    Pinterest *pinterst = [[Pinterest alloc] initWithClientId:PINTEREST_APPID];
    if ([pinterst canPinWithSDK]){
        return YES;
    }
    else{
        return NO;
    }
    

}

- (BOOL)hasInstagramAccess
{
    return [MGInstagram isAppInstalled];
}

- (BOOL)hasInstagramCorrectSize:(UIImage *)image
{
    return [MGInstagram isImageCorrectSize:image];
}


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
                //DLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                
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

            //DLog(@"Found: %i friends", friends.count);
            
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


- (void)sendFriendMessgaeWithID:(NSString *)userID
                          block:(FacebookFriendInvite)block
{
    if (FBSession.activeSession.isOpen){
        [FBWebDialogs presentDialogModallyWithSession:FBSession.activeSession
                                               dialog:@"send"
                                           parameters:@{@"to": userID}
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
             if (error){
                 DLog(@"%@",[error localizedDescription]);
                 [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Unable to send invitaton at this momemt. Make sure you're connected to the internet", nil)];
                 if (block){
                     block(NO , result);
                 }
             }
             else{
                 if (![resultURL query]){
                     return;
                 }
                 
                 if (result == FBWebDialogResultDialogNotCompleted){
                     [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Unable to send invitaton at this momemt. Make sure you're connected to the internet", nil)];
                     if (block){
                         block(NO,result);
                     }

                     return;
                 }
                 else if (![[resultURL description] hasPrefix:@"fbconnect://success?request="]){
                     if (block){
                         block(NO,result);
                     }

                     return;
                 }
                 else{
                     // success
                     
                     if (block){
                         block(YES,result);
                     }
                     
                     DLog(@"%@",resultURL);

                 }
                 
                 /*
                 NSDictionary *params = [self parseURLParams:[resultURL query]];
                 NSMutableArray *IDS = [[NSMutableArray alloc] init];
                 for (NSString *key in params){
                     if ([key hasPrefix:@"to["]){
                         [IDS addObject:[params objectForKey:key]];
                     }
                 }
                 
                 if ([params objectForKey:@"request"]){
                      DLog(@"Request ID: %@", [params objectForKey:@"request"]);
                 }
                 
                 if ([IDS count] > 0){
                     DLog(@"Recipient ID(s): %@", IDS);
                     
                     if (block){
                         block(YES,result);
                     }

                 }
                  */
                 
            }
         }];
    }
    else{
        if (block){
            block(NO,FBWebDialogResultDialogNotCompleted);
        }
    }

}


- (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        
        [params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return params;
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
                                                         DLog(@"%u",result);
                                                         
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

{
    if (!isFB){
        // if user didnt sign in with fbook
        // then use facebook built into settings
        
        [self postImageToFacebookFeed:image
                              message:message
                              caption:caption
                                 name:name
                              albumID:albumId
                            feedBlock:fblock];
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
                                                                     feedBlock:fblock];
                                             }
                                         }];
        
        return;
    }
    
    
    /*
    NSDictionary *params1 = @{@"album":albumId,
                             @"message":message,
                             @"caption":caption};
    
    
    // upload to album
    FBRequest *request = [FBRequest requestForUploadPhoto:image];
    [request.parameters addEntriesFromDictionary:params1];
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    [connection addRequest:request
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (error){
                 NSLog(@"%@",error);
                 if (fblock) {
                     fblock(NO);
                     
                     
                 }
                 return;
             }
             
             if (fblock){
                 DLog(@"album result %@",result);
                 fblock(YES);
             }

    }];
     */

    
    // upload to feed
    NSDictionary *params2 = @{@"picture": image,
                              @"caption":caption,
                              @"message":message};
    
    [FBRequestConnection startWithGraphPath:@"me/photos"
                                 parameters:params2
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error){
                                  NSLog(@"%@",error);
                                  if (fblock) {
                                      fblock(NO);
                                      
                                      
                                  }
                                  return;
                              }
                              
                              if (fblock){
                                  DLog(@"feed result %@",result);
                                  fblock(YES);
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
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    //specifiy APP id permissions
    NSDictionary *options = @{ACFacebookAppIdKey:CAPTIFY_FACEBOOK_ID,
                              ACFacebookPermissionsKey:@[@"publish_stream", @"publish_actions"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    
    [accountStore requestAccessToAccountsWithType:facebookAccountType
                                          options:options
                                       completion:^(BOOL granted, NSError *error) {
                                           if (granted){
                                               // post to feed
                                               NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                                               if ([accounts count] > 0){
                                                   ACAccount *facebookAccount = [accounts lastObject];
                                                   
                                                   NSDictionary *params1 = @{
                                                                             @"message":message,
                                                                             @"caption":caption,
                                                                             @"name":name};
                                                   
        
                                                   
                                                   SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                               requestMethod:SLRequestMethodPOST
                                                                                                         URL:[NSURL URLWithString:@"https://graph.facebook.com/me/photos"]
                                                                                                  parameters:params1];
                                
                                                   [feedRequest addMultipartData:UIImageJPEGRepresentation(image, 1.f)
                                                                        withName:@"picture"
                                                                            type:@"image/jpeg"
                                                                        filename:nil];
                                                   
                                                   
                                                   feedRequest.account = facebookAccount;
                                                   [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                        DLog(@"%@",urlResponse);
                                                       if (error){
                                                           NSLog(@"%@",error);
                                                           if (fblock){
                                                               fblock(NO);
                                                           }
                                                           return;
                                                       }
                                                       else{
                                                           // successfully posted to feed now post to album
                                                           NSString *albumString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos",albumId];
                                                           NSString *finalAlbum = [albumString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                                           NSURL *albumURL = [NSURL URLWithString:finalAlbum];
                                                           NSDictionary *params2 = @{@"source": image};
                                                           
                                                           SLRequest *albumRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                                                        requestMethod:SLRequestMethodPOST
                                                                                                                  URL:albumURL
                                                                                                           parameters:params2];
                                                           [albumRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                               if (error){
                                                                    NSLog(@"%@",error);
                                                                   if (fblock){
                                                                       fblock(NO);
                                                                   }
                                                                   return;
                                                               }
                                                               else{
                                                                   if (fblock){
                                                                       fblock(YES);
                                                                       DLog(@"%ld status code",(long)[urlResponse statusCode]);
                                                                       DLog(@"%@",urlResponse);
                                                                   }
                                                                   return;
                                                               }
                                                           }];

                                                           
                                                        }
                                                   }];
                                               }
                                               else{
                                                   [self showAlertWithTitle:nil message:NSLocalizedString(@"Make sure you've added a Facebook account in iOS Settings > Privacy > Facebook", nil)];
                                                   if (fblock){
                                                       fblock(NO);
                                                   }

                                               }
                                               
                                               
                                           }
                                           else{
                                               DLog(@"Error occoured %@",[error localizedDescription] );
                                               [self showAlertWithTitle:nil message:NSLocalizedString(@"Make sure you've allowed Captify to use Facebook in iOS Settings > Privacy > Facebook", nil)];
                                               if (fblock){
                                                   fblock(NO);
                                               }
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
                                              
                                              NSURL *requestUrl = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
                                              
                                              SLRequest *postRequest = [SLRequest
                                                                        requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST
                                                                        URL:requestUrl
                                                                        parameters:params];
                                              
                                              postRequest.account = twitterAccount;
                                              [postRequest addMultipartData:UIImageJPEGRepresentation(image, 1.f)
                                                                   withName:@"media[]" type:@"image/jpeg" filename:@"image.jpg"];
                                              
                                              [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                  if (error || [urlResponse statusCode] != 200){
                                                      DLog(@"%@",error);
                                                      if (block){
                                                          block(NO, YES);
                                                      }
                                                      return ;
                                                  }
                                                  else{
                                                      block(YES, YES);
                                                  }
                                                  
                                              }];
                                          }
                                          else{
                                            [self showAlertWithTitle:nil message:NSLocalizedString(@"Make sure you've added a Twiiter account in iOS Settings > Privacy > Twitter", nil)];
                                              if (block){
                                                  block(NO, NO);
                                              }
                                          }
                                      }
                                      else{
                                          DLog(@"Error occoured %@",[error localizedDescription]);
                                          [self showAlertWithTitle:nil message:NSLocalizedString(@"Make sure you've allowed Captify to use Twitter in iOS Settings > Privacy > Twitter", nil)];
                                          if (block){
                                              block(NO, NO);
                                          }
                                          
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
                    DLog(@"Remember to get album id and add to user defaults with method createAlbumwithname in facebook friends");
                    DLog(@"%@",error);
                    if (block){
                        block(NO);
                    }
                    
                    return;
                }
                
                if (block){
                    DLog(@"album result %@",result);
                    block(YES);
                }
            }];
            
            
        }
        else{
            DLog(@"error");
        }
    }];
    
}


+ (void)getFriendsUsernameWithID:(NSString *)ID
                           block:(FacebookFriendUsername)block
{
    [FBRequestConnection startWithGraphPath:ID
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error){
                                  DLog(@"%@",error.localizedDescription);
                                  if (block){
                                      block(NO,nil);
                                  }
                                  return ;
                              }
                              
                              if (block){
                                  block(YES,result[@"username"]);
                              }
                        }];
}


- (void)postImageToPinterestWithUrl:(NSURL *)url
                          sourceUrl:(NSURL *)sourceUrl
                     andDescription:(NSString *)description
{
    Pinterest *pinterst = [[Pinterest alloc] initWithClientId:PINTEREST_APPID];
    [pinterst createPinWithImageURL:url
                          sourceURL:sourceUrl
                        description:description];

}


- (void)postImageToInstagram:(UIImage *)image
                 withCaption:(NSString *)caption
                      inView:(UIView *)view
                    delegate:(id<UIDocumentInteractionControllerDelegate>)delegate
{
    [MGInstagram setPhotoFileName:kInstagramOnlyPhotoFileName];
    [MGInstagram postImage:image
               withCaption:caption
                    inView:view
                  delegate:delegate];

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
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];

    });
}


// used for phone number formatting
+ (NSString *)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    
    NSUInteger length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        
    }
    
    
    return mobileNumber;
}


+ (NSUInteger)getLength:(NSString *)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSUInteger length = [mobileNumber length];
    
    return length;
    
    
}

+ (void)sendPhoneNumber:(NSString *)number
                forUser:(NSString *)user
                  block:(SendPhoneNumberBlock)block
{
    NSDictionary *params = @{@"content": number,
                             @"username": user,
                             @"action":@"updatePhoneNumber"};
    AwesomeAPICLient *client = [AwesomeAPICLient sharedClient];
    if (!client.apiKeyFound){
        NSString *apiString = [[NSUserDefaults standardUserDefaults] valueForKey:@"apiString"];
        [client.requestSerializer setValue:apiString forHTTPHeaderField:@"Authorization"];
    }
    
    [client POST:AwesomeAPISettingsString
                               parameters:params
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                    DLog(@"%@",responseObject);
                                      int code = [[responseObject valueForKey:@"code"] intValue];
                                      if (code == 1){
                                        DLog(@"success");
                                          if (block){
                                              block(YES);
                                          }
                                      }
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      DLog(@"%@",error.localizedDescription);
                                      if (block){
                                          block(NO);
                                      }
                                  }];
}
@end
