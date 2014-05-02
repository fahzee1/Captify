//
//  PhoneNumberViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 5/2/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "PhoneNumberViewController.h"

@interface PhoneNumberViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@end

@implementation PhoneNumberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
