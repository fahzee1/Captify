//
//  RecentActivityViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/6/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "RecentActivityViewController.h"
#import "AppDelegate.h"
#import "Challenge+Utils.h"

@interface RecentActivityViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableBox;
@property (weak, nonatomic) IBOutlet UISegmentedControl *whichTable;


@property NSArray *myChallenges;
@property (weak, nonatomic) IBOutlet UISegmentedControl *whichController;



@end

@implementation RecentActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self){
       
    }
    return self;
}

- (instancetype)initWithMyViewController:(UIViewController *)myVC
                    andFriendsController:(UIViewController *)friendVC
{
    self = [super initWithNibName:nil bundle:nil];
    if (self){
        self.myChallengeController = myVC;
        self.friendsChallengeController = friendVC;
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myChallengeController = [self.storyboard instantiateViewControllerWithIdentifier:@"myChallenges"];
    self.friendsChallengeController = [self.storyboard instantiateViewControllerWithIdentifier:@"friendsChallenges"];

    UIViewController *vc = self.myChallengeController;
    if (vc){
        if ([vc respondsToSelector:@selector(setMyUser:)]){
            
            ((FriendsChallengeViewController *)vc).myUser = self.myUser;
        }

        [self displayCurrentController:self.friendsChallengeController];
    }
    [self.whichController addTarget:self action:@selector(choseController) forControlEvents:UIControlEventValueChanged];
    
    /*self.myChallenges = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];*/
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGRect)frameForCurrentController:(BOOL)transition
{
    CGRect frame = CGRectZero;
    CGSize size = CGSizeMake(self.currentController.view.frame.size.width, self.currentController.view.frame.size.height);
    CGPoint slide;
    if (!transition){
        slide = CGPointMake(self.currentController.view.frame.origin.x, self.whichController.frame.origin.y +50);
    }
    else
    {
         slide = CGPointMake(self.currentController.view.frame.origin.x, self.whichController.frame.origin.y + 1000);
    }
    frame = CGRectMake(slide.x, slide.y, size.width, size.height);
    return frame;
}


- (CGRect)endFrameController
{
    CGRect frame = CGRectZero;
    CGSize size = CGSizeMake(self.currentController.view.frame.size.width, self.currentController.view.frame.size.height);
    CGPoint slide = CGPointMake(self.currentController.view.frame.origin.x, -self.whichController.frame.origin.y);

    frame = CGRectMake(slide.x, slide.y, size.width, size.height);
    return frame;
}




- (void)displayCurrentController:(UIViewController *)controller
{
    self.currentController = controller;
    [self addChildViewController:controller];
    controller.view.frame = [self frameForCurrentController:NO];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];

}

- (void)hideViewController:(UIViewController *)controller
{
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}


- (void)cycleFromViewController: (UIViewController *)oldVC
                toViewController:(UIViewController *)newVc
{
    [oldVC willMoveToParentViewController:nil];
    [self addChildViewController:newVc];
    
    newVc.view.frame = [self frameForCurrentController:YES];
    CGRect endFrame = [self frameForCurrentController:YES];
    
    [self transitionFromViewController:oldVC
                      toViewController:newVc
                              duration:0.25
                               options:0
                            animations:^{
                                newVc.view.frame = oldVC.view.frame;
                                oldVC.view.frame = endFrame;
                            }
                            completion:^(BOOL finished) {
                                self.currentController = newVc;
                                [oldVC removeFromParentViewController];
                                [newVc didMoveToParentViewController:self];
                            }];
}


-(void)choseController
{
    switch (self.whichController.selectedSegmentIndex) {
        case 0:
        {
            
            UIViewController *vc = self.friendsChallengeController;
            if ([vc respondsToSelector:@selector(setMyUser:)]){
                ((FriendsChallengeViewController *)vc).myUser = self.myUser;
            }
            [self cycleFromViewController:self.currentController toViewController:vc];
        }
            break;
            
        case 1:
        {
            UIViewController *vc = self.myChallengeController;
            if ([vc respondsToSelector:@selector(setMyUser:)]){
                ((MyChallengesViewController *)vc).myUser = self.myUser;
            }

            [self cycleFromViewController:self.currentController toViewController:vc];
            
            break;
        }
            
        default:
        {
            
        }
            break;
    }
    
}


#pragma -mark Lazy Instantiation
- (User *)myUser
{
    if (!_myUser){
        NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
        NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
        if (uri){
            NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
            NSError *error;
            _myUser = (id) [context existingObjectWithID:superuserID error:&error];
        }
        
    }
    return _myUser;
}




@end
