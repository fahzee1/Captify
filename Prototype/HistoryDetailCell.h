//
//  HistoryDetailCell.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/3/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myImageVew;

@property (weak, nonatomic) IBOutlet UILabel *myDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCaptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *mySelectButton;

@property (weak, nonatomic) IBOutlet UILabel *myUsername;

@end
