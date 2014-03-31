//
//  Notifications.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/31/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "Notifications.h"

#define notificationTAG 33330002


@implementation Notifications



- (NSString *)keyName
{
    return @"notifications";
}


- (void)addOneNotifToView:(UIView *)view
                  atPoint:(CGPoint)point
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int count = [[defaults valueForKey:[self keyName]] intValue];
    if (count){
        count = count += 1;
    }
    else{
        count = 1;
    }
    
    [defaults setValue:[NSNumber numberWithInt:count] forKey:[self keyName]];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.text = [NSString stringWithFormat:@"%d",count];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont boldSystemFontOfSize:12];
    CGRect frame = CGRectMake(point.x,point.y, 30, 30);
    CGRect lFrame;
    if (count > 99){
        lFrame = CGRectMake(5, 5, 30, 20);
    }
    else{
        lFrame = CGRectMake(9, 5, 30, 20);
    }
    countLabel.frame = lFrame;
    UIView *notif = [[UIView alloc] initWithFrame:frame];
    notif.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6f];
    notif.layer.cornerRadius = 15;
    notif.tag = notificationTAG;
    [notif addSubview:countLabel];
    notif.userInteractionEnabled = NO;
    [view addSubview:notif];

    
    

}

- (void)addOneNotifToView:(UIView *)view usingViewAsReference:(UIView *)rView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int count = [[defaults valueForKey:[self keyName]] intValue];
    if (count > 0){
        count = count += 1;
    }
    else{
        count = 1;
    }
    
    [defaults setValue:[NSNumber numberWithInt:count] forKey:[self keyName]];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.text = [NSString stringWithFormat:@"%d",count];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont boldSystemFontOfSize:12];
    CGRect frame = CGRectMake(rView.frame.origin.x, rView.frame.origin.y, 30, 30);
    CGRect lFrame;
    if (count > 99){
        lFrame = CGRectMake(5, 5, 30, 20);
    }
    else if (count < 10 && count > 0){
        lFrame = CGRectMake(12, 5, 30, 20);
    }
    else{
        lFrame = CGRectMake(9, 5, 30, 20);
    }
    countLabel.frame = lFrame;
    UIView *notif = [[UIView alloc] initWithFrame:frame];
    notif.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6f];
    notif.layer.cornerRadius = 15;
    [notif addSubview:countLabel];
    notif.userInteractionEnabled = NO;
    notif.tag = notificationTAG;
    [view addSubview:notif];
    
}

- (void)addToNotifsWithCount:(NSInteger)count
                     andView:(UIView *)view
        usingViewAsReference:(UIView *)rView
{
    
}


- (void)removeOneNotifFromView:(UIView *)view
                       atPoint:(CGPoint)point
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int count = [[defaults valueForKey:[self keyName]] intValue];
    if (count > 1){
        count = count -= 1;
        
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.text = [NSString stringWithFormat:@"%d",count];
        countLabel.textColor = [UIColor whiteColor];
        countLabel.font = [UIFont boldSystemFontOfSize:12];
        CGRect frame = CGRectMake(point.x, point.y, 30, 30);
        CGRect lFrame;
        if (count > 99){
            lFrame = CGRectMake(5, 5, 30, 20);
        }
        else if (count < 10 && count > 0){
            lFrame = CGRectMake(12, 5, 30, 20);
        }
        else{
            lFrame = CGRectMake(9, 5, 30, 20);
        }
        countLabel.frame = lFrame;
        UIView *notif = [[UIView alloc] initWithFrame:frame];
        notif.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6f];
        notif.layer.cornerRadius = 15;
        [notif addSubview:countLabel];
        notif.userInteractionEnabled = NO;
        notif.tag = notificationTAG;
        [view addSubview:notif];

        
        
    }
    else{
        count = 0;
        
        UIView *notif = [view viewWithTag:notificationTAG];
        if (notif){
            [notif removeFromSuperview];
        }
    }
    
    [defaults setValue:[NSNumber numberWithInt:count] forKey:[self keyName]];
    
}


- (void)removeNotifsWithCount:(NSInteger)count
                      andView:(UIView *)view
         usingViewAsReference:(UIView *)rView
{
    
}

- (void)clearAllNotifs
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:[self keyName]];
}

@end

