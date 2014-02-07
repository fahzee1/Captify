//
//  ResultsTransition.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ResultsTransition.h"
#import "HomeViewController.h"

@interface ResultsTransition()

@property UIView *snapshot;

@end
@implementation ResultsTransition


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

    if (self.showingResults){
        toVC.view.alpha = .8;
        UIView *snapshot = [fromVC.view snapshotViewAfterScreenUpdates:YES];
        self.snapshot = snapshot;
        [toVC.view addSubview:snapshot];
        
    }

    [containerView addSubview:toVC.view];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         fromVC.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         if (!self.showingResults){
                             toVC.view.alpha = 1;
                         }
                     } completion:^(BOOL finished) {
                         if (self.showingResults){
                             [self.snapshot removeFromSuperview];
                         }
                         fromVC.view.transform = CGAffineTransformIdentity;
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
