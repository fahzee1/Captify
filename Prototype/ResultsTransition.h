//
//  ResultsTransition.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultsTransition : NSObject<UIViewControllerAnimatedTransitioning>

@property BOOL presenting;
@property bool dismissing;

@end
