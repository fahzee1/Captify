//
//  PhoneNumberViewController.h
//  Captify
//
//  Created by CJ Ogbuehi on 5/2/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhoneNumberViewController;

@protocol PhoneNumberDelegate <NSObject>

- (void)phoneNumberControllerDidTapCancel:(PhoneNumberViewController *)controller;
- (void)phoneNumberControllerDidTapSave:(PhoneNumberViewController *)controller;

@end

@interface PhoneNumberViewController : UIViewController

@property (weak)id<PhoneNumberDelegate>delegate;
@property (strong, nonatomic)NSString *phoneNumber;

@end
