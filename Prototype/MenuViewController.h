//
//  MenuViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/13/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MenuDelegate <NSObject>

- (void)menuShowingAnotherScreen;

@end

@interface MenuViewController : UIViewController

@property (weak)id <MenuDelegate>delegate;

@end
