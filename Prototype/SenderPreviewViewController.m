//
//  SenderPreviewViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "SenderPreviewViewController.h"
#import "UIColor+HexValue.h"

@interface SenderPreviewViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIPickerView *phraseCountPicker;
@property (strong, nonatomic)NSArray *phraseCountNumbers;
@end

@implementation SenderPreviewViewController

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
    self.phraseCountPicker.delegate = self;
    self.phraseCountPicker.dataSource = self;
    
    [self setupStyles];
    
    self.name = @"Guess what im eating";
    self.phrase = @"Nothing stupid";
    self.phraseCountNumbers = [[NSArray alloc] initWithObjects:@"One Word",@"Two Words",@"Three Words" ,nil];
    
    self.topLabel.text = self.name;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupStyles
{
    self.topLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#3498db"] CGColor];
    self.topLabel.textColor = [UIColor whiteColor];
    self.topLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    
    // the send button
    self.sendButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    


}


#pragma -mark UIpicker delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.phraseCountNumbers objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
        {
            NSLog(@"one word chosen");
        }
            break;
            
        case 1:
        {
               NSLog(@"two word chosen");
        }
            break;
        case 2:
        {
               NSLog(@"three word chosen");
        }
            break;
            
        default:
            break;
    }
    
}

@end
