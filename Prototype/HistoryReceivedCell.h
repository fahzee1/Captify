//
//  HistoryCell.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/21/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryReceivedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *historyTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *historyImageView;

@property (weak, nonatomic) IBOutlet UIButton *activeButton;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *myUsername;

@end
