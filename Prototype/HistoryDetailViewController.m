//
//  HistoryDetailViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/28/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryDetailViewController.h"
#import "HistoryDetailCell.h"
#import "NSString+FontAwesome.h"
#import "FAImageView.h"
#import "UIFont+FontAwesome.h"
#import "NSDate+TimeAgo.h"
#import "UIView+Screenshot.h"
#import "FacebookFriends.h"
#import "UIImage+Utils.h"
#import "UIColor+HexValue.h"
#import "ShareViewController.h"
#import "UIView+Glow.h"
#import "NEOColorPickerViewController.h"
#import "CMPopTipView.h"



@interface HistoryDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, NEOColorPickerViewControllerDelegate>

@property NSArray *data;
@property BOOL hideSelectButtons;
@property BOOL shareToFacebook;
@property BOOL shareContainerOnScreen;
@property CGPoint priorPoint;
@property NSString *selectedCaption;
@property (weak, nonatomic) IBOutlet UILabel *finalCaptionLabel;
@property UIImageView *finalContainerScreen;
@property UIImage *finalImage;
@property (strong, nonatomic)UIView *imageControls;
@property (strong, nonatomic)UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *captionFontValue;
@property (weak, nonatomic) IBOutlet UIButton *captionColor;
@property (weak, nonatomic) IBOutlet UIStepper *captionFontStepper;
@property (weak, nonatomic) IBOutlet UIButton *captionDoneButton;
@property (strong,nonatomic)CMPopTipView *toolTip;

@end

@implementation HistoryDetailViewController

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
    
    //self.navigationItem.rightBarButtonItem = nextButton;
    
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.finalCaptionLabel.hidden = YES;
    [self.myImageView addSubview:self.finalCaptionLabel];
    self.myImageView.clipsToBounds = YES;
    self.data = @[@"This is one long example of a caption that could be used",@"Buggy woggy its late right now",@"Wait a minute dont you hear me",@"She wanna have what you have",@"Yolo son!",@"Her ass cant handle it",@"Its alright, its Ok!"];
    self.imageControls = [[[NSBundle mainBundle] loadNibNamed:@"shareControls" owner:self options:nil]lastObject];
    self.imageControls.frame = self.myImageView.frame;
    self.imageControls.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self setupImageControlsStyle];
    self.imageControls.hidden = YES;
    [self.view addSubview:self.imageControls];
    
    self.captionFontStepper.value = 25;
    self.captionFontStepper.minimumValue = 8;
    self.captionFontStepper.maximumValue = 45;
   
    
    if (!self.hideSelectButtons){
        self.hideSelectButtons = NO;
    }
    

    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (void)showShareScreen
{
    UIViewController *shareVc = [self.storyboard instantiateViewControllerWithIdentifier:@"shareController"];
    if ([shareVc isKindOfClass:[ShareViewController class]]){
        ((ShareViewController *)shareVc).myImageView.image = self.myImageView.image;
        [self.navigationController pushViewController:shareVc animated:YES];
        
    }
}




- (void)setupFinalLabel
{

    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startedLabelDrag:)];
    press.minimumPressDuration = 0.1;
    
    UILongPressGestureRecognizer *controls = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCaption:)];
    controls.minimumPressDuration = 0.7;
    
    [press requireGestureRecognizerToFail:controls];
    
    
    self.finalCaptionLabel.text = self.selectedCaption;
    self.finalCaptionLabel.font = [UIFont fontWithName:@"Chalkduster" size:25];
    if ([self.finalCaptionLabel.text length] > 15){
        self.finalCaptionLabel.numberOfLines = 0;
        [self.finalCaptionLabel sizeToFit];
    }
    self.finalCaptionLabel.textAlignment = NSTextAlignmentCenter;
    self.finalCaptionLabel.alpha = 0;
    [self.finalCaptionLabel addGestureRecognizer:press];
    [self.finalCaptionLabel addGestureRecognizer:controls];
    self.finalCaptionLabel.hidden = NO;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.finalCaptionLabel.alpha = 1;
                         [self.finalCaptionLabel startGlowingWithColor:[UIColor whiteColor] intensity:0.9];
                     } completion:^(BOOL finished) {
                        self.finalCaptionLabel.userInteractionEnabled = YES;
                         self.myImageView.userInteractionEnabled = YES;
                         [self toggleNextButton];
                         
                         self.toolTip = [[CMPopTipView alloc] initWithMessage:@"Press and hold for edit options or drag caption"];
                         self.toolTip.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
                         self.toolTip.textColor = [UIColor whiteColor];
                         self.toolTip.hasGradientBackground = NO;
                         self.toolTip.preferredPointDirection = PointDirectionDown;
                         self.toolTip.hasShadow = NO;
                         self.toolTip.has3DStyle = NO;
                         self.toolTip.borderWidth = 1.0;
                         [self.toolTip presentPointingAtView:self.finalCaptionLabel inView:self.myImageView animated:YES];
                         [self performSelector:@selector(dismissToolTip) withObject:nil afterDelay:3.0];
                         
                         
                     }];
    
}


- (void)dismissToolTip
{
    [self.toolTip dismissAnimated:YES];
    self.toolTip = nil;
}

- (void)setupImageControlsStyle
{
    self.captionDoneButton.titleLabel.font =[UIFont fontWithName:kFontAwesomeFamilyName size:35];
    [self.captionDoneButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
    [self.captionDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.captionColor.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    [self.captionColor setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-pencil"] forState:UIControlStateNormal];
    [self.captionColor setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.captionFontStepper.tintColor = [UIColor whiteColor];
    self.captionFontValue .textColor = [UIColor whiteColor];
    [self.captionColor setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.captionFontStepper.value = 25;
    [self.captionFontStepper addTarget:self action:@selector(captionFontChanged) forControlEvents:UIControlEventValueChanged];
    
    
    
}

- (void)toggleNextButton
{
    if (!self.navigationItem.rightBarButtonItem){
        self.navigationItem.rightBarButtonItem = self.nextButton;
        }
    else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}


- (void)captureFinalImage
{
    // hide controls
    
    self.finalImage = [self.view convertViewToImage];
    //UIImageWriteToSavedPhotosAlbum(self.finalImage, nil, nil, nil);
    
}


- (IBAction)tappedDone:(id)sender {
    if (!self.imageControls.hidden){
         self.imageControls.hidden = YES;
    }
}


- (IBAction)pickColor:(UIButton *)sender {
    NEOColorPickerViewController *colorPicker = [[NEOColorPickerViewController alloc] init];
    colorPicker.delegate = self;
    colorPicker.selectedColor = [UIColor blackColor];
    colorPicker.title = @"Caption color";
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:colorPicker];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)tappedCaption:(UITapGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.imageControls.hidden){
                self.imageControls.hidden = NO;
            }

        }
            
            break;
        case UIGestureRecognizerStateChanged:
        {
          
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)startedLabelDrag:(UILongPressGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    CGPoint point = [gesture locationInView:view.superview];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //[self captionStartedDragging];
             [self.finalCaptionLabel stopGlowing];
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



- (void)selectedCaption:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTable];
    NSIndexPath *indexPath = [self.myTable indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil){
        self.selectedCaption = [self.data objectAtIndex:indexPath.row];
    }

    UIAlertView *confirm = [[UIAlertView alloc]
                            initWithTitle:@"Confirm"
                            message:[NSString stringWithFormat:@"Are you sure you want this caption? '%@' ",[self.data objectAtIndex:indexPath.row]]
                            delegate:self
                            cancelButtonTitle:@"Not sure"
                            otherButtonTitles:@"I'm sure", nil];
    [confirm show];
    
}

- (void)captionFontChanged
{
    [self.finalCaptionLabel stopGlowing];
    self.finalCaptionLabel.font = [UIFont fontWithName:@"Chalkduster" size:self.captionFontStepper.value];
    self.captionFontValue.text = [NSString stringWithFormat:@"%d", (int)self.captionFontStepper.value];
    

}

/*
- (void)setupShareStyles
{
    self.finalShareContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.finalShareContainer.frame = CGRectMake(self.finalShareContainer.frame.origin.x, self.finalShareContainer.frame.origin.y + self.finalShareContainer.frame.size.height, self.finalShareContainer.frame.size.width , self.finalShareContainer.frame.size.height);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFacebookLabel:)];
    tap.numberOfTapsRequired = 1;
    
    self.shareFacebookLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    self.shareFacebookLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"];
    self.shareFacebookLabel.textColor = [UIColor whiteColor];
    self.shareFacebookLabel.userInteractionEnabled = YES;
    [self.shareFacebookLabel addGestureRecognizer:tap];
    
    
    self.shareImageButton.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] colorWithAlphaComponent:0.5f];
    self.shareImageButton.layer.cornerRadius = 10.0f;
    
}


- (void)captionStartedDragging
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.finalShareContainer.frame = CGRectMake(self.finalShareContainer.frame.origin.x, self.finalShareContainer.frame.origin.y + self.finalShareContainer.frame.size.height, self.finalShareContainer.frame.size.width , self.finalShareContainer.frame.size.height);
                     }];
}

- (void)captionStoppedDragging
{
    [UIView animateWithDuration:1.0
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:0
                     animations:^{
                         self.finalShareContainer.frame = CGRectMake(self.finalShareContainer.frame.origin.x, self.finalShareContainer.frame.origin.y - self.finalShareContainer.frame.size.height, self.finalShareContainer.frame.size.width , self.finalShareContainer.frame.size.height);
                     } completion:nil];
    

}
 */


# pragma -mark Color picker delegate

- (void)colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color
{
    self.finalCaptionLabel.textColor = color;
    self.imageControls.hidden = YES;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(NEOColorPickerBaseViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark Uialertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if user chooses caption. Hide caption select buttons
    // and add caption to the image
    
    if (buttonIndex == 0){
        self.selectedCaption = nil;
    }
    
    else if (buttonIndex == 1){
        self.hideSelectButtons = YES;
        [self.myTable reloadData];
        [self setupFinalLabel];
    }
}

#pragma -mark Uitableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.hideSelectButtons){
        return [NSString stringWithFormat:@"%lu captions", (unsigned long)[self.data count]];
    }
    else{
        return [NSString stringWithFormat:@" Choose from %lu captions!", (unsigned long)[self.data count]];
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell isKindOfClass:[HistoryDetailCell class]]){
        UILabel *captionLabel = ((HistoryDetailCell *)cell).myCaptionLabel;
        UIButton *selectButton = ((HistoryDetailCell *)cell).mySelectButton;
        UILabel *dateLabel = ((HistoryDetailCell *)cell).myDateLabel;
        
        ((HistoryDetailCell *)cell).myImageVew.image = nil;
        FAImageView *imageView = ((FAImageView *)((HistoryDetailCell *)cell).myImageVew);
        [imageView setDefaultIconIdentifier:@"fa-user"];
        
        captionLabel.text = [self.data objectAtIndex:indexPath.row];
    
        // set width and height so "sizeToFit" uses those constraints
      
        captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);

        captionLabel.numberOfLines = 0;
        [captionLabel sizeToFit];
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        dateLabel.text = [date timeAgo];
    
        
        
        [selectButton addTarget:self action:@selector(selectedCaption:) forControlEvents:UIControlEventTouchUpInside];
        if (self.hideSelectButtons){
            selectButton.hidden = YES;
        }
       
        /*
        [((HistoryDetailCell *)cell).mySelectButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:25]];
        [((HistoryDetailCell *)cell).mySelectButton.titleLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"]];
        [((HistoryDetailCell *)cell).mySelectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
         */
        
        
    }
    return cell;
    
}



- (UIBarButtonItem *)nextButton
{
    if (!_nextButton){
       _nextButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-right"] style:UIBarButtonItemStylePlain target:self action:@selector(showShareScreen)];
        [_nextButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25]} forState:UIControlStateNormal];
        [_nextButton setTintColor:[UIColor greenColor]];

    }
    return  _nextButton;
}



- (UIView *)imageControls
{
    if (!_imageControls){
        _imageControls = [[[NSBundle mainBundle] loadNibNamed:@"shareControls" owner:self options:nil]lastObject];
        [self setupImageControlsStyle];
    }
    return _imageControls;
}





@end
