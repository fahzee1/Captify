//
//  UITableView+ReloadAnimation.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/26/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UITableView+ReloadAnimation.h"

@implementation UITableView (ReloadAnimation)


- (void)reloadData:(BOOL)animated
{
    [self reloadData];
    
    if (animated) {
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:.3];
        [[self layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
        
    }
}

@end
