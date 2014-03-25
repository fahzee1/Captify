//
//  HistoryDetailViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/28/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"
#import "Challenge.h"

@interface HistoryDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) UIImage *image;


@property (nonatomic, retain)User *myUser;
@property (nonatomic, retain)Challenge *myChallenge;

@end
