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
#import "UIImageView+WebCache.h"
#import "AwesomeAPICLient.h"
#import "CJPopup.h"
#import "ParseNotifications.h"
#import <MessageUI/MessageUI.h>
#import "FUIAlertView.h"
#import "GPUImage.h"
#import "UISlider+FlatUI.h"
#import "UIStepper+FlatUI.h"
#import "UIColor+FlatUI.h"


/*
 mark challenge as done when complete
 
 check if challenge is done on view did
 load
 
 
 */

#define SHARE_CONTROLS_CONTAINER 6466
#define FINAL_CAPTION_TAG 3433

@interface HistoryDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, NEOColorPickerViewControllerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray *data;
@property BOOL shareToFacebook;
@property BOOL shareContainerOnScreen;
@property CGPoint priorPoint;
@property CGPoint currentPoint;
@property NSString *selectedCaption;
@property NSString *selectedUsername;
@property ChallengePicks *selectedPick;
@property (weak, nonatomic) IBOutlet UILabel *finalCaptionLabel;
@property UIImageView *finalContainerScreen;
@property (strong, nonatomic)UIImage *finalImage;
@property (strong, nonatomic)UIView *imageControls;
@property (strong, nonatomic)UIBarButtonItem *nextButton;


@property (weak, nonatomic) IBOutlet UILabel *captionSizeTitle;
@property (weak, nonatomic) IBOutlet UILabel *captionSizeValue;
@property (weak, nonatomic) IBOutlet UIButton *captionColor;

@property (weak, nonatomic) IBOutlet UILabel *captionColorTitle;
@property (weak, nonatomic) IBOutlet UIStepper *captionSizeStepper;
@property (weak, nonatomic) IBOutlet UIButton *captionDoneButton;
@property (weak, nonatomic) IBOutlet UIButton *captionRotateButton;

@property (weak, nonatomic) IBOutlet UIButton *captionRotateReverseButton;
@property (weak, nonatomic) IBOutlet UILabel *captionRotateTitle;
@property (weak, nonatomic) IBOutlet UILabel *captionAlphaTitle;
@property (weak, nonatomic) IBOutlet UILabel *captionAlphaValue;
@property (weak, nonatomic) IBOutlet UISlider *captionAlphaSlider;

@property (weak, nonatomic) IBOutlet UILabel *captionFontTitle;
@property (weak, nonatomic) IBOutlet UIButton *captionFontButton;


@property (weak, nonatomic) IBOutlet UILabel *captionImageFilterLabel;

@property (weak, nonatomic) IBOutlet UIButton *captionImageFilterButton;
@property (strong, nonatomic)UILabel *errorLabel;
@property (strong, nonatomic)UIButton *errorMakeCaptionButton;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (weak, nonatomic) IBOutlet UIButton *splitCaptionButton;
@property (weak, nonatomic) IBOutlet UILabel *splitCaptionLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong,nonatomic)CMPopTipView *toolTip;
@property (strong, nonatomic)UIAlertView *confirmCaptionAlert;
@property (strong, nonatomic)UIAlertView *makeCaptionAlert;
@property (strong, nonatomic)UIButton *makeButton;
@property (strong,nonatomic)NSArray *activeFonts;
@property (strong, nonatomic)NSString *currentFont;
@property (strong,nonatomic)NSArray *activeFilters;
@property (strong, nonatomic)NSString *currentFilter;
@property (strong, nonatomic)NSIndexPath *previousCellIndex;
@property (strong, nonatomic)UITableViewCell *previousCell;

@property BOOL pendingRequest;
@property BOOL makeButtonVisible;
@property BOOL captionMoved;
@property int errorCount;
@property BOOL captionIsSplit;
@property BOOL fromColorPicker; // flag so we dont scroll screen down coming from color picker

// filters
@property (strong ,nonatomic)GPUImageGrayscaleFilter *grayScaleFilter;
@property (strong ,nonatomic)GPUImageSepiaFilter *sepiaFilter;
@property (strong ,nonatomic)GPUImageSketchFilter *sketchFilter;
@property (strong ,nonatomic)GPUImageToonFilter *toonFilter;
@property (strong ,nonatomic)GPUImagePosterizeFilter *posterizeFilter;
@property (strong ,nonatomic)GPUImageAmatorkaFilter *amatoraFilter;
@property (strong ,nonatomic)GPUImageMissEtikateFilter *etikateFilter;





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
    
    self.captionIsSplit = NO;
    
    self.activeFonts = [NSArray arrayWithObjects:CAPTIFY_FONT_GOODDOG,
                                                 CAPTIFY_FONT_GLOBAL_BOLD,
                                                 CAPTIFY_FONT_LEMONDROP,
                                                 CAPTFIY_FONT_KILOGRAM,
                                                 CAPTFIY_FONT_AGENTORANGE,
                                                 CAPTFIY_FONT_TRIBBON,
                                                 CAPTIFY_FONT_LEAGUE,
                                                  nil];


    
    self.activeFilters = [NSArray arrayWithObjects:
                          [NSNumber numberWithInt:CAPTIFY_FILTER_AMATORKA],
                          [NSNumber numberWithInt:CAPTIFY_FILTER_MISS_ETIKATE],
                          [NSNumber numberWithInt:CAPTIFY_FILTER_SEPIA],
                          [NSNumber numberWithInt:CAPTIFY_FILTER_GRAYSCALE],
                          [NSNumber numberWithInt:CAPTIFY_FILTER_POSTERIZE],
                          [NSNumber numberWithInt:CAPTIFY_FILTER_SKETCH],
                          [NSNumber numberWithInt:CAPTIFY_FILTER_ORIGINAL],nil];


    self.currentFont = CAPTIFY_FONT_CAPTION;
    
    self.navigationItem.title = NSLocalizedString(@"Challenge", @"All captions to showing on final screen");
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-folder-o"] style:UIBarButtonItemStylePlain target:self action:@selector(popToHistory)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;

    
    [self setupStylesAndMore];
    
    // we will have an image from the filesystem on view did load if
    // we sent the challenge, if not we download it from url
    if (!self.image){
        [self downloadImage];
    }
    else{
        self.progressView.hidden = YES;
        self.myImageView.image = self.image;
    }
    
    // shows error message if no captions
    if ([self.data count] == 0){
        [self.scrollView addSubview:self.errorLabel];
    }
    
    if ([self.data count] > 0){
        int height = 93 * (int)[self.data count]; //cell height times amount of cells to add to scrollview
        int scrollHeight = [UIScreen mainScreen].bounds.size.height + height;
        self.scrollView.contentSize = CGSizeMake(320, scrollHeight+70);
        CGRect tableRect = self.myTable.frame;
        tableRect.size.height += height;
        self.myTable.frame = tableRect;
    }
    else{
         self.scrollView.contentSize = CGSizeMake(320, 670);
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    

    
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (USE_GOOGLE_ANALYTICS){
        if (self.hideSelectButtonsMax){
             self.screenName = @"Inactive Detail Screen";
        }
        else{
             self.screenName = @"Active Detail Screen";
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.fromColorPicker){
        if (IS_IPHONE5){
            if ([self.data count] > 0){
                CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
                [self.scrollView setContentOffset:bottomOffset animated:YES];

            }
            
        }
        else{
            CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
            [self.scrollView setContentOffset:bottomOffset animated:YES];
        }
        
        self.fromColorPicker = NO;
    }
    
    

    
    if (!self.sentHistory){
        if (![self.myPick.challenge.sender.username isEqualToString:self.myUser.username]){
            if ([self.myPick.is_chosen intValue] == 1 && self.hideSelectButtonsMax){
                if ([self.myPick.first_open intValue] == 1){
                    UIImage *image = [self.view snapshotView:self.view];
                    CJPopup *pop = [[CJPopup alloc] initWithFrame:self.view.frame];
                    [pop showSuccessBlur2WithImage:image sender:self.myChallenge.sender.username];
                    
                    self.myPick.first_open = [NSNumber numberWithBool:NO];
                    NSError *error;
                    if (![self.myPick.managedObjectContext save:&error]){
                        DLog(@"%@",error);
                    }
            
                }
                
                

                

                
                
            }
        }
    }
    
    
    
    [self fetchUpdates];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    self.grayScaleFilter = nil;
    self.sepiaFilter = nil;
    self.sketchFilter = nil;
    self.toonFilter = nil;
    self.posterizeFilter = nil;
    self.amatoraFilter = nil;
    self.etikateFilter = nil;
    
    self.imageControls = nil;
    
    DLog(@"received memory warning here");

}




- (void)popToHistory
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)fetchUpdates
{
    if (!self.pendingRequest){
        self.pendingRequest = YES;
        [User fetchMediaBlobWithParams:@{@"challenge_id": self.myChallenge.challenge_id}
                                 block:^(BOOL wasSuccessful, id data, NSString *message) {
                                     if (wasSuccessful){
                                         
                                         
                                         if (!self.myChallenge.image_path){
                                             
                                             if (data[@"media64"]){
                                                 NSString *base64Media = data[@"media64"];
                                                 NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Media options:0];
                                                 self.myImageView.image = [UIImage imageWithData:data];
                                             }

                                             else if (data[@"media_url"]){
                                                 NSString *url = data[@"media_url"];
                                                 self.myChallenge.image_path = url;
                                                 self.mediaURL = [NSURL URLWithString:self.myChallenge.image_path];
                                                 [self downloadImage];
                                                 
                                                 NSError *error;
                                                 [self.myChallenge.managedObjectContext save:&error];
                                             }
                                             
                                        }
                                         
                                         // get picks
                                         id picks = [data valueForKey :@"picks"];
                                         NSData *jsonString = [picks dataUsingEncoding:NSUTF8StringEncoding];
                                         id json = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:nil];
                                         
                                         for (id pick in json){
                                             DLog(@"%@",pick);
                                             NSString *caption = pick[@"answer"];
                                             NSString *player = pick[@"player"];
                                             NSNumber *is_chosen = pick[@"is_chosen"];
                                             NSString *pick_id = pick[@"pick_id"];
                                             NSString *facebook_id = pick[@"facebook_id"];
                                             NSNumber *is_facebook = pick[@"is_facebook"];
                                             
                                             NSMutableDictionary *params = [@{@"player": player,
                                                                       @"context":self.myUser.managedObjectContext,
                                                                       @"is_chosen":is_chosen,
                                                                       @"answer":caption,
                                                                       @"pick_id":pick_id} mutableCopy];
                                             
                                             if (facebook_id && is_facebook){
                                                 params[@"is_facebook"] = is_facebook;
                                                 params[@"facebook_id"] = facebook_id;
                                             }
                                             
                                             ChallengePicks *pick = [ChallengePicks createChallengePickWithParams:params];
                                             if (pick){
                                                 [self.myChallenge addPicksObject:pick];
                                                 
                                                 NSError *error;
                                                 if (![self.myChallenge.managedObjectContext save:&error]){
                                                     DLog(@"%@",error);
                                                     
                                                 }
                                                 
                                             }
                                             
                                         }
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if ([self.data count] > 0){
                                                 [self.errorLabel removeFromSuperview];
                                                 self.errorLabel = nil;
                                             }
                                             
                                             [self.myTable reloadData];
                                         });

                                     }
            
                                 }];
        self.pendingRequest = NO;
        
    }
}



- (void)setupStylesAndMore
{
     self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
    self.makeButtonVisible = YES;
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    self.finalCaptionLabel.hidden = YES;
    self.finalCaptionLabel.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    
    [self.myImageView addSubview:self.finalCaptionLabel];
    self.myImageView.clipsToBounds = YES;
    
    self.imageControls.frame = self.myImageView.frame;
    self.imageControls.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [self setupImageControlsStyle];
    self.imageControls.hidden = YES;
    [self.scrollView addSubview:self.imageControls];
    
    self.captionSizeStepper.value = 35;
    self.captionSizeStepper.minimumValue = 8;
    self.captionSizeStepper.maximumValue = 100;
    
    self.captionAlphaSlider.value = 1.0;
    self.captionAlphaSlider.maximumValue = 1.0;
    self.captionAlphaSlider.minimumValue = 0.2;
    
    self.myTable.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.myTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.topLabel.text = [self.myChallenge.name capitalizedString];
    self.topLabel.textColor = [UIColor whiteColor];
    self.topLabel.layer.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] CGColor];
    self.topLabel.layer.borderWidth = 2;
    self.topLabel.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    self.topLabel.layer.cornerRadius = 5;
    if ([self.myChallenge.name length] > 30){
        self.topLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:15];
    }
    else{
        self.topLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:17];
    }
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.numberOfLines = 0;
    [self.topLabel sizeToFit];
    self.topLabel.frame = CGRectMake(self.topLabel.frame.origin.x,
                                     self.topLabel.frame.origin.y,
                                     [UIScreen mainScreen].bounds.size.width,
                                     self.topLabel.frame.size.height);
    
    CGRect labelFrame = self.topLabel.frame;
    labelFrame.size.height += 10;
    self.topLabel.frame = labelFrame;
    
    self.currentPoint = self.finalCaptionLabel.center;
    self.priorPoint = self.finalCaptionLabel.center;
    
    if (!self.hideSelectButtons){
        self.hideSelectButtons = NO;
    }
    
    self.retryButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:15];
    [self.retryButton setTitle:NSLocalizedString(@"Image Not Available", nil)  forState:UIControlStateNormal];
    [self.retryButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_DARK_GREY] forState:UIControlStateNormal];
    self.retryButton.userInteractionEnabled = NO;
    //[self.retryButton addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
    self.retryButton.hidden = YES;
    self.retryButton.center = self.myImageView.superview.center;
    [self.myImageView addSubview:self.retryButton];
    self.myImageView.userInteractionEnabled = YES;
    
}


- (void)checkForCaptions
{
}

- (void)downloadImage
{
    if (self.mediaURL){
        self.retryButton.hidden = YES;
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
        [self.myImageView setImageWithURL:self.mediaURL
                         placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    self.progressView.hidden = NO;
                                    long percent = receivedSize / expectedSize;
                                    self.progressView.progress = (float)percent;
                                     
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    self.progressView.hidden = YES;
                                    if (!image){
                                        double delayInSeconds = 2.0;
                                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                             self.retryButton.hidden = NO;
                                        });
                
                                    }
                                    else{
                                        self.image = image;
                                    }
                                }];
        
    }

}

- (void)showShareScreen
{
    
    [self captureFinalImage];
    
    UIViewController *shareVc = [self.storyboard instantiateViewControllerWithIdentifier:@"shareController"];
    if ([shareVc isKindOfClass:[ShareViewController class]]){
        if (self.finalImage){
            ((ShareViewController *)shareVc).shareImage = self.finalImage;
            ((ShareViewController *)shareVc).myChallenge = self.myChallenge;
            ((ShareViewController *)shareVc).myPick = self.selectedPick;
            ((ShareViewController *)shareVc).selectedCaption = self.finalCaptionLabel.text;
        }
        [self.navigationController pushViewController:shareVc animated:YES];
        
    }
}

- (void)reset
{
    self.captionMoved = NO;
    
    for (UIView *view in self.myImageView.subviews){
        if ([view isKindOfClass:[UILabel class]] && view.tag != FINAL_CAPTION_TAG){
            [view removeFromSuperview];
        }
    }
    
    self.captionIsSplit = NO;
}


- (void)setupFinalLabel
{
    [self reset];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startedLabelDrag:)];
    press.minimumPressDuration = 0.05;
    
    UILongPressGestureRecognizer *controls = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCaption:)];
    controls.minimumPressDuration = 0.7;
    
    [press requireGestureRecognizerToFail:controls];
    

    if (!CGPointEqualToPoint(self.finalCaptionLabel.center, self.priorPoint)){
        self.finalCaptionLabel.center = self.priorPoint;
    }
    self.finalCaptionLabel.text = [self.selectedCaption capitalizedString];
    self.finalCaptionLabel.font = [UIFont fontWithName:CAPTIFY_FONT_CAPTION size:CAPTIFY_CAPTION_SIZE];
    /*
    if ([self.finalCaptionLabel.text length] > 15){
        self.finalCaptionLabel.numberOfLines = 0;
        [self.finalCaptionLabel sizeToFit];
    }*/
     
    self.finalCaptionLabel.numberOfLines = 0;
    [self.finalCaptionLabel sizeToFit];

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
                        
                         NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                         int count = [[defaults valueForKey:@"challengeToolTip"] intValue];
                         
                         if (count < 2){
                             self.toolTip = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"Hold for edit options or drag caption", nil)];
                             self.toolTip.backgroundColor = [UIColor whiteColor];
                             self.toolTip.textColor = [UIColor blackColor];
                             self.toolTip.textFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
                             self.toolTip.titleFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
                             self.toolTip.hasGradientBackground = NO;
                             self.toolTip.preferredPointDirection = PointDirectionDown;
                             self.toolTip.dismissTapAnywhere = YES;
                             self.toolTip.hasShadow = NO;
                             self.toolTip.has3DStyle = NO;
                             self.toolTip.borderWidth = 0;
                             [self.toolTip autoDismissAnimated:YES atTimeInterval:5.0];
                             [self.toolTip presentPointingAtView:self.finalCaptionLabel inView:self.myImageView animated:YES];
                             
                             [defaults setValue:[NSNumber numberWithInt:count +1] forKey:@"challengeToolTip"];
                             
                             
                             double delayInSeconds = 5.3    ;
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                 CMPopTipView *toolTip = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"Or create your own", nil)];
                                 toolTip.backgroundColor = [UIColor whiteColor];
                                 toolTip.textColor = [UIColor blackColor];
                                 toolTip.textFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
                                 toolTip.titleFont = [UIFont fontWithName:CAPTIFY_FONT_LEAGUE size:20];
                                 toolTip.hasGradientBackground = NO;
                                 toolTip.preferredPointDirection = PointDirectionDown;
                                 toolTip.dismissTapAnywhere = YES;
                                 toolTip.hasShadow = NO;
                                 toolTip.has3DStyle = NO;
                                 toolTip.borderWidth = 0;
                                 [toolTip autoDismissAnimated:YES atTimeInterval:5.0];
                                 [toolTip presentPointingAtView:self.makeButton inView:self.view animated:YES];

                             });
                             
                         }
                         
                         //[self performSelector:@selector(dismissToolTipAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:5.0];
                         
                         
                         
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
    self.captionColorTitle.textColor = self.finalCaptionLabel.textColor;
    self.captionColorTitle.text = NSLocalizedString(@"Color", nil);
    
    
    self.captionRotateButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.captionRotateButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-repeat"] forState:UIControlStateNormal];
    [self.captionRotateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.captionRotateButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] forState:UIControlStateHighlighted];
    self.captionRotateReverseButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.captionRotateReverseButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-undo"] forState:UIControlStateNormal];
    [self.captionRotateReverseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.captionRotateReverseButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] forState:UIControlStateHighlighted];

    self.captionRotateTitle.textColor = [UIColor whiteColor];
    self.captionRotateTitle.text = NSLocalizedString(@"Rotate", nil);
    
    
    self.captionAlphaTitle.textColor = [UIColor whiteColor];
    self.captionAlphaValue.textColor = [UIColor whiteColor];
    //self.captionAlphaSlider.tintColor = [UIColor whiteColor];
    [self.captionAlphaSlider configureFlatSliderWithTrackColor:[UIColor silverColor]
                                                 progressColor:self.finalCaptionLabel.textColor
                                              thumbColorNormal:[UIColor whiteColor]
                                         thumbColorHighlighted:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE]];
    
    
    self.captionSizeTitle.textColor = [UIColor whiteColor];
    self.captionSizeTitle.text = NSLocalizedString(@"Size", nil);
    self.captionSizeStepper.tintColor = [UIColor whiteColor];
    self.captionSizeValue .textColor = [UIColor whiteColor];
    self.captionSizeStepper.value = 25;
    [self.captionSizeStepper addTarget:self action:@selector(captionSizeChanged) forControlEvents:UIControlEventValueChanged];
    
    
    self.captionFontTitle.textColor = [UIColor whiteColor];
    self.captionFontTitle.text = NSLocalizedString(@"Font", nil);
    self.captionFontButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    [self.captionFontButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-font"] forState:UIControlStateNormal];
    [self.captionFontButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.captionFontButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] forState:UIControlStateHighlighted];
    
    self.captionImageFilterLabel.textColor = [UIColor whiteColor];
    self.captionImageFilterLabel.text = NSLocalizedString(@"Filter", nil);
    self.captionImageFilterButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    [self.captionImageFilterButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-picture-o"] forState:UIControlStateNormal];
    [self.captionImageFilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.captionImageFilterButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] forState:UIControlStateHighlighted];
    
    
    self.splitCaptionButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    [self.splitCaptionButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-th-large"] forState:UIControlStateNormal];
    [self.splitCaptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.splitCaptionLabel.textColor = [UIColor whiteColor];
    self.splitCaptionLabel.text = NSLocalizedString(@"Split", nil);

    
    
    
    
    
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
    //self.imageControls.hidden = YES;
    for (UIView *view in self.scrollView.subviews){
        if (view.tag == SHARE_CONTROLS_CONTAINER){
            view.hidden = YES;
        }
    }
    
}


- (IBAction)tappedFont:(UIButton *)sender {
    [self.finalCaptionLabel stopGlowing];
    
    static NSInteger fontIndex = 0;
    NSInteger total = [self.activeFonts count];

    if (!self.captionIsSplit){
        
        NSString *font = [self.activeFonts objectAtIndex:fontIndex];
        self.currentFont = font;
        self.finalCaptionLabel.font = [UIFont fontWithName:font size:self.captionSizeStepper.value];
        self.finalCaptionLabel.numberOfLines = 0;
        [self.finalCaptionLabel sizeToFit];
        
        CGRect frame = self.finalCaptionLabel.frame;
        frame.size.width = self.finalCaptionLabel.superview.bounds.size.width;
        self.finalCaptionLabel.frame = frame;
        
        
        fontIndex += 1;
        
        if (fontIndex >= total){
            fontIndex = 0;
        }
    }
    else{
        NSString *font = [self.activeFonts objectAtIndex:fontIndex];
        self.currentFont = font;
        for (UIView * view in self.myImageView.subviews){
            if ([view isKindOfClass:[UILabel class]]){
                ((UILabel *)view).font = [UIFont fontWithName:font size:self.captionSizeStepper.value];
                ((UILabel *)view).numberOfLines = 0;
                [((UILabel *)view) sizeToFit];
                ((UILabel *)view).textAlignment = NSTextAlignmentCenter;
                
                CGSize size = view.superview.bounds.size;
                
                CGRect spiltFrame = ((UILabel *)view).frame;
                //spiltFrame.size = CGSizeMake(spiltFrame.size.width + 20, spiltFrame.size.height);
                spiltFrame.size = CGSizeMake(size.width/2, spiltFrame.size.height);
                ((UILabel *)view).frame = spiltFrame;
                
                if (view.tag == FINAL_CAPTION_TAG){
                    CGRect frame = ((UILabel *)view).frame;
                    frame.size.width = ((UILabel *)view).superview.bounds.size.width;
                    ((UILabel *)view).frame = frame;

                }

            }
        }
        
        
        fontIndex += 1;
        
        if (fontIndex >= total){
            fontIndex = 0;
        }

    }
    
}


- (IBAction)tappedImageFilter:(UIButton *)sender {
    
    static NSInteger filterIndex = 0;
    NSInteger total = [self.activeFilters count];
    
    id filter = [self.activeFilters objectAtIndex:filterIndex];
    switch ([filter intValue]) {
            
        case CAPTIFY_FILTER_GRAYSCALE:
        {
            UIImage *image = [self.grayScaleFilter imageByFilteringImage:self.image];
            self.myImageView.image = image;

        }
            break;
        
        case CAPTIFY_FILTER_POSTERIZE:
        {
            UIImage *image = [self.posterizeFilter imageByFilteringImage:self.image];
            self.myImageView.image = image;

        }
            break;
        case CAPTIFY_FILTER_SEPIA:
        {
            UIImage *image = [self.sepiaFilter imageByFilteringImage:self.image];
            self.myImageView.image = image;

        }
            break;
        case CAPTIFY_FILTER_SKETCH:
        {
            UIImage *image = [self.sketchFilter imageByFilteringImage:self.image];
            self.myImageView.image = image;

        }
            break;
        case CAPTIFY_FILTER_TOON:
        {
            UIImage *image = [self.toonFilter imageByFilteringImage:self.image];
            self.myImageView.image = image;

        }
            break;
            
        case CAPTIFY_FILTER_ORIGINAL:
        {
            self.myImageView.image = self.image;
        }
            break;
            
        case CAPTIFY_FILTER_AMATORKA:
        {
            UIImage *image = [self.amatoraFilter imageByFilteringImage:self.image];
            self.myImageView.image = image;
        }
            break;
            
        case CAPTIFY_FILTER_MISS_ETIKATE:
        {
            UIImage *image = [self.etikateFilter imageByFilteringImage:self.image];
            self.myImageView.image = image;
        }
            break;
            
       default:
            break;
    }
    
    
    
    filterIndex += 1;
    
    if (filterIndex >= total){
        filterIndex = 0;
    }

    
}


- (IBAction)pickColor:(UIButton *)sender {
    NEOColorPickerViewController *colorPicker = [[NEOColorPickerViewController alloc] init];
    colorPicker.delegate = self;
    colorPicker.selectedColor = [UIColor blackColor];
    colorPicker.title = NSLocalizedString(@"Caption Color", @"Color to use on caption");
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:colorPicker];
    [self presentViewController:navVC animated:YES completion:^{
        self.fromColorPicker = YES;
    }];
}


- (IBAction)tappedRotate:(UIButton *)sender {
    [self.finalCaptionLabel stopGlowing];
    static int attempts = 0;

    //[self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/-12)];
    
    
    if (!self.captionIsSplit){
        if (!attempts){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/4)];
        }
        
        if (attempts == 1){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
        }
        
        if (attempts == 2){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/-1)];
        }
        
        if (attempts == 3){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/-4)];
        }
        
        
        if (attempts == 4){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(0)];
        }
    
    }
    else{
        for (UIView *view in self.myImageView.subviews){
            if ([view isKindOfClass:[UILabel class]]){
                if (!attempts){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/4)];
                }
                
                if (attempts == 1){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
                }
                
                if (attempts == 2){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/-1)];
                }
                
                if (attempts == 3){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/-4)];
                }
                
                
                if (attempts == 4){
                    [view setTransform:CGAffineTransformMakeRotation(0)];
                }
            }
        }

    }
    
    attempts += 1;
    
    if (attempts > 4){
        attempts = 0;
    }

    
    
}

- (IBAction)tappedReverseRotate:(UIButton *)sender {
    [self.finalCaptionLabel stopGlowing];
    static int attempts = 0;
    
    //[self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/-12)];
    
    if (!self.captionIsSplit){
        if (!attempts){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/-4)];
        }
        
        if (attempts == 1){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/-2)];
        }
        
        if (attempts == 2){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/-1)];
        }
        
        if (attempts == 3){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(-M_PI/4)];
        }
        
        
        if (attempts == 4){
            [self.finalCaptionLabel setTransform:CGAffineTransformMakeRotation(0)];
        }
    }
    else{
        for (UIView *view in self.myImageView.subviews){
            if ([view isKindOfClass:[UILabel class]]){
                if (!attempts){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/4)];
                }
                
                if (attempts == 1){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/2)];
                }
                
                if (attempts == 2){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/-1)];
                }
                
                if (attempts == 3){
                    [view setTransform:CGAffineTransformMakeRotation(-M_PI/-4)];
                }
                
                
                if (attempts == 4){
                    [view setTransform:CGAffineTransformMakeRotation(0)];
                }
            }
        }

    }
    
    attempts += 1;
    
    if (attempts > 4){
        attempts = 0;
    }

}



- (IBAction)splitCaptionButtonTapped:(UIButton *)sender
{

    if (!self.captionIsSplit){
        self.splitCaptionLabel.text = NSLocalizedString(@"Join", nil);
        NSArray *words = [self.finalCaptionLabel.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        words = [words filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        for (NSString *word in words){
            UILabel *splitCaptionLabel = [[UILabel alloc] init];
            splitCaptionLabel.text = word;
            splitCaptionLabel.textColor = self.finalCaptionLabel.textColor;
            splitCaptionLabel.font = self.finalCaptionLabel.font;
            
            [UIView animateWithDuration:1
                                  delay:0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:.9
                                options:0
                             animations:^{
                                    //splitCaptionLabel.frame = previousFrame;
                                 splitCaptionLabel.center = CGPointMake(arc4random() % (int) self.myImageView.bounds.size.width/2,
                                                                        arc4random() % (int) self.myImageView.bounds.size.height/2);
                                 

                             } completion:nil];
          
            splitCaptionLabel.numberOfLines = 0;
            [splitCaptionLabel sizeToFit];
            splitCaptionLabel.userInteractionEnabled = YES;
            
            UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startedLabelDrag:)];
            press.minimumPressDuration = 0.05;
            
            UILongPressGestureRecognizer *controls = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCaption:)];
            controls.minimumPressDuration = 0.7;
            
            [press requireGestureRecognizerToFail:controls];
            
            [splitCaptionLabel addGestureRecognizer:press];
            [splitCaptionLabel addGestureRecognizer:controls];

            
            
            [self.myImageView addSubview:splitCaptionLabel];
        }
        
        self.finalCaptionLabel.hidden = YES;
        self.captionIsSplit = YES;

    }
    else{
        self.splitCaptionLabel.text = NSLocalizedString(@"Split", nil);
        [self joinCaptionButtonTapped:sender];
    }
}


- (IBAction)joinCaptionButtonTapped:(UIButton *)sender
{
    if (self.captionIsSplit){
        for (UIView *view in self.myImageView.subviews){
            if ([view isKindOfClass:[UILabel class]] && view.tag != FINAL_CAPTION_TAG){
                [view removeFromSuperview];
            }
        }
        
        self.finalCaptionLabel.hidden = NO;
        self.captionIsSplit = NO;
    }
}



- (void)tappedCaption:(UITapGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.imageControls.hidden){
                [self.finalCaptionLabel stopGlowing];
                self.imageControls.hidden = NO;
                
                if (USE_GOOGLE_ANALYTICS){
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UI_Actions"
                                                                          action:@"show_image_controls"
                                                                           label:@"detail_screen"
                                                                           value:nil] build]];
                }

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
            self.captionMoved = YES;
            view.center = point;
            
            view.backgroundColor = [UIColor clearColor];
            view.layer.borderColor = [[UIColor whiteColor] CGColor];
            view.layer.borderWidth = 2.f;
            view.layer.cornerRadius = 10.f;
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            //[self captionStoppedDragging];
            self.currentPoint = point;
            view.layer.borderWidth = 0;
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

- (IBAction)captionAlphaChanged:(UISlider *)sender {
    
    [self.finalCaptionLabel stopGlowing];
    //self.finalCaptionLabel.alpha = sender.value;

    for (UIView *view in self.myImageView.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            ((UILabel *)view).alpha = sender.value;
        }
    }
    self.captionAlphaValue.text = [NSString stringWithFormat:@"%.1f",sender.value];
}

- (void)showAlertWithTextField
{

    self.makeCaptionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Make your own", nil)
                                                    message:NSLocalizedString(@"Dont like any captions or haven't received any? Create your own", nil) delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"Make Caption", nil), nil];
    self.makeCaptionAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [self.makeCaptionAlert textFieldAtIndex:0];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    textField.placeholder = NSLocalizedString(@"Enter caption", nil);
    textField.delegate = self;
    [self.makeCaptionAlert show];

}


- (void)selectedCaption:(UIButton *)sender
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTable];
    NSIndexPath *indexPath = [self.myTable indexPathForRowAtPoint:buttonPosition];
    ChallengePicks *pick = [self.data objectAtIndex:indexPath.section];
    UITableViewCell *cell = [self.myTable cellForRowAtIndexPath:indexPath];
    NSArray *visibleCells = [self.myTable visibleCells];
    
    NSString *checkCaption = [((HistoryDetailCell *)cell).myCaptionLabel.text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    if ([pick.answer isEqualToString:checkCaption]){
        cell.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_BLUE];
    }
    else{
        cell.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    }
    
    if (self.previousCell && ![self.previousCell isEqual:cell]){
        self.previousCell.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    }
    
    for (UITableViewCell *ce in visibleCells){
        if (![ce isEqual:cell]){
            ce.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
        }
    }
    
    
    if (indexPath != nil){
        self.selectedPick = pick;
        self.selectedCaption = pick.answer;
        self.selectedUsername = pick.player.username;
    }

    self.previousCell = cell;
    [self.finalCaptionLabel stopGlowing];
    self.hideSelectButtons = YES;
    //[self.myTable reloadData];
    [self setupFinalLabel];
    
}


- (void)captionSizeChanged
{
    [self.finalCaptionLabel stopGlowing];
    
    
    //CGFloat width = CGRectGetMaxX(self.myImageView.bounds);
    //CGFloat height = CGRectGetMaxY(self.myImageView.bounds);
    
    if (!self.captionIsSplit){
        self.finalCaptionLabel.frame = CGRectMake(self.currentPoint.x, self.currentPoint.y,CGRectGetMaxX(self.myImageView.frame), 200);
        if (self.captionMoved){
            self.finalCaptionLabel.center = self.currentPoint;
        }
        else{
            self.finalCaptionLabel.center = self.priorPoint;
        }
       
    }
    else{
     
        for (UIView *view in self.myImageView.subviews){
            if ([view isKindOfClass:[UILabel class]]){
                
                ((UILabel *)view).font = [UIFont fontWithName:self.currentFont size:self.captionSizeStepper.value];
                ((UILabel *)view).numberOfLines = 0;
                [((UILabel *)view) sizeToFit];
                ((UILabel *)view).textAlignment = NSTextAlignmentCenter;
                
                CGSize size = view.superview.bounds.size;
                
                CGRect spiltFrame = ((UILabel *)view).frame;
                //spiltFrame.size = CGSizeMake(spiltFrame.size.width + 20, spiltFrame.size.height);
                spiltFrame.size = CGSizeMake(size.width/2, spiltFrame.size.height);
                ((UILabel *)view).frame = spiltFrame;
                
                
            }
        }
        
    }
    
    self.finalCaptionLabel.font = [UIFont fontWithName:self.currentFont size:self.captionSizeStepper.value];
    self.captionSizeValue.text = [NSString stringWithFormat:@"%d pt", (int)self.captionSizeStepper.value];


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
    //self.finalCaptionLabel.textColor = color;
    for (UIView *view in self.myImageView.subviews){
        if ([view isKindOfClass:[UILabel class]]){
            ((UILabel *)view).textColor = color;
        }
    }
    [self.captionColor setTitleColor:color forState:UIControlStateNormal];
    self.captionColorTitle.textColor = color;
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

    if (alertView == self.makeCaptionAlert){
        if ([alertView textFieldAtIndex:0].delegate == self){
            [alertView textFieldAtIndex:0].delegate = nil;
        }

        if (buttonIndex == 1){
            NSString *caption = [alertView textFieldAtIndex:0].text;
            if ([caption length] > 0){
                [self.finalCaptionLabel stopGlowing];
                self.selectedCaption = caption;
                self.hideSelectButtons = YES;
                [self setupFinalLabel];
                
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    NSString *message = [NSString stringWithFormat:@"Are you sure you want the caption \"%@\"?",self.selectedCaption];
                    self.confirmCaptionAlert = [[UIAlertView alloc]
                                                initWithTitle:NSLocalizedString(@"Confirm", nil)
                                                message:message
                                                delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
                    [self.confirmCaptionAlert show];
                });
            }
        }
    }
    
    else if (alertView == self.confirmCaptionAlert){
        if (buttonIndex == 1){
            self.makeButtonVisible = NO;
            NSDictionary *params = @{@"username": self.myUser.username,
                                     @"challenge_id":self.myChallenge.challenge_id,
                                     @"answer":self.selectedCaption,
                                     @"iMade":[NSNumber numberWithBool:YES],
                                     @"date":[Challenge dateStringFromDate:[NSDate date]]};
            
            [ChallengePicks sendCreatePickRequestWithParams:params
                                                      block:^(BOOL wasSuccessful, BOOL fail, NSString *message, NSString *pick_id) {
                                                          if (wasSuccessful){
                                                              
                                                              
                                                              NSDictionary *params2 = @{@"player": self.myUser.username,
                                                                                        @"context":self.myUser.managedObjectContext,
                                                                                        @"is_chosen":[NSNumber numberWithBool:NO],
                                                                                        @"answer":self.selectedCaption,
                                                                                        @"pick_id":pick_id,
                                                                                        @"pick_chosen":[NSNumber numberWithBool:YES]};
                                                              ChallengePicks *pick = [ChallengePicks createChallengePickWithParams:params2];
                                                              if (pick){
                                                                  NSError *error;
                                                                  [self.myChallenge addPicksObject:pick];
                                                                  self.myChallenge.sentPick = [NSNumber numberWithBool:YES];
                                                                  self.selectedPick = pick;
                                                                  if (![self.myChallenge.managedObjectContext save:&error]){
                                                                      DLog(@"%@",error);
                                                                  }
                                                              }
                                                              
                                                              
                                                              
                                                          }
                                                          else{
                                                              self.makeButtonVisible = YES;
                                                              if (fail){
                                                                  [self showAlertWithTitle:@"Error" message:message];
                                                                  
                                                              }
                                                              else{
                                                                  if (self.errorCount < 3){
                                                                      [self showAlertWithTitle:@"Error" message:@"There was an error sending your caption. Try again."];
                                                                      
                                                                  }
                                                                  else{
                                                                      [self showAlertWithTitle:@"Bug" message:@"This might be a bug. Developer has been notified."];
                                                                      MFMailComposeViewController *tempMailCompose = [[MFMailComposeViewController alloc] init];
                                                                      
                                                                      if ([MFMailComposeViewController canSendMail])
                                                                      {
                                                                          tempMailCompose.mailComposeDelegate = self;
                                                                          [tempMailCompose setToRecipients:@[@"help@gocaptify.com"]];
                                                                          [tempMailCompose setSubject:@"Theres a freaking bug!"];
                                                                          [tempMailCompose setMessageBody:[NSString stringWithFormat:@"I tried to send %@ a caption and I keep getting error alerts! Get this fixed now!",self.myChallenge.sender.username] isHTML:NO];
                                                                          [self presentViewController:tempMailCompose animated:YES completion:^{
                                                                          }];
                                                                      }
                                                                      
                                                                      
                                                                  }
                                                                  
                                                                  
                                                                  self.errorCount += 1;
                                                              }
                                                          }

                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.myTable reloadData];
                                                              if ([self.data count] > 0){
                                                                  [self.errorLabel removeFromSuperview];
                                                                  self.errorLabel = nil;
                                                                  [self.errorMakeCaptionButton removeFromSuperview];
                                                                  self.errorMakeCaptionButton = nil;

                                                              }
                                                          });

                                                      }];
            
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
    return [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return 35;
    }
    else{
        return 5;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *container;
    if (section == 0){
        container = [[UIView alloc] initWithFrame:CGRectMake(100, 0.0, 100, 60)];
        container.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
        
        NSString *title;
        NSUInteger count = [self.data count];
        if (count == 0){
            title = NSLocalizedString(@"No captions received yet", @"Nothing received yet");
        }

        else if  (self.hideSelectButtons || self.hideSelectButtonsMax){
            NSString *string;
            
            if (self.hideSelectButtonsMax){
                if (count == 1){
                    string = [NSString stringWithFormat:@"%lu caption sent", (unsigned long)count];
                }
                else{
                    string = [NSString stringWithFormat:@"%lu captions sent", (unsigned long)count];
                    
                }

            }
            else{
                string = [NSString stringWithFormat:@" Choose your favorite caption"];
            }
            title = NSLocalizedString(string, nil);
        }
        else{
            NSString *string = [NSString stringWithFormat:@" Choose your favorite caption"];
            title = NSLocalizedString(string, nil);
        }

        UILabel *titleLablel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 300, 50)];
        titleLablel.text = title;
        titleLablel.numberOfLines = 0;
        [titleLablel sizeToFit];
        titleLablel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:15];
        titleLablel.textColor = [UIColor whiteColor];
        
        if (!self.hideSelectButtonsMax){
            if (self.makeButtonVisible){        
                self.makeButton = [[UIButton alloc] initWithFrame:CGRectMake(240.0, -5.0, 100, 50)];
                self.makeButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:25];
                [self.makeButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
                [self.makeButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-pencil-square-o"] forState:UIControlStateNormal];
                [self.makeButton addTarget:self action:@selector(makeCaption) forControlEvents:UIControlEventTouchUpInside];
                [container addSubview:self.makeButton];
            }
        }
        
        [container addSubview:titleLablel];
    }
    return container;
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = 10;
    cell.contentView.layer.cornerRadius = 10;
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];

    ChallengePicks *pick = [self.data objectAtIndex:indexPath.section];
    
    if ([pick isKindOfClass:[ChallengePicks class]]){
        
        if ([cell isKindOfClass:[HistoryDetailCell class]]){
            UILabel *captionLabel = ((HistoryDetailCell *)cell).myCaptionLabel;
            UILabel *usernameLabel = ((HistoryDetailCell *)cell).myUsername;
            UIButton *selectButton = ((HistoryDetailCell *)cell).mySelectButton;
            UILabel *dateLabel = ((HistoryDetailCell *)cell).myDateLabel;
            UIImageView *imageView = ((HistoryDetailCell *)cell).myImageVew;
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 30;
            
            [pick.player getCorrectProfilePicWithImageView:imageView];
            
            if ([pick.player.facebook_user intValue] == 1){
                NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",pick.player.facebook_id];
                NSURL * fbUrl = [NSURL URLWithString:fbString];
                [imageView setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
                
            }
            
            else{
                imageView.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
                /*
                imageView.image = nil;
                FAImageView *imageView2 = (FAImageView *)imageView;
                [imageView2 setDefaultIconIdentifier:@"fa-user"];
                 */
                
            }

    
            NSString *username;
            if (pick.player.username){
                username = [pick.player.username capitalizedString];
            
            }
            else{
                username = @"User";
            }
            
            
            NSString *me = [self.myUser.username capitalizedString];
            if ([username isEqualToString:me]){
                usernameLabel.text = [@"You" capitalizedString];
            }
            else{
                usernameLabel.text = [pick.player displayName];
            }
            
            usernameLabel.frame = CGRectMake(usernameLabel.frame.origin.x, usernameLabel.frame.origin.y, 176, 50);
            usernameLabel.textColor = [UIColor whiteColor];
            usernameLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:17];
            usernameLabel.numberOfLines = 0;
            [usernameLabel sizeToFit];
    
             captionLabel.text = [NSString stringWithFormat:@"\"%@\"",pick.answer];
        
            // set width and height so "sizeToFit" uses those constraints
          
            captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);
            captionLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
            captionLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:15];
            captionLabel.numberOfLines = 0;
            [captionLabel sizeToFit];
            
            dateLabel.text = [pick.timestamp timeAgo];
            dateLabel.textColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
            dateLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:11];
            
        
            
            
            [selectButton addTarget:self action:@selector(selectedCaption:) forControlEvents:UIControlEventTouchUpInside];
            
            selectButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:25];
            [selectButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check"] forState:UIControlStateNormal];
            [selectButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_ORANGE] forState:UIControlStateNormal];
            
            if (self.hideSelectButtonsMax){
                if ([pick.is_chosen intValue] == 1){
                    selectButton.userInteractionEnabled = NO;
                    selectButton.hidden = YES;
                    cell.contentView.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_BLUE];
                    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] CGColor];
                    //cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
                    //selectButton.titleLabel.font = [UIFont fontAwesomeFontOfSize:25];
                    //[selectButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-trophy"] forState:UIControlStateNormal];
                }
                else{
                    selectButton.hidden = YES;
                }
          }
            
           
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
        [_nextButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                              NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
        

    }
    return  _nextButton;
}



- (NSArray *)data
{
    
    NSMutableSet *picks = [self.myChallenge.picks mutableCopy];
    for (ChallengePicks *pick in picks){
        if ([pick.player.username isEqualToString:self.myUser.username]){
            [picks removeObject:pick];
        }
    }
    
    NSSortDescriptor *sortDate = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    _data = [picks sortedArrayUsingDescriptors:@[sortDate]];
     
    
    return _data;
}


- (ChallengePicks *)myPick
{
    if (!_myPick){
        NSArray *allPicks = [self.myChallenge.picks allObjects];
        NSArray *picks = [allPicks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player.username == %@",self.myUser.username]];
        if (picks){
            _myPick = [picks firstObject];
        }
    }
    
    return _myPick;
}



- (UIView *)imageControls
{
    if (!_imageControls){
        _imageControls = [[[NSBundle mainBundle] loadNibNamed:@"shareControls" owner:self options:nil]lastObject];
        [self setupImageControlsStyle];
    }
    return _imageControls;
}



- (GPUImageGrayscaleFilter *)grayScaleFilter
{
    if (!_grayScaleFilter){
        _grayScaleFilter = [GPUImageGrayscaleFilter new];
    }
    return  _grayScaleFilter;
}

- (GPUImageSepiaFilter *)sepiaFilter
{
    if (!_sepiaFilter){
        _sepiaFilter = [GPUImageSepiaFilter new];
        
    }
    return _sepiaFilter;
}

- (GPUImageSketchFilter *)sketchFilter
{
    if (!_sketchFilter){
        _sketchFilter = [GPUImageSketchFilter new];
        
    }
    return _sketchFilter;
}

- (GPUImageToonFilter *)toonFilter
{
    if (!_toonFilter){
        _toonFilter = [GPUImageToonFilter new];
        _toonFilter.threshold = 0.2;
        _toonFilter.quantizationLevels = 10.0;
        
    }
    return _toonFilter;
}

- (GPUImagePosterizeFilter *)posterizeFilter
{
    if (!_posterizeFilter){
        _posterizeFilter = [GPUImagePosterizeFilter new];
        _posterizeFilter.colorLevels = 10;
    }
    return _posterizeFilter;
}

- (GPUImageAmatorkaFilter *)amatoraFilter
{
    _amatoraFilter = [GPUImageAmatorkaFilter new];
    return _amatoraFilter;
}

- (GPUImageMissEtikateFilter *)etikateFilter
{
    _etikateFilter = [GPUImageMissEtikateFilter new];
    return _etikateFilter;
}


- (UILabel *)errorLabel
{
    if (!_errorLabel){
          CGRect ivFrame = self.myImageView.frame;
         _errorLabel = [[UILabel alloc] init];
         _errorLabel.textColor = [UIColor whiteColor];
         _errorLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:16];
        NSString *errorText;
        if ([self.myChallenge.active intValue] == 1){
           errorText = NSLocalizedString(@"No captions have been sent to this challenge", nil);
        }
        else{
            errorText = NSLocalizedString(@"No captions were sent to this challenge", nil);
        }
        _errorLabel.text = errorText;
        _errorLabel.frame = CGRectMake(ivFrame.origin.x, ivFrame.size.height + 90, ivFrame.size.width, 40);
         _errorLabel.numberOfLines = 0;
        [_errorLabel sizeToFit];
        if ([self.myChallenge.active intValue] == 1){
            _errorLabel.frame = CGRectMake(ivFrame.origin.x + 20, ivFrame.size.height + 120, ivFrame.size.width, 40);
            
            self.errorMakeCaptionButton = [UIButton buttonWithType:UIButtonTypeSystem];
              self.errorMakeCaptionButton.frame = CGRectMake(_errorLabel.frame.origin.x, _errorLabel.frame.origin.y + 60, 203, 45);
            [self.errorMakeCaptionButton setTitle:NSLocalizedString(@"Make your own", nil) forState:UIControlStateNormal];
            [self.errorMakeCaptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.errorMakeCaptionButton setTitleColor:[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] forState:UIControlStateHighlighted];
            self.errorMakeCaptionButton.titleLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:15];
            self.errorMakeCaptionButton.backgroundColor = [UIColor clearColor];
            self.errorMakeCaptionButton.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_BLUE] CGColor];
            self.errorMakeCaptionButton.layer.borderWidth = 2;
            self.errorMakeCaptionButton.layer.cornerRadius = 5;
            [ self.errorMakeCaptionButton addTarget:self action:@selector(makeCaption) forControlEvents:UIControlEventTouchUpInside];
            
            [self.scrollView addSubview:self.errorMakeCaptionButton];
        }
        else{
            
            _errorLabel.frame = CGRectMake(ivFrame.origin.x + 10, ivFrame.size.height + 120, ivFrame.size.width, 40);
        }


    }
    
    
    return _errorLabel;
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


#pragma -mark Mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}




@end
