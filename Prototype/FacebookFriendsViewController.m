//
//  AddFriendsViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/20/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "FacebookFriendsViewController.h"
#import "User.h"
#import "SocialFriends.h"
#import "AddFriendCell.h"
#import "FAImageView.h"
#import "UIImageView+WebCache.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"




@interface FacebookFriendsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic)NSArray *contactsArray;
@property (strong, nonatomic)NSArray *sections;
@property (strong, nonatomic)SocialFriends *friend;

@end

@implementation FacebookFriendsViewController

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

    
    self.sections = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setFacebookFriendsArray:(NSArray *)facebookFriendsArray
{
    _facebookFriendsArray = facebookFriendsArray;
    [self.myTableView reloadData];
}

- (SocialFriends *)friend
{
    if (!_friend){
        _friend = [[SocialFriends alloc] init];
    }
    return _friend;
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return  self.sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray;
    sectionArray =  [self.facebookFriendsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name beginswith[c] %@",[self.sections objectAtIndex:section]]];
    
    return [sectionArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"addFriendCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // sort alphabetically
    NSArray *sectionArray;
    sectionArray =  [self.facebookFriendsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
    
    NSString *picURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",[sectionArray objectAtIndex:indexPath.row][@"fbook_id"]];
    NSURL *url = [NSURL URLWithString:picURL];
    [((AddFriendCell *)cell).addFriendPic setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
  
    ((AddFriendCell *)cell).addFriendName.text = [sectionArray objectAtIndex:indexPath.row][@"name"];
    
    
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // params 'title', 'message', 'to'
    
    NSArray *sectionArray;
    sectionArray =  [self.facebookFriendsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
    
    NSString *name = [sectionArray objectAtIndex:indexPath.row][@"name"];
    NSString *fb_id = [sectionArray objectAtIndex:indexPath.row][@"fbook_id"];
    
    
    [self.friend inviteFriendWithID:fb_id
                              title:[NSString stringWithFormat:@"Invite %@",name]
                            message:@"Come up with something catchy"
                              block:^(BOOL wasSuccessful, FBWebDialogResult result) {
                                  if (wasSuccessful){
                                      NSLog(@"%u",result);
                                  }
                              }];
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
