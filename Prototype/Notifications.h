//
//  Notifications.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/31/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notifications : NSObject


- (void)addOneNotifToView:(UIView *)view
                  atPoint:(CGPoint)point;

- (void)addOneNotifToView:(UIView *)view
     usingViewAsReference:(UIView *)rView;

- (void)addToNotifsWithCount:(NSInteger)count
                     andView:(UIView *)view
        usingViewAsReference:(UIView *)rView;

- (void)removeOneNotifFromView:(UIView *)view
                       atPoint:(CGPoint)point;

- (void)removeNotifsWithCount:(NSInteger)count
                      andView:(UIView *)view
         usingViewAsReference:(UIView *)rView;

- (void)clearAllNotifs;

@end
