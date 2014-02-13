//
//  FriendTableViewCell.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/13/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *myFriendUsername;
@property (nonatomic, weak) IBOutlet UILabel *myFriendScore;
@property (nonatomic, weak) IBOutlet UIImageView *myFriendPic;
@end
