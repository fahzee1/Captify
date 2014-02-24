//
//  AddFriendsViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "User.h"
#import "FacebookFriends.h"



@interface AddFriendsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic)NSArray *contactsArray;
@property (strong, nonatomic)NSArray *facebookFriendsArray;

@end

@implementation AddFriendsViewController

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
    // Do any additional setup after loading the view from its nib.
    

    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSArray *)facebookFriendsArray
{
    if (!_facebookFriendsArray){
        FacebookFriends *f = [[FacebookFriends alloc] init];
        [f allFriends:^(BOOL wasSuccessful, NSArray *data) {
            _facebookFriendsArray = data;
            [self.myTableView reloadData];
        }];
    }
    return  _facebookFriendsArray;
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
    
    return [self.facebookFriendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"addFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.facebookFriendsArray objectAtIndex:indexPath.row][@"name"];
    //User *user = [self.contactsArray objectAtIndex:indexPath.row];
    
    //((FriendTableViewCell*)cell).myFriendUsername.text = user.username;
    //((FriendTableViewCell *)cell).myFriendScore.text = [user.score stringValue];
    //((FriendTableViewCell *)cell).myFriendPic.image = [UIImage imageNamed:@"profile-placeholder"];
    
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




@end
