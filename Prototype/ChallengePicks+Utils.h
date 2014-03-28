//
//  ChallengePicks+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengePicks.h"
@class User;

typedef void (^CreatePickUpdateBlock) (BOOL wasSuccessful, NSString *message);

@interface ChallengePicks (Utils)


+ (NSString *)name;

+ (NSString *)dateStringFromDate:(NSDate *)date;

+ (ChallengePicks *)createChallengePickWithParams:(NSDictionary *)params;

+ (NSString *)createPickID;

+ (void)sendCreatePickRequestWithParams:(NSDictionary *)params
                                  block:(CreatePickUpdateBlock)block;

@end
