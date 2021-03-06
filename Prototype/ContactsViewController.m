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
#import "UIImageView+WebCache.h"

#define test 0

@interface ContactsViewController ()<SWTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearch;
@property (strong, nonatomic)NSArray *sections;
@property (strong, nonatomic)NSArray *data;
@property (strong, nonatomic)NSArray *recents;
@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (strong, nonatomic) NSMutableArray *indexPaths;
@property (strong, nonatomic) UIView *errorContainerView;

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
    
    if (!self.onlyShowFriends){
        self.navigationItem.title = NSLocalizedString(@"Select Friends", nil);
    }
    else{
        self.navigationItem.title = NSLocalizedString(@"Contacts", nil);
    }
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;

    // check server for any new friends since last check
    // if any create them in core data and then refresh table
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    if (self.onlyShowFriends){
        self.sections = [NSArray arrayWithObjects:@"",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];

    }
    else{
        self.sections = [NSArray arrayWithObjects:@"Recents",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];

    }
    
    
    if ([self.myFriends count] == 0){
        [self.myTable removeFromSuperview];
        [self.view addSubview:self.errorContainerView];
    }
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    self.searchFetchRequest = nil;
    self.myUser = nil;
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
       DLog(@"received memory warning here");
}


- (void)sendTextInvite
{
   
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[INVITE_TEXT] applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    [self presentViewController:activityVC animated:YES completion:nil];
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


- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
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
        if ([self.sections containsObject:@"Recents"]){
            return [self.sections subarrayWithRange:NSMakeRange(1, [self.sections count] -1)];
        }
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
        if (section > 0){
            // regular table
            NSArray *sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:section]]];
            
            return [sectionArray count];
        }
        else{
            // recents table
            return [self.recents count];
            
        }
    }
    else{
        return [self.filteredList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.myTable){
        NSArray *sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
        if ([sectionArray count] > 0){
            User *user = [sectionArray objectAtIndex:indexPath.row];
            if (user.display_name){
                return 60;
            }
        }

    }
    
    return 48;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"friendCells";
    if (tableView == self.myTable){
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        ((FriendCell *)cell).rightUtilityButtons = [self rightButtons];
        ((FriendCell *)cell).delegate = self;
        
        if (indexPath.section == 0){
            // recents
            id friend = [self.recents objectAtIndex:indexPath.row];
            if ([friend isKindOfClass:[NSString class]]){
                // contact
                
                if ([(NSString *)friend isEqualToString:@"Team-Captify"]){
                    ((FriendCell *)cell).myFriendPic.image = [UIImage imageNamed:CAPTIFY_LOGO];
                     ((FriendCell *)cell).myFriendUsername.text = [[friend stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
                    
                }
                else{
                    ((FriendCell *)cell).myFriendPic.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
                    ((FriendCell *)cell).myFriendUsername.text = [[friend stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
                }
                
                
       
                
            }
            else if ([friend isKindOfClass:[NSDictionary class]]){
                // facebook
                
                NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",friend[@"facebook_id"]];
                NSURL * fbUrl = [NSURL URLWithString:fbString];
                ((FriendCell *)cell).myFriendUsername.text = [(NSString *)friend[@"username"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
                [((FriendCell *)cell).myFriendPic sd_setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]];
        
            }
            
            UILabel *displayName = ((FriendCell *)cell).myFriendDisplayName;
            displayName.text = nil;
        
            
        }
        // regular table
        else{
            
            NSArray *sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
            
            User *user = [sectionArray objectAtIndex:indexPath.row];
            if ([user isKindOfClass:[User class]]){
                //((FriendCell *)cell).myFriendScore.text = [user.score stringValue];
                UILabel *username = ((FriendCell *)cell).myFriendUsername;
                UILabel *displayName = ((FriendCell *)cell).myFriendDisplayName;
                username.text = [user displayName];
                
                if (user.display_name){
                    displayName.text = user.display_name;
                }
                else{
                    displayName.text = @"";
                }
                
                
                
                //[[user.username stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
                //[cell.contentView sendSubviewToBack:((FriendCell *)cell).myFriendPic];
                //((FriendCell *)cell).myFriendPic.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];

            }
            
            [user getCorrectProfilePicWithImageView:((FriendCell *)cell).myFriendPic];
            
            if ([self.indexPaths containsObject:indexPath]){
                 cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else{
                 cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }

    }
    // search table not main table
    else{
        
        cell = [self.myTable dequeueReusableCellWithIdentifier:cellIdentifier];
        //((FriendTableViewCell*)cell).myFriendUsername.text = user.username;
         ((FriendCell*)cell).myFriendUsername.text =[self.filteredList objectAtIndex:indexPath.row];
        ((FriendCell *)cell).myFriendScore.text = @"176";
        ((FriendCell *)cell).myFriendPic.image = [UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER];
        
    }
   
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.onlyShowFriends){
        if (indexPath.section == 0){
            // recents
            id friend = [self.recents objectAtIndex:indexPath.row];
            NSString *username;
            if ([friend isKindOfClass:[NSString class]]){
                username = friend;
            }
            else if ([friend isKindOfClass:[NSDictionary class]]){
                username = friend[@"username"];
            }
            
            
            if ([self.selection containsObject:username]){
                [self.selection removeObject:username];
            }
            else{
                [self.selection addObject:username];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(ContactViewControllerDataChanged:)]){
                [self.delegate ContactViewControllerDataChanged:self];
            }
            
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (![self.indexPaths containsObject:indexPath]){
                [self.indexPaths addObject:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            else{
                [self.indexPaths removeObject:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
            }
            
            [self.myTable reloadData];

            
            
            
        }
        // regular
        else{
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
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (![self.indexPaths containsObject:indexPath]){
                [self.indexPaths addObject:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            else{
                [self.indexPaths removeObject:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;

            }
            
            [self.myTable reloadData];
        }

    }
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

#pragma -mark SWTableviewcell delegate
// click event on left utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    
}

// click event on right utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (index == 0){
        DLog(@"delete");
        NSIndexPath *indexPath = [self.myTable indexPathForCell:cell];
        NSArray *sectionArray = [self.myFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.username beginswith[c] %@",[self.sections objectAtIndex:indexPath.section]]];
        
        User *user = [sectionArray objectAtIndex:indexPath.row];
        if (user){
            user.is_deleted = [NSNumber numberWithBool:YES];
            NSError *error;
            [user.managedObjectContext save:&error];
            self.myFriends = nil;
            [self.myTable reloadData];
        }

        
    }
    
}

// utility button open/close event
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    
}

// prevent multiple cells from showing utilty buttons simultaneously
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

// prevent cell(s) from displaying left/right utility buttons
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    NSIndexPath *path = [self.myTable indexPathForCell:cell];
    if (path.section == 0){
        // if recents no
        return NO;
    }
    return YES;
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

- (NSArray *)recents
{
    if (!_recents){
        if (self.onlyShowFriends){
            return @[];
        }
        _recents = [[NSUserDefaults standardUserDefaults] valueForKey:@"recents"];
        
    }
    return _recents;
}

- (NSMutableArray *)selection
{
    if (!_selection){
        _selection = [[NSMutableArray alloc] init];
    }
    
    return _selection;
}


- (UIView *)errorContainerView
{
    if (!_errorContainerView){
        _errorContainerView = [[UIView alloc] initWithFrame:self.myTable.frame];
        _errorContainerView.layer.cornerRadius = 10;
        _errorContainerView.layer.masksToBounds = YES;
        _errorContainerView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        
        CGRect containerFrame = _errorContainerView.frame;
        containerFrame.size.width -= 15;
        containerFrame.size.height -= 300;
        containerFrame.origin.y += 150;
        containerFrame.origin.x += 7;
        _errorContainerView.frame = containerFrame;
        
        
        UILabel *errorLabel = [[UILabel alloc] init];
        errorLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        errorLabel.text = @"None of your contacts are on Captify! Tell some friends to Join!";
        errorLabel.numberOfLines = 0;
        [errorLabel sizeToFit];
        errorLabel.textColor = [UIColor whiteColor];
        errorLabel.frame = CGRectMake(15, 50, _errorContainerView.frame.size.width-20, 100);
        
        UIButton *invite = [UIButton buttonWithType:UIButtonTypeSystem];
        invite.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
        invite.layer.cornerRadius = 10;
        invite.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:20];
        [invite setTitle:NSLocalizedString(@"Invite", nil) forState:UIControlStateNormal];
        [invite setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
        invite.frame = CGRectMake(50, _errorContainerView.bounds.size.height - 134, 200, 50);
        [invite addTarget:self action:@selector(sendTextInvite) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (!IS_IPHONE5){
            CGRect inviteFrame = invite.frame;
            containerFrame.origin.y -= 40;
            containerFrame.size.height += 25;
            inviteFrame.origin.y += 100;
            _errorContainerView.frame = containerFrame;
            invite.frame = inviteFrame;
            
        }
        
        [_errorContainerView addSubview:errorLabel];
        [_errorContainerView addSubview:invite];
        
    }
    
    return _errorContainerView;
}

@end
