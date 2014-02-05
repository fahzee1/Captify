//
//  ChallengeSend.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/5/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Challenge, User;

@interface ChallengeSend : NSManagedObject

@property (nonatomic, retain) NSNumber * retry;
@property (nonatomic, retain) Challenge *challenge;
@property (nonatomic, retain) NSSet *recipients;
@end

@interface ChallengeSend (CoreDataGeneratedAccessors)

- (void)addRecipientsObject:(User *)value;
- (void)removeRecipientsObject:(User *)value;
- (void)addRecipients:(NSSet *)values;
- (void)removeRecipients:(NSSet *)values;

@end
