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
#import "ChallengePicks+Utils.h"

#ifdef USE_GOOGLE_ANALYTICS
    #import "GAITrackedViewController.h"
    #import "GAI.h"
    #import "GAIDictionaryBuilder.h"
#endif


#ifdef USE_GOOGLE_ANALYTICS
    @interface HistoryDetailViewController : GAITrackedViewController
#else
    @interface HistoryDetailViewController : UIViewController
#endif

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) UIImage *image;
@property BOOL hideSelectButtons;
@property BOOL hideSelectButtonsMax;
@property (nonatomic, retain)User *myUser;
@property (nonatomic, retain)Challenge *myChallenge;
@property (nonatomic, strong)NSURL *mediaURL;
@property (strong, nonatomic)ChallengePicks *myPick;

@property BOOL sentHistory;


@end
