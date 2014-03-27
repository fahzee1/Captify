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
#import "SocialFriends.h"
#import "UIImage+Utils.h"
#import "UIColor+HexValue.h"
#import "ShareViewController.h"
#import "UIView+Glow.h"
#import "NEOColorPickerViewController.h"
#import "CMPopTipView.h"
#import "ChallengePicks+Utils.h"
#import "UIImageView+WebCache.h"
#import "AwesomeAPICLient.h"

/*
 mark challenge as done when complete
 
 check if challenge is done on view did
 load
 
 
 */


@interface HistoryDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, NEOColorPickerViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *data;
@property BOOL shareToFacebook;
@property BOOL shareContainerOnScreen;
@property CGPoint priorPoint;
@property NSString *selectedCaption;
@property NSString *selectedUsername;
@property (weak, nonatomic) IBOutlet UILabel *finalCaptionLabel;
@property UIImageView *finalContainerScreen;
@property (strong, nonatomic)UIImage *finalImage;
@property (strong, nonatomic)UIView *imageControls;
@property (strong, nonatomic)UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *captionFontValue;
@property (weak, nonatomic) IBOutlet UIButton *captionColor;
@property (weak, nonatomic) IBOutlet UIStepper *captionFontStepper;
@property (weak, nonatomic) IBOutlet UIButton *captionDoneButton;
@property (strong,nonatomic)CMPopTipView *toolTip;
@property (strong, nonatomic)UIAlertView *confirmCaptionAlert;
@property (strong, nonatomic)UIAlertView *makeCaptionAlert;
@property BOOL pendingRequest;

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
    
    self.navigationItem.title = NSLocalizedString(@"All Captions", @"All captions to showing on final screen");
    
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.finalCaptionLabel.hidden = YES;
    [self.myImageView addSubview:self.finalCaptionLabel];
    self.myImageView.clipsToBounds = YES;
    self.imageControls = [[[NSBundle mainBundle] loadNibNamed:@"shareControls" owner:self options:nil]lastObject];
    self.imageControls.frame = self.myImageView.frame;
    self.imageControls.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self setupImageControlsStyle];
    self.imageControls.hidden = YES;
    [self.view addSubview:self.imageControls];
    
    self.captionFontStepper.value = 25;
    self.captionFontStepper.minimumValue = 8;
    self.captionFontStepper.maximumValue = 45;
   
    self.topLabel.text = self.myChallenge.name;
    
    if (!self.hideSelectButtons){
        self.hideSelectButtons = NO;
    }
    
    
    
    if (self.media_url){
        [self.myImageView setImageWithURL:self.media_url placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fetchUpdates
{
    if (!self.pendingRequest){
        self.pendingRequest = YES;
        [User fetchMediaBlobWithParams:@{@"challenge_id": self.myChallenge.challenge_id}
                                 block:^(BOOL wasSuccessful, id data, NSString *message) {
                                     if (wasSuccessful){
                                         
                                         // get picks
                                         id picks = [data valueForKey :@"picks"];
                                         NSData *jsonString = [picks dataUsingEncoding:NSUTF8StringEncoding];
                                         id json = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:nil];
                                         
                                         for (id pick in json){
                                             NSString *caption = pick[@"answer"];
                                             NSString *player = pick[@"player"];
                                             NSNumber *is_chosen = pick[@"is_chosen"];
                                             NSString *pick_id = pick[@"pick_id"];
                                             
                                             
                                             NSDictionary *params = @{@"player": player,
                                                                       @"context":self.myUser.managedObjectContext,
                                                                       @"is_chosen":is_chosen,
                                                                       @"answer":caption,
                                                                       @"pick_id":pick_id};
                                             
                                             ChallengePicks *pick = [ChallengePicks createChallengePickWithParams:params];
                                             if (pick){
                                                 [self.myChallenge addPicksObject:pick];
                                                 
                                                 NSError *error;
                                                 if (![self.myChallenge.managedObjectContext save:&error]){
                                                     NSLog(@"%@",error);
                                                     
                                                 }
                                                 
                                             }
                                             
                                         }
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.myTable reloadData];
                                         });

                                     }
            
                                 }];
        self.pendingRequest = NO;
        
    }
}

- (void)showShareScreen
{
    
    [self captureFinalImage];
    
    UIViewController *shareVc = [self.storyboard instantiateViewControllerWithIdentifier:@"shareController"];
    if ([shareVc isKindOfClass:[ShareViewController class]]){
        if (self.finalImage){
            ((ShareViewController *)shareVc).shareImage = self.finalImage;
        }
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

                         [self showNextButton];
                        
                         self.toolTip = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"Press and hold for edit options or drag caption", nil)];
                         self.toolTip.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
                         self.toolTip.textColor = [UIColor whiteColor];
                         self.toolTip.hasGradientBackground = NO;
                         self.toolTip.preferredPointDirection = PointDirectionDown;
                         self.toolTip.hasShadow = NO;
                         self.toolTip.has3DStyle = NO;
                         self.toolTip.borderWidth = 0;
                         [self.toolTip presentPointingAtView:self.finalCaptionLabel inView:self.myImageView animated:YES];
                         [self performSelector:@selector(dismissToolTipAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:5.0];
                         
                         
                         
                     }];
    
}


- (void)dismissToolTipAnimated:(BOOL)animated
{
    [self.toolTip dismissAnimated:animated];
    self.toolTip = nil;
}

- (void)setupImageControlsStyle
{
    self.captionDoneButton.titleLabel.font =[UIFont fontWithName:kFontAwesomeFamilyName size:35];
    [self.captionDoneButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
    [self.captionDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.captionColor.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    [self.captionColor setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-pencil"] forState:UIControlStateNormal];
    [self.captionColor setTitleColor:self.finalCaptionLabel.textColor forState:UIControlStateNormal];
    
    self.captionFontStepper.tintColor = [UIColor whiteColor];
    self.captionFontValue .textColor = [UIColor whiteColor];
    
    self.captionFontStepper.value = 25;
    [self.captionFontStepper addTarget:self action:@selector(captionFontChanged) forControlEvents:UIControlEventValueChanged];
    
    
    
}

- (void)showNextButton
{

    if (self.navigationItem.rightBarButtonItem == self.nextButton){
        return;
    }
    
    self.navigationItem.rightBarButtonItem = self.nextButton;
}


- (void)captureFinalImage
{
    [self dismissToolTipAnimated:NO];
    [self.finalCaptionLabel stopGlowing];
    self.finalImage = [self.myImageView convertViewToImage];
 
    
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
    colorPicker.title = NSLocalizedString(@"Caption Color", @"Color to use on caption");
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



- (void)makeCaption
{
    [self showAlertWithTextField];
}


- (void)showAlertWithTextField
{
    self.makeCaptionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Make your own", nil)
                                                    message:NSLocalizedString(@"Dont like any of the captions below? Create your own.", nil) delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Make Caption", nil), nil];
    self.makeCaptionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.makeCaptionAlert show];
}


- (void)selectedCaption:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTable];
    NSIndexPath *indexPath = [self.myTable indexPathForRowAtPoint:buttonPosition];
    ChallengePicks *pick = [self.data objectAtIndex:indexPath.row];
    if (indexPath != nil){
        self.selectedCaption = pick.answer;
        self.selectedUsername = pick.player.username;
    }

    [self.finalCaptionLabel stopGlowing];
    self.hideSelectButtons = YES;
    //[self.myTable reloadData];
    [self setupFinalLabel];
    
}

- (void)captionFontChanged
{
    [self.finalCaptionLabel stopGlowing];
    
    CGRect labelFrame = self.finalCaptionLabel.frame;
    self.finalCaptionLabel.frame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y, 500, 200);

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



- (NSArray *)data
{
    NSSet *picks = self.myChallenge.picks;
    _data = [picks sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
    
    return _data;
}


# pragma -mark Color picker delegate

- (void)colorPickerViewController:(NEOColorPickerBaseViewController *)controller didSelectColor:(UIColor *)color
{
    self.finalCaptionLabel.textColor = color;
    [self.captionColor setTitleColor:color forState:UIControlStateNormal];
    self.imageControls.hidden = YES;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(NEOColorPickerBaseViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@""]){
        return YES;
    }
    
    if ([textField.text length] <= CAPTION_LIMIT){
        return YES;
    }
    else{
        return NO;
    }
    
    
    
}


#pragma -mark Uialertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if user chooses caption. Hide caption select buttons
    // and add caption to the image
    if ([alertView textFieldAtIndex:0].delegate == self){
        [alertView textFieldAtIndex:0].delegate = nil;
    }
    
    if (alertView == self.makeCaptionAlert){
        if (buttonIndex == 1){
            NSString *caption = [alertView textFieldAtIndex:0].text;
            if ([caption length] > 0){
                [self.finalCaptionLabel stopGlowing];
                self.selectedCaption = caption;
                self.hideSelectButtons = YES;
                [self.myTable reloadData];
                [self setupFinalLabel];
            }
        }
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (alertView == self.makeCaptionAlert){
        [alertView textFieldAtIndex:0].delegate = self;
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(100, 0.0, 100, 60)];
    container.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];
    
    NSString *title;
    int count = [self.data count];
    if (count == 0){
        title = NSLocalizedString(@"No captions received yet!", @"Nothing received yet");
    }

    else if  (self.hideSelectButtons || self.hideSelectButtonsMax){
        NSString *string;
        if (count == 1){
            string = [NSString stringWithFormat:@"%lu caption has been sent to this challenge!", (unsigned long)count];
        }
        else{
           string = [NSString stringWithFormat:@"%lu captions have been sent to this challenge!", (unsigned long)count];

        }
        title = NSLocalizedString(string, nil);
    }
    else{
        NSString *string;
        if (count == 1){
            string = [NSString stringWithFormat:@" Choose from %lu caption!", (unsigned long)count];
        }
        else{
            string = [NSString stringWithFormat:@" Choose from %lu captions!", (unsigned long)count];
        }
        title = NSLocalizedString(string, nil);
    }

    UILabel *titleLablel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 300, 50)];
    titleLablel.text = title;
    titleLablel.numberOfLines = 0;
    [titleLablel sizeToFit];
    titleLablel.font = [UIFont boldSystemFontOfSize:12];
    
    if (!self.hideSelectButtonsMax){
        UIButton *makeButton = [[UIButton alloc] initWithFrame:CGRectMake(240.0, -5.0, 100, 50)];
        makeButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
        [makeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-pencil-square-o"] forState:UIControlStateNormal];
        [makeButton addTarget:self action:@selector(makeCaption) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:makeButton];
    }
    
    [container addSubview:titleLablel];
    
    return container;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ChallengePicks *pick = [self.data objectAtIndex:indexPath.row];
    
    if ([pick isKindOfClass:[ChallengePicks class]]){
        
        if ([cell isKindOfClass:[HistoryDetailCell class]]){
            UILabel *captionLabel = ((HistoryDetailCell *)cell).myCaptionLabel;
            UIButton *selectButton = ((HistoryDetailCell *)cell).mySelectButton;
            UILabel *dateLabel = ((HistoryDetailCell *)cell).myDateLabel;
            UIImageView *imageView = ((HistoryDetailCell *)cell).myImageVew;
            
            [pick.player getCorrectProfilePicWithImageView:imageView];
            
            if (pick.player.facebook_user){
                NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small",pick.player.facebook_id];
                NSURL * fbUrl = [NSURL URLWithString:fbString];
                [imageView setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
                
            }
            
            else{
                imageView.image = nil;
                FAImageView *imageView2 = (FAImageView *)imageView;
                [imageView2 setDefaultIconIdentifier:@"fa-user"];
                
            }

    
            NSString *username;
            if (pick.player.username){
                username = [pick.player.username capitalizedString];
            }
            else{
                username = @"User23";
            }
            
            
            if ([pick.is_chosen intValue] == 1){
                captionLabel.text = @"this one was selected.. show trophy badge";
            }
            else{
                 captionLabel.text = [NSString stringWithFormat:@"%@ said \r \r \"%@\"",username,pick.answer];
            }

        
            // set width and height so "sizeToFit" uses those constraints
          
            captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);

            captionLabel.numberOfLines = 0;
            [captionLabel sizeToFit];
            
            dateLabel.text = [pick.timestamp timeAgo];
        
            
            
            [selectButton addTarget:self action:@selector(selectedCaption:) forControlEvents:UIControlEventTouchUpInside];
            
          
            if (self.hideSelectButtonsMax){
                selectButton.hidden = YES;
            }
#warning add trophy icon to selected caption
            
           
            /*
            [((HistoryDetailCell *)cell).mySelectButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:25]];
            [((HistoryDetailCell *)cell).mySelectButton.titleLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"]];
            [((HistoryDetailCell *)cell).mySelectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
             */
            
            
        }
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
