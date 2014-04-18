//
//  FUISegmentedControl.m
//  FlatUIKitExample
//
//  Created by Alex Medearis on 5/17/13.
//
//

#import "FUISegmentedControl.h"
#import "UIImage+FlatUI.h"
#import "UIColor+FlatUI.h"

@implementation FUISegmentedControl

+ (void)initialize {
    if (self == [FUISegmentedControl class]) {
        FUISegmentedControl *appearance = [self appearance];
        [appearance setCornerRadius:5.0f];
        [appearance setSelectedColor:[UIColor blueColor]];
        [appearance setDeselectedColor:[UIColor darkGrayColor]];
        [appearance setDisabledColor:[UIColor midnightBlueColor]];
        [appearance setDividerColor:[UIColor grayColor]];
        [appearance setSelectedFont:[UIFont fontWithName:@"Arial" size:15.0]];
        [appearance setDeselectedFont:[UIFont fontWithName:@"Arial" size:15.0]];
        [appearance setDisabledFont:[UIFont fontWithName:@"Arial" size:15.0]];
        [appearance setSelectedFontColor:[UIColor whiteColor]];
        [appearance setDeselectedFontColor:[UIColor whiteColor]];
        [appearance setDisabledFontColor:[UIColor whiteColor]];
    }
}

- (void)setDeselectedColor:(UIColor *)deselectedColor {
    _deselectedColor = deselectedColor;
    [self configureFlatSegmentedControl];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [self configureFlatSegmentedControl];
}

- (void)setDisabledColor:(UIColor *)disabledColor {
    _disabledColor = disabledColor;
    [self configureFlatSegmentedControl];
}

- (void)setDividerColor:(UIColor *)dividerColor {
    _dividerColor = dividerColor;
    [self configureFlatSegmentedControl];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self configureFlatSegmentedControl];
}

- (void)setSelectedFont:(UIFont *)selectedFont {
    _selectedFont = selectedFont;
    [self setupFonts];
}

- (void)setSelectedFontColor:(UIColor *)selectedFontColor {
    _selectedFontColor = selectedFontColor;
    [self setupFonts];
}

- (void)setDeselectedFont:(UIFont *)deselectedFont {
    _deselectedFont = deselectedFont;
    [self setupFonts];
}

- (void)setDeselectedFontColor:(UIColor *)deselectedFontColor {
    _deselectedFontColor = deselectedFontColor;
    [self setupFonts];
}

- (void)setDisabledFont:(UIFont *)disabledFont {
    _disabledFont = disabledFont;
    [self setupFonts];
}

- (void)setDisabledFontColor:(UIColor *)disabledFontColor {
    _disabledFontColor = disabledFontColor;
    [self setupFonts];
}

- (void)setupFonts {
    
    NSDictionary *selectedAttributesDictionary;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowOffset:CGSizeZero];
        [shadow setShadowColor:[UIColor clearColor]];
        selectedAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self.selectedFontColor,
                                        NSForegroundColorAttributeName,
                                        shadow,
                                        NSShadowAttributeName,
                                        self.selectedFont,
                                        NSFontAttributeName,
                                        nil];
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // Pre-iOS6 methods
        selectedAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self.selectedFontColor,
                                        UITextAttributeTextColor,
                                        [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
                                        UITextAttributeTextShadowColor,
                                        [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                        UITextAttributeTextShadowOffset,
                                        self.selectedFont,
                                        UITextAttributeFont,
                                        nil];
#pragma clang diagnostic pop
    }
    
    [self setTitleTextAttributes:selectedAttributesDictionary forState:UIControlStateSelected];
    
    NSDictionary *deselectedAttributesDictionary;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS6+ methods
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowOffset:CGSizeZero];
        [shadow setShadowColor:[UIColor clearColor]];
        deselectedAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          self.deselectedFontColor,
                                          NSForegroundColorAttributeName,
                                          shadow,
                                          NSShadowAttributeName,
                                          self.deselectedFont,
                                          NSFontAttributeName,
                                          nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // pre-iOS6 methods
        deselectedAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          self.deselectedFontColor,
                                          UITextAttributeTextColor,
                                          [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
                                          UITextAttributeTextShadowColor,
                                          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                          UITextAttributeTextShadowOffset,
                                          self.deselectedFont,
                                          UITextAttributeFont,
                                          nil];
#pragma clang diagnostic pop
    }

    [self setTitleTextAttributes:deselectedAttributesDictionary forState:UIControlStateNormal];

    NSDictionary *disabledAttributesDictionary;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
        // iOS6+ methods
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowOffset:CGSizeZero];
        [shadow setShadowColor:[UIColor clearColor]];
        disabledAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                self.disabledFontColor,
                NSForegroundColorAttributeName,
                shadow,
                NSShadowAttributeName,
                self.disabledFont,
                NSFontAttributeName,
                nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // pre-iOS6 methods
        disabledAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                self.disabledFontColor,
                UITextAttributeTextColor,
                [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
                UITextAttributeTextShadowColor,
                [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                UITextAttributeTextShadowOffset,
                self.disabledFont,
                UITextAttributeFont,
                nil];
#pragma clang diagnostic pop
    }

    [self setTitleTextAttributes:disabledAttributesDictionary forState:UIControlStateDisabled];
}

- (void)configureFlatSegmentedControl {
    UIImage *selectedBackgroundImage = [UIImage buttonImageWithColor:self.selectedColor
                                                      cornerRadius:self.cornerRadius
                                                       shadowColor:[UIColor clearColor]
                                                      shadowInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *deselectedBackgroundImage = [UIImage buttonImageWithColor:self.deselectedColor
                                                           cornerRadius:self.cornerRadius
                                                            shadowColor:[UIColor clearColor]
                                                           shadowInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *disabledBackgroundImage = [UIImage buttonImageWithColor:self.disabledColor
                                                          cornerRadius:self.cornerRadius
                                                           shadowColor:[UIColor clearColor]
                                                          shadowInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    UIImage *dividerImage = [[UIImage imageWithColor:self.dividerColor cornerRadius:0] imageWithMinimumSize:CGSizeMake(1, 1)];
    
    [self setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:deselectedBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:disabledBackgroundImage forState:UIControlStateDisabled barMetrics:UIBarMetricsDefault];
    [self setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setDividerImage:dividerImage forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setDividerImage:dividerImage forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

}

@end