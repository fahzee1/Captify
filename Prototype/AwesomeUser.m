//
//  AwesomeUser.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AwesomeUser.h"

NSString * const kUserLoggedOutNotification = @"kUserLoggedOutNotification";

@interface AwesomeUser()
//private properties

@end
@implementation AwesomeUser

- (void)setLogged:(BOOL)logged
{
    _logged = logged;
    
    if (_logged == NO){
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedOutNotification
                                                            object:self];
    }
}

+ (instancetype)sharedAccount
{
    static id sharedAccount;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAccount = [[self alloc] init];
    });
    
    return sharedAccount;
}
@end
