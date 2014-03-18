//
//  FriendsViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/12/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ContactsViewController.h"
#import "FriendCell.h"
#import "AppDelegate.h"
#import "TWTSideMenuViewController.h"
#import "FAImageView.h"


#define test 0

@interface ContactsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearch;
@property (strong, nonatomic)NSArray *sections;
@property (strong, nonatomic)NSArray *data;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;

@end

@implementation ContactsViewController

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
	


    // check server for any new friends since last check
    // if any create them in core data and then refresh table
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.sections = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
    
    self.data = [NSArray arrayWithObjects:@"apples",@"bannas",@"chips", @"dogs",@"apllsl",@"yolo",@"spagetti",@"finally",@"zappo",@"zebra",@"appspkksksksss", nil];
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    self.searchFetchRequest = nil;
    self.myUser = nil;
    
    [super didReceiveMemoryWarning];
 
    // Dispose of any resources that can be recreated.
}


- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

- (void)showAddFriendScreen
{
    [self performSegueWithIdentifier:@"addFriends" sender:self];
}



-(NSFetchRequest *)searchFetchRequest
{
    if(!_searchFetchRequest){
        _searchFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
        _searchFetchRequest.sortDescriptors = sortDescriptors;
    
    }
    return _searchFetchRequest;
}

/*
- (NSArray *)data
{
    if (!_data){
        _data =[User fetchFriendsInContext:self.myUser.managedObjectContext];
    }
    return _data;
}
*/
#pragma -mark Lazy inst
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

- (NSArray *)myFriends
{
    if (!_myFriends){
        _myFriends = [User fetchFriendsInContext:self.myUser.managedObjectContext];
        
    }
    return _myFriends;
}

#pragma -mark UITABLEVIEW delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.myTable){
        return [self.sections count];
    }
    else{
        return 1;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.myTable){
        return self.sections;
    }
    else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.myTable){
        return  index;
    }
    else{
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.myTable){
        return [self.sections objectAtIndex:section];
    }
    else{
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.myTable){
        NSArray *sectionArray;
        if (test){
            sectionArray =  [self.data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",[self.sections objectAtIndex:section]]];
        }
        else{
            sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:section]]];
        }
        
        return [sectionArray count];
    }
    else{
        return [self.filteredList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"friendCells";
    if (tableView == self.myTable){
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        NSArray *sectionArray;
        if (test){
                sectionArray = [self.data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
            
            ((FriendCell *)cell).myFriendScore.text = @"176";
            ((FriendCell *)cell).myFriendUsername.text = [sectionArray objectAtIndex:indexPath.row];
            ((FriendCell *)cell).myFriendPic.image = nil;
            FAImageView *imageView = ((FAImageView *)((FriendCell *)cell).myFriendPic);
            [imageView setDefaultIconIdentifier:@"fa-user"];
        
            
        }
        // not testing
        else{
            
            sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
            
            User *user = [sectionArray objectAtIndex:indexPath.row];
            if ([user isKindOfClass:[User class]]){
                ((FriendCell *)cell).myFriendScore.text = [user.score stringValue];
                ((FriendCell *)cell).myFriendUsername.text = user.username;
                ((FriendCell *)cell).myFriendPic.image = nil;
                FAImageView *imageView = ((FAImageView *)((FriendCell *)cell).myFriendPic);
                [imageView setDefaultIconIdentifier:@"fa-user"];

            }


        }
      
    }
    // search table not main table
    else{
        
        cell = [self.myTable dequeueReusableCellWithIdentifier:cellIdentifier];
        //((FriendTableViewCell*)cell).myFriendUsername.text = user.username;
         ((FriendCell*)cell).myFriendUsername.text =[self.filteredList objectAtIndex:indexPath.row];
        ((FriendCell *)cell).myFriendScore.text = @"176";
        ((FriendCell *)cell).myFriendPic.image = [UIImage imageNamed:@"profile-placeholder"];
        
    }
   
    return cell;
}

@end
