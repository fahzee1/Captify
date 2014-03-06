//
//  ShareViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 3/4/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ShareViewController.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "UIColor+HexValue.h"

@interface ShareViewController ()

@property (weak, nonatomic) IBOutlet UIButton *myShareButton;
@property (weak, nonatomic) IBOutlet UILabel *myFacebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *myInstagramLabel;
@property (weak, nonatomic) IBOutlet UIView *shareContainer;
@property (weak, nonatomic) IBOutlet UILabel *facebookDisplayLabel;

@property (weak, nonatomic) IBOutlet UILabel *instagramDisplayLabel;

@property BOOL shareFacebook;
@property BOOL shareInstagram;

@end

@implementation ShareViewController

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
    self.shareFacebook = NO;
    self.shareInstagram = NO;
    [self setupShareStyles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupShareStyles
{
    self.shareImageView.image = self.shareImage;
    
    self.shareContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    self.myShareButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    [self.myShareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapFB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFacebook)];
    tapFB.numberOfTapsRequired = 1;
    tapFB.numberOfTouchesRequired = 1;
    
    self.myFacebookLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    self.myFacebookLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"];
    self.myFacebookLabel.textColor = [UIColor whiteColor];
    self.myFacebookLabel.userInteractionEnabled = YES;
    [self.myFacebookLabel addGestureRecognizer:tapFB];
    
    UITapGestureRecognizer *tapIG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedInstagram)];
    tapIG.numberOfTapsRequired = 1;
    tapIG.numberOfTouchesRequired = 1;
    
    self.myInstagramLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    self.myInstagramLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-instagram"];
    self.myInstagramLabel.textColor = [UIColor whiteColor];
    self.myInstagramLabel.userInteractionEnabled = YES;
    [self.myInstagramLabel addGestureRecognizer:tapIG];
}


- (void)tappedFacebook
{
    self.shareFacebook = !self.shareFacebook;
    if (self.shareFacebook){
        self.myFacebookLabel.textColor = [UIColor colorWithHexString:@"#3B5998"];
        self.facebookDisplayLabel.textColor = [UIColor colorWithHexString:@"#3B5998"];
    }
    else{
        self.myFacebookLabel.textColor = [UIColor whiteColor];
        self.facebookDisplayLabel.textColor = [UIColor whiteColor];
    }
}

- (void)tappedInstagram
{
    self.shareInstagram = !self.shareInstagram;
    if (self.shareInstagram){
        self.myInstagramLabel.textColor = [UIColor colorWithHexString:@"#3f729b"];
        self.instagramDisplayLabel.textColor = [UIColor colorWithHexString:@"#3f729b"];

    }
    else{
        self.myInstagramLabel.textColor = [UIColor whiteColor];
        self.instagramDisplayLabel.textColor = [UIColor whiteColor];
    }
}



@end
