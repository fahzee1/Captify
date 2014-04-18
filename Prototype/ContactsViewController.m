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
#import "UIColor+HexValue.h"


#define test 0

@interface ContactsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearch;
@property (strong, nonatomic)NSArray *sections;
@property (strong, nonatomic)NSArray *data;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (strong, nonatomic) NSMutableArray *indexPaths;

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
	

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(tappedCancel)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(tappedDone)];

    /*
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
     */
    
    self.navigationItem.title = NSLocalizedString(@"Select Friends", nil);
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;

    // check server for any new friends since last check
    // if any create them in core data and then refresh table
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.sections = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];

    
    
    
    
    
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

- (void)clearSelections
{
    self.selection = nil;
    self.indexPaths = nil;
    [self.myTable reloadData]; //to clear checks
}

- (void)tappedCancel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ContactViewControllerPressedCancel:)]){
        [self.delegate ContactViewControllerPressedCancel:self];
    }
}

- (void)tappedDone
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ContactViewControllerPressedDone:)]){
        [self.delegate ContactViewControllerPressedDone:self];
    }
    
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
        NSArray *sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:section]]];
        
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
        
        NSArray *sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
        
        User *user = [sectionArray objectAtIndex:indexPath.row];
        if ([user isKindOfClass:[User class]]){
            //((FriendCell *)cell).myFriendScore.text = [user.score stringValue];
            UILabel *username = ((FriendCell *)cell).myFriendUsername;
            username.text = [user.username capitalizedString];
            //((FriendCell *)cell).myFriendPic.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];

        }
        
        if ([self.indexPaths containsObject:indexPath]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
    
    User *user = [sectionArray objectAtIndex:indexPath.row];
    if ([user isKindOfClass:[User class]]){
        
        if ([self.selection containsObject:user.username]){
            [self.selection removeObject:user.username];
        }
        else{
            [self.selection addObject:user.username];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(ContactViewControllerDataChanged:)]){
            [self.delegate ContactViewControllerDataChanged:self];
        }
    }
    
    
    if (![self.indexPaths containsObject:indexPath]){
        [self.indexPaths addObject:indexPath];
        
    }
    else{
        [self.indexPaths removeObject:indexPath];
    }
    
    [self.myTable reloadData];

        
}

- (NSMutableArray *)indexPaths
{
    if (!_indexPaths){
        _indexPaths = [[NSMutableArray alloc] init];
    }
    
    return _indexPaths;
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
        _myFriends = [User fetchFriendsInContext:self.myUser.managedObjectContext getContacts:YES];
        
    }
    return _myFriends;
}

- (NSMutableArray *)selection
{
    if (!_selection){
        _selection = [[NSMutableArray alloc] init];
    }
    
    return _selection;
}

@end
