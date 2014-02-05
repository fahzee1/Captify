//
//  GoHomeTransition.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/4/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "GoHomeTransition.h"
#import "HomeViewController.h"
#import "LoginViewController.h"

@implementation GoHomeTransition


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}


-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    HomeViewController *toVC = (HomeViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];

    toVC.view.alpha = 0;
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         fromVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         toVC.view.alpha = 1;
                     } completion:^(BOOL finished) {
                         fromVC.view.transform = CGAffineTransformIdentity;
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}
@end
