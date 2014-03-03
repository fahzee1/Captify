//
//  HistoryDetailCell.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/3/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryDetailCell.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"

@implementation HistoryDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.mySelectButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
        self.mySelectButton.titleLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"];
        


    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.mySelectButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
        self.mySelectButton.titleLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"];


    }
    
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
