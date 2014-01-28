//
//  TilesView.h
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TilesView : UIImageView

@property (strong, nonatomic, readonly) NSString* letter;
@property (assign, nonatomic) BOOL isMatched;

-(instancetype)initWithLetter:(NSString*)letter andSideLength:(float)sideLength;
-(void)randomize;
@end
