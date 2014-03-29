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
    
    [self.previewImage addSubview:self.previewCaption];
    self.previewImage.clipsToBounds = YES;

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
    
    CGRect captionRect = self.previewCaption.frame;
    CGRect nameRect = self.previewChallengeName.frame;
    

    self.previewCaption.text = self.caption;
    self.previewCaption.textAlignment = NSTextAlignmentCenter;
    self.previewCaption.font = [UIFont fontWithName:@"Chalkduster" size:25];
    self.previewCaption.frame = CGRectMake(captionRect.origin.x, captionRect.origin.y, 300, 100);
    self.previewCaption.numberOfLines = 0;
    [self.previewCaption sizeToFit];
    
    self.previewChallengeName.text = self.challengeName;
    self.previewChallengeName.textAlignment = NSTextAlignmentCenter;
    self.previewChallengeName.frame = CGRectMake(nameRect.origin.x, nameRect.origin.y, 300, 100);
    self.previewChallengeName.numberOfLines = 0;
    [self.previewChallengeName sizeToFit];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startedLabelDrag:)];
    press.minimumPressDuration = 0.1;
    
    [self.previewCaption addGestureRecognizer:press];
    self.previewCaption.userInteractionEnabled = YES;
    self.previewImage.userInteractionEnabled = YES;

    
    
    

}
- (void)setupColors
{
       // title of challege
    self.previewChallengeName.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    self.previewChallengeName.textColor = [UIColor whiteColor];

    
    // the phrase
    self.previewCaption.font =  [UIFont fontWithName:@"Optima-ExtraBlack" size:21.5];
    self.previewCaption.textColor = [UIColor colorWithHexString:@"#3498db"];
    
    // the send button
    self.sendButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendButton.layer.cornerRadius = 20.0f;
    
    

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

- (void)startedLabelDrag:(UILongPressGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGPoint point = [gesture locationInView:view.superview];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //[self captionStartedDragging];
        }
            
            break;
        case UIGestureRecognizerStateChanged:
        {
            view.center = point;
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //[self captionStoppedDragging];
        }
            break;
            
        default:
            break;
    }
}




@end
