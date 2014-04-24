//
//  SenderPreviewViewController.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Utils.h"

#ifdef USE_GOOGLE_ANALYTICS
    #import "GAITrackedViewController.h"
#endif



@protocol SenderPreviewDelegate <NSObject>

- (void)previewscreenDidMoveBack;
- (void)previewscreenFinished;

@end


#ifdef USE_GOOGLE_ANALYTICS
    @interface SenderPreviewViewController : GAITrackedViewController
#else
    @interface SenderPreviewViewController : UIViewController
#endif


@property (nonatomic, retain)User *myUser;
@property(nonatomic,strong)NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (weak) id <SenderPreviewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;

@end

