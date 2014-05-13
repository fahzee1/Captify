//
//  PhoneNumberViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 5/2/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "PhoneNumberViewController.h"
#import "UIColor+HexValue.h"

@interface PhoneNumberViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel2;

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
	
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(tappedCancel)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(tappedSave)];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.title = NSLocalizedString(@"Phone Number", nil);
    
    self.phoneTextField.delegate = self;
    
    [self setupStyles];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.phoneTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
      DLog(@"received memory warning here");
}


- (void)setupStyles
{

    

    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.phoneLabel.textColor = [UIColor whiteColor];
    self.phoneLabel2.textColor = [UIColor whiteColor];
    self.phoneLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:12];
    self.phoneLabel2.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:12];
    
    self.phoneTextField.borderStyle = UITextBorderStyleNone;
    self.phoneTextField.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    self.phoneTextField.layer.opacity = 0.6f;
    self.phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Enter Phone #", nil) attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];


    
}

- (void)tappedCancel
{
    [self.phoneTextField resignFirstResponder];
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(phoneNumberControllerDidTapCancel:)]){
            [self.delegate phoneNumberControllerDidTapCancel:self];
        }
    }
}


- (void)tappedSave
{
    [self.phoneTextField resignFirstResponder];
    if ([self.phoneTextField.text length] == 0){
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Phone number can't be blank", nil)];
        return;
    }
    
    self.phoneNumber = self.phoneTextField.text;
    
    if (self.delegate){
        if ([self.delegate respondsToSelector:@selector(phoneNumberControllerDidTapSave:)]){
            [self.delegate phoneNumberControllerDidTapSave:self];
        }
    }
    
    
    
}


- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    UIAlertView *a = [[UIAlertView alloc]
                      initWithTitle:title
                      message:message
                      delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    [a show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self tappedSave];
    return YES;
}




@end
