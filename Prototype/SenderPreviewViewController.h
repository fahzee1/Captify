//
//  SenderPreviewViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SenderPreviewDelegate <NSObject>

- (void)previewscreenDidMoveBack;

@end


@interface SenderPreviewViewController : UIViewController

@property(nonatomic,strong)NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *phrase;
@property (weak) id <SenderPreviewDelegate> delegate;


@end

