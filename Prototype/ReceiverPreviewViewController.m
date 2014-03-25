//
//  ReceiverPreviewViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ReceiverPreviewViewController.h"
#import "UIColor+HexValue.h"
#import "TWTSideMenuViewController.h"

@interface ReceiverPreviewViewController ()
@property (weak, nonatomic) IBOutlet UILabel *previewPhraseTitle;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation ReceiverPreviewViewController

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
    // character limit of about 30 should be fine
    // for challenge name/title
    
    [super viewDidLoad];

    [self setupColors];
    [self setupOutlets];
    
    
	// Do any additional setup after loading the view.
}

- (void)dealloc
{
    self.image = nil;
    self.previewImage = nil;
}

- (void)setupOutlets
{
    self.previewImage.image = self.image;
    self.previewCaption.text = self.caption;
    self.previewChallengeName.text = self.challengeName;
    
    

}
- (void)setupColors
{
       // title of challege
    self.previewChallengeName.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    self.previewChallengeName.textColor = [UIColor whiteColor];
    self.previewChallengeName.layer.backgroundColor = [[UIColor colorWithHexString:@"#3498db"] CGColor];
    
    // phrase title "Your phase"
    self.previewPhraseTitle.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:25];
    self.previewPhraseTitle.layer.backgroundColor = [[UIColor colorWithHexString:@"#e74c3c"] CGColor];
    self.previewPhraseTitle.textColor = [UIColor whiteColor];
    
    // the phrase
    self.previewCaption.font =  [UIFont fontWithName:@"Optima-ExtraBlack" size:21.5];
    self.previewCaption.textColor = [UIColor colorWithHexString:@"#3498db"];
    
    // the send button
    self.sendButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    

}

- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendRecieverPick:(UIButton *)sender {
    
    
}


@end
