//
//  AwesomeUser.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AwesomeUser : NSObject

@property (nonatomic, assign) NSUInteger userID;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, unsafe_unretained) NSURL *avatarImageURL;
@property(nonatomic, assign, getter = isLogged) BOOL logged;

+ (instancetype)sharedAccount;

@end
