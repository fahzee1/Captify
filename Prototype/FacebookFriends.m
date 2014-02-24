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
            NSLog(@"Found: %i friends", friends.count);
            for (NSDictionary<FBGraphUser>* friend in friends) {
                NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
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
@end
