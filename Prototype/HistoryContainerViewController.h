//
//  HistoryContainerViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 3/7/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol showingMenuDelegate <NSObject>

@optional
- (void)showingMenuFromHome;

@end


@interface HistoryContainerViewController : UIViewController

@property BOOL showSentScreen;

@end
