//
//  FriendsChallengeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/7/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "FriendsChallengeViewController.h"
#import "Challenge+Utils.h"
#import "ChallengeViewController.h"
#import "Challenge+Utils.h"
#import "User+Utils.h"
#import "AppDelegate.h"

@interface FriendsChallengeViewController ()

@property NSArray *friendsChallenges;
@property (weak, nonatomic) IBOutlet UITableView *tableBox;

@end

@implementation FriendsChallengeViewController

- (void)dealloc
{
    /*
    if( self.tableBox.delegate == self){
    self.tableBox.delegate = NULL;
    }
    if (self.tableBox.dataSource == self){
        self.tableBox.dataSource = NULL;
    }
     */
}
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
    
    //[User createTestFriendWithName:@"test2" context:self.myUser.managedObjectContext];
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSDictionary *params = @{@"username": username,
                             @"challenge_id":@"0001"};
    
    [Challenge fetchChallengeWithUsernameAndID:params];
    self.tableBox.delegate = self;
    self.tableBox.dataSource = self;
    self.friendsChallenges = [Challenge getChallengesWithUsername:@"test2"
                                                      fromFriends:YES
                                                           getAll:YES
                                                          context:self.myUser.managedObjectContext];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableBox selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
    [super viewDidAppear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.friendsChallenges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Challenge *challenge = [self.friendsChallenges objectAtIndex:indexPath.row];
    cell.textLabel.text = challenge.sender.username;
    
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


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    Challenge *challenge = [self.friendsChallenges objectAtIndex:indexPath.row];
    ChallengeViewController *vc = [[ChallengeViewController alloc] initWithNibName:nil bundle:nil];
    vc.answer = challenge.answer;
    vc.hint = challenge.hint;
    vc.challenge_id = challenge.challenge_id;
    vc.level = [challenge.type intValue];
    vc.title = challenge.name;
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    if ([challenge.active boolValue]){
        [vc.navigationItem setHidesBackButton:YES animated:YES];
        [self.navigationController pushViewController:vc animated:YES];
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
