//
//  MenuViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/13/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum{
    MenuHomeScreen = 1000,
    MenuHistoryScreen,
    MenuFriendsScreen,
    MenuSettingsScreen,
    MenuFeedScreen,
    
} MenuScreenConstants;

typedef enum{
    MenuHomeIcon = 2000,
    MenuHistoryIcon,
    MenuFeedIcon,
    MenuSettingIcon,
    MenuFriendsIcon,
 
    
} MenuScreenIcon;


@protocol MenuDelegate <NSObject>

- (void)menuShowingAnotherScreen;

@end

@interface MenuViewController : UIViewController

@property (weak)id <MenuDelegate>delegate;

- (void)setupColors;

- (void)updateCurrentScreen:(MenuScreenConstants)screen;

- (void)showScreen:(MenuScreenConstants)screen;

@end
