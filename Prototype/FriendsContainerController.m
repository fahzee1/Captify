//
//  FriendsContainerController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "FriendsContainerController.h"

@interface FriendsContainerController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *myContainerView;
@property (strong,nonatomic)UIViewController *currentController;

@end

@implementation FriendsContainerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIViewController *vc = [self viewControllerForSegmentIndex:self.mySegmentedControl.selectedSegmentIndex];
    [self addChildViewController:vc];
    vc.view.frame = self.myContainerView.bounds;
    [self.myContainerView addSubview:vc.view];
    self.currentController = vc;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    UIViewController *vc = [self viewControllerForSegmentIndex:sender.selectedSegmentIndex];
    
    [self addChildViewController:vc];
    [self transitionFromViewController:self.currentController
                      toViewController:vc
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromBottom
                            animations:^{
                                [self.currentController.view removeFromSuperview];
                                vc.view.frame = self.myContainerView.bounds;
                                [self.myContainerView addSubview:vc.view];
                            } completion:^(BOOL finished) {
                                [vc didMoveToParentViewController:self];
                                [self.currentController removeFromParentViewController];
                                self.currentController = vc;
                            }];
    
}


- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    UIViewController *vc;
    switch (index) {
        case 0:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"friends"];
            break;
        case 1:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"addFriends"];
            break;
        case 2:
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"searchFriends"];
            break;
    }
    return vc;
}

@end
