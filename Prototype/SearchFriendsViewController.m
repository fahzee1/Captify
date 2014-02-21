//
//  SearchFriendsViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import "User.h"
#import "FriendTableViewCell.h"

@interface SearchFriendsViewController ()<UISearchDisplayDelegate,UISearchBarDelegate>
@property (strong, nonatomic)NSArray *data;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;

@end

@implementation SearchFriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // uiviewcontroller come with searchDisplayControllers
    
    self.mySearchBar.delegate = self;
    [self.mySearchBar becomeFirstResponder];
    
    self.data = [NSArray arrayWithObjects:@"apple",@"bannana",@"cookies",@"donald",@"dogs", nil];

    
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



- (void)searchForText:(NSString *)searchText
{
    //NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
    //NSString *searchAttribute = @"username";
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat,searchAttribute,searchText];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchText];
    self.searchFetchRequest.predicate = predicate;
    //NSError *error;
    //self.filteredList = [self.myUser.managedObjectContext executeFetchRequest:self.searchFetchRequest error:&error];
    self.filteredList = [self.data filteredArrayUsingPredicate:predicate];
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


#pragma -mark UISEARCH delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchForText:searchString];
    [self.tableView reloadData];
    
    return YES;
}




- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //My Solution: remove the searchBar away from current super view,
    //then add it as subview again to the tableView
    UISearchBar *searchBar = controller.searchBar;
    UIView *superView = searchBar.superview;
    if (![superView isKindOfClass:[UITableView class]]) {
        NSLog(@"Error here");
        [searchBar removeFromSuperview];
        [self.tableView addSubview:searchBar];
    }
    NSLog(@"%@", NSStringFromClass([superView class]));
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"cancel clicked");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchForText:searchText];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [self.filteredList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell;
   

    if ([[self.filteredList objectAtIndex:indexPath.row] isKindOfClass:[User class]]){
        static NSString *CellIdentifier = @"searchFriendsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];


        User *user = [self.filteredList objectAtIndex:indexPath.row];
        
        ((FriendTableViewCell*)cell).myFriendUsername.text = user.username;
        ((FriendTableViewCell *)cell).myFriendScore.text = [user.score stringValue];
        ((FriendTableViewCell *)cell).myFriendPic.image = [UIImage imageNamed:@"profile-placeholder"];
    }
    else{
        static NSString *CellIdentifier = @"friendCells";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        ((FriendTableViewCell*)cell).myFriendUsername.text  = [self.filteredList objectAtIndex:indexPath.row];
        ((FriendTableViewCell *)cell).myFriendPic.image = [UIImage imageNamed:@"profile-placeholder"];

        
        }
       
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
