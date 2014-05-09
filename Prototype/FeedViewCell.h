//
//  FeedViewCell.h
//  Captify
//
//  Created by CJ Ogbuehi on 5/8/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedViewCell : UICollectionViewCell

@property (nonatomic, strong)IBOutlet UIImageView *myImageView;
@property (strong, nonatomic)UIImage *image;

@property (strong, nonatomic)IBOutlet UIImageView *senderPic;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *name;

@end
