//
//  ChallengePicks+Utils.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengePicks.h"
@class User;

@interface ChallengePicks (Utils)


+ (NSString *)name;

+ (ChallengePicks *)createChallengePickWithParams:(NSDictionary *)params;
@end
