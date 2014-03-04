//
//  DraggablePhraseLabel.h
//  Prototype
//
//  Created by CJ Ogbuehi on 2/26/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DraggableCaptionDelegate <NSObject>

- (void)CaptionStartedDragging;
- (void)CaptionStoppedDragging;

@end

@interface DraggableCaption : UILabel


@property (weak)id<DraggableCaptionDelegate>delegate;

@end
