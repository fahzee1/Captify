//
//  ChallengePicks+Utils.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/24/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengePicks+Utils.h"

@implementation ChallengePicks (Utils)

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    // called only once in this objects life time, at creation
    // put defaults here
    
    self.timestamp = [NSDate date];

}


- (void)awakeFromFetch
{
    [super awakeFromFetch];
    // called everytime this object is fetched
}


+ (NSString *)name
{
    return @"ChallengePicks";
}


@end
