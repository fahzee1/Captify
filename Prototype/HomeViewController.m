//
//  HomeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"


@interface HomeViewController ()

@property (nonatomic, retain)NSManagedObject *myUser;

@end

@implementation HomeViewController

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
}

-(void)viewDidAppear:(BOOL)animated
{
    //if user not logged in segue to login screen
       if (![[NSUserDefaults standardUserDefaults] valueForKey:@"logged2"]){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
       }else{
           [self fetchSuperUserWithName:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]];
       }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logout:(UIButton *)sender {
    [self performSegueWithIdentifier:@"segueToLogin" sender:self];
}


#pragma -mark Core Data
- (void)fetchSuperUserWithName:(NSString *)name
{
    
    // Request Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    // Filter if I want
    request.predicate = [NSPredicate predicateWithFormat:@"(User.super_user = 1) and (User.username = %@)",name];
    
    // Sort if i want
    //request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
    //                                                                                 ascending:YES
    //                                                                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSError *error;
    NSArray *fetch = [self.managedObjectContext executeFetchRequest:request error:&error];
    self.myUser = [fetch firstObject];
    NSLog(@"%@",self.myUser);
}

#pragma -mark Segues
- (IBAction)unwindToHomeController:(UIStoryboardSegue *)segue
{    
}

@end
