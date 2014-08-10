//
//  FriendTableViewCell.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/13/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

// incase of issue with table cells content views and i forget
// drag a cell from ib instead of using default

@interface FriendCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *myFriendUsername;
@property (nonatomic, weak) IBOutlet UILabel *myFriendScore;
@property (nonatomic, weak) IBOutlet UIImageView *myFriendPic;

@property (weak, nonatomic) IBOutlet UILabel *myFriendDisplayName;

@end
