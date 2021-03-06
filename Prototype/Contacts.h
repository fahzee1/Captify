//
//  Contacts.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/17/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ContactsBlock) (BOOL done, id data);
typedef void (^ContactsRequestBlock) (BOOL success, id data);

@interface Contacts : NSObject



- (void)fetchContactsWithBlock:(ContactsBlock)block;

- (NSURLSessionDataTask *)requestFriendsFromContactsList:(NSDictionary *)params
                                                   block:(ContactsRequestBlock)block;
@end
