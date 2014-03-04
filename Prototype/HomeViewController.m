//
//  HomeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UIView+Screenshot.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "LoginViewController.h"
#import "User+Utils.h"
#import "Challenge+Utils.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ChallengeViewController.h"
#import "UIColor+HexValue.h"
#import "GoHomeTransition.h"
#import "ReceiverPreviewViewController.h"
#import "ChallengeViewController.h"
#import "UIColor+HexValue.h"
#import "GPUImage.h"
#import "NSString+FontAwesome.h"
#import "UIFont+FontAwesome.h"
#import "SenderPreviewViewController.h"
#import "UIImage+Utils.h"
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FacebookFriends.h"
#import "UIImage+Utils.h"



#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define ONEFIELD_TAG 1990
#define PHRASE_LIMIT 40

@interface HomeViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ODelegate,SenderPreviewDelegate,MenuDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *snapPicButton;
@property CGRect firstFrame;
@property (weak, nonatomic) IBOutlet UIButton *topMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *rotateButton;

@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureDevice *cameraDevice;
@property (strong,nonatomic)AVCaptureDeviceInput *cameraInput;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic)AVCaptureStillImageOutput *snapper;
@property (strong,nonatomic)UIImageView *previewSnap;
@property (strong,nonatomic)UIImage *previewEditedSnapshot;
@property (strong,nonatomic)UIImage *previewOriginalSnapshot;
@property (strong, nonatomic)UIView *previewControls;
@property (strong, nonatomic)UIView *mainControls;
@property (weak, nonatomic) IBOutlet UIButton *previewCancelButton;

@property (weak, nonatomic) IBOutlet UITextField *previewTextField;
@property (weak, nonatomic) IBOutlet UIButton *previewNextButton;

@property (weak, nonatomic) IBOutlet UIView *cameraOptionsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraOptionsButton;

@property (weak, nonatomic) IBOutlet UIView *previewOneFieldContainer;

@property (weak, nonatomic) IBOutlet UILabel *previewFinalPhraseLabel;

@property (nonatomic, strong)NSString *finalPhrase;
@property CGPoint finalPhraseLabelPostion;


@end

@implementation HomeViewController




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

    self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    MenuViewController *menu = (MenuViewController *)self.sideMenuViewController.menuViewController;
    menu.delegate = self;


    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // got a camera
            [self setupCamera];
        
    }
    else{
        // using simulator with no camera so just add buttons
        
        [self setupTestNoCamera];
    }
    
    
    
    //if user not logged in segue to login screen
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"logged"]){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }
    // used from settings to logout
    if (self.goToLogin){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    
}


- (void)setupCamera
{
    // everything here is being lazy loaded because of memory issues
    
    NSError *error;
    
    // set flash
    [self.cameraDevice lockForConfiguration:&error];
    [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
    [self.cameraDevice unlockForConfiguration];
    

    if (self.cameraInput){
        [self.session addInput:self.cameraInput];
    }
    if (self.snapper){
        [self.session addOutput:self.snapper];
    }
    
    if (self.cameraInput && self.snapper){
        
        [self.view.layer addSublayer:self.previewLayer];
        [self.view addSubview:self.mainControls];
        [self setupStylesAndMore];
        
        
        [self.session startRunning];
        
        
        
    }
    else{
        NSLog(@"error creating camera input or output");
    }
    

}

- (void)setupTestNoCamera
{
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeSystem];
    [menu setTitle:NSLocalizedString(@"Menu", nil) forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    menu.frame = CGRectMake(50, 100, 60, 60);
    
    UIButton *preview = [UIButton buttonWithType:UIButtonTypeSystem];
    [preview setTitle:@"Preview" forState:UIControlStateNormal];
    [preview addTarget:self action:@selector(tappedNextPreview:) forControlEvents:UIControlEventTouchUpInside];
    preview.frame = CGRectMake(115, 100, 60, 60);

    
    [self.view addSubview:preview];
    [self.view addSubview:menu];
}

- (void)setupStylesAndMore
{
 
    UITapGestureRecognizer *snapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedSnapPic:)];
    snapTap.numberOfTapsRequired = 1;
    
    UITapGestureRecognizer *libraryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedSnap:)];
    libraryTap.numberOfTapsRequired = 2;
    
    [snapTap requireGestureRecognizerToFail:libraryTap];
    
    [self.snapPicButton addGestureRecognizer:libraryTap];
    [self.snapPicButton addGestureRecognizer:snapTap];
    self.snapPicButton.userInteractionEnabled = YES;
    
    self.snapPicButton.font = [UIFont fontWithName:kFontAwesomeFamilyName size:70];
    self.snapPicButton.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-dot-circle-o"];
    self.snapPicButton.textColor =[UIColor colorWithHexString:@"#3498db"];
    
    self.topMenuButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.topMenuButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [self.topMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    

    
    self.flashButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ On", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];
    [self.flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.rotateButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    [self.rotateButton setTitle:[NSString stringWithFormat:@"%@ %@",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-camera"],[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"]] forState:UIControlStateNormal];
    [self.rotateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.cameraOptionsButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.cameraOptionsButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cogs"] forState:UIControlStateNormal];
    [self.cameraOptionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.cameraOptionsContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.cameraOptionsContainerView.layer.cornerRadius = 10.0f;
    self.cameraOptionsContainerView.hidden = YES;
    


}

- (void)setupPreviewStylesAndMore
{
    
    self.previewCancelButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    [self.previewCancelButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
    [self.previewCancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    self.previewNextButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    [self.previewNextButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-long-arrow-right"] forState:UIControlStateNormal];
    [self.previewNextButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    
    /*
    // add pulsating effect to button
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.3];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
     */
    

    self.previewFinalPhraseLabel.font = [UIFont fontWithName:@"Chalkduster" size:25];
    self.previewFinalPhraseLabel.hidden = YES;
    
    self.previewTextField.placeholder = NSLocalizedString(@"Enter your phrase!", @"Textfield placeholder text");
    self.previewOneFieldContainer.layer.cornerRadius = 10.0f;
    self.previewOneFieldContainer.backgroundColor = [[UIColor colorWithHexString:@"#1abc9c"] colorWithAlphaComponent:0.5f];
    CGRect firstRect = self.previewOneFieldContainer.frame;
    self.previewOneFieldContainer.frame = CGRectMake(firstRect.origin.x, SCREENHEIGHT , firstRect.size.width, firstRect.size.height);
    for (id textField in self.previewOneFieldContainer.subviews){
        if ([textField isKindOfClass:[UITextField class]]){
            ((UITextField *)textField).delegate = self;
        }
    }
   

    
}

- (IBAction)tappedMenuButton:(UIButton *)sender {
    [self showMenu];
}



- (void)tappedSnapPic:(UITapGestureRecognizer *)sender {
  
       [self snapPhoto];
}


- (IBAction)tappedFlashButton:(UIButton *)sender {
    [self toggleFlash];
}

- (IBAction)tappedCancelPreview:(UIButton *)sender {
    [self cancelPreviewImage];
}

- (IBAction)tappedCameraOptions:(UIButton *)sender {
    if (self.cameraOptionsContainerView.hidden){
        self.cameraOptionsContainerView.hidden = NO;
       [self.cameraOptionsButton setTitleColor:[UIColor colorWithHexString:@"#bdc3c7"] forState:UIControlStateNormal];
    }
    else{
        self.cameraOptionsContainerView.hidden = YES;
        [self.cameraOptionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

}


- (IBAction)tappedRotateCamera:(UIButton *)sender {
    [self toggleCameraPosition];
}




- (IBAction)tappedNextPreview:(UIButton *)sender {
    if ([self.previewTextField.text length] == 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Alert error title")
                                                            message:NSLocalizedString(@"Must enter phrase before continuing", @"Alert error message")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            return;
    }
    
    // if label is still hidden then we mimic action of clicking
    // next button on keyboard
    if (self.previewFinalPhraseLabel.hidden){
        [self textFieldShouldReturn:self.previewTextField];
        return;
    }
    
    // hide top buttons and take a snapshot
    self.previewNextButton.hidden = YES;
    self.previewCancelButton.hidden = YES;
    
    self.previewEditedSnapshot = [self.view convertViewToImage];
    
    // save position of label on image
    self.finalPhraseLabelPostion = self.previewFinalPhraseLabel.frame.origin;
    
    [self pushFinalPreview];
}

- (void)doubleTappedSnap:(UITapGestureRecognizer *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        NSLog(@"no photo library");
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}




- (void)pushFinalPreview
{
    //[self performSegueWithIdentifier:@"showFinalPreview" sender:self];
    SenderPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"finalPreview"];
    
    vc.image = self.previewOriginalSnapshot;
    vc.name = self.finalPhrase;
    vc.phrase = self.finalPhrase;
    vc.delegate = self;
    
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)source
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    imgPicker.sourceType = source;
    imgPicker.delegate = self;
    
    if (source == UIImagePickerControllerSourceTypeCamera){
        //camera so show overlay
        imgPicker.showsCameraControls = NO;
        imgPicker.allowsEditing = NO;
        imgPicker.navigationBarHidden = YES;
        imgPicker.toolbarHidden = YES;
        
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1.70, 1.70);
        imgPicker.cameraViewTransform = transform;
        //load overlay
        OverlayView *overlay = [[OverlayView alloc] init];
        overlay.delegate = self;
        [imgPicker.view addSubview:overlay];
        //UIView *button = [overlay viewWithTag:1];
        //button.layer.backgroundColor = [[UIColor colorWithHexString:@"#e74c3c"] CGColor];
        imgPicker.cameraOverlayView = overlay;
        [self presentViewController:imgPicker animated:NO completion:nil];
        
    }
}

- (void)snapPhoto
{
    AVCaptureConnection *vc = [self.snapper connectionWithMediaType:AVMediaTypeVideo];
    [self.snapper captureStillImageAsynchronouslyFromConnection:vc
                                              completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                  NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                  self.previewOriginalSnapshot = [UIImage imageWithData:data];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      
                                                      [self setupImagePreviewScreen];
                                                      
                                                      
                                                      //[self.previewLayer removeFromSuperlayer];
                                                      //self.previewLayer = nil;
                                                      //[self.session stopRunning];
                                                  });
                                              }];
}


- (void)setupImagePreviewScreen
{
    self.previewSnap = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.previewSnap.contentMode = UIViewContentModeScaleAspectFill;
    self.previewSnap.image = self.previewOriginalSnapshot;

    
    [self.view addSubview:self.previewSnap];
    [self.view addSubview:self.previewControls];
    
    [self setupPreviewStylesAndMore];
    [self performSelector:@selector(animateTextFieldUp:) withObject:[NSNumber numberWithBool:YES] afterDelay:2.0f];

    
    

}

- (void)cancelPreviewImage
{
    [self.previewControls removeFromSuperview];
    [self.previewSnap removeFromSuperview];
    
    self.previewControls = nil;
    self.previewSnap = nil;
}


- (void)animateTextFieldUp:(NSNumber *)up
{
    if (up){
        CGRect oneFrame = self.previewOneFieldContainer.frame;
        [UIView animateWithDuration:1.0f
                              delay:0
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                                              SCREENHEIGHT - 290,
                                                                              oneFrame.size.width,
                                                                              oneFrame.size.height);

                         } completion:nil];
    }
    else{
        CGRect oneFrame = self.previewOneFieldContainer.frame;
        [UIView animateWithDuration:1.0f
                              delay:0
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0
                            options:0
                         animations:^{
                             self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                                              SCREENHEIGHT ,
                                                                              oneFrame.size.width,
                                                                              oneFrame.size.height);
                             
                         } completion:nil];

    }
    

}


- (void)toggleFlash
{
    if ([self.cameraDevice isFlashModeSupported:AVCaptureFlashModeOn]){
        NSError *error;
        if (self.cameraDevice.flashActive){
            // turn off
             [self.cameraDevice lockForConfiguration:&error];
             [self.cameraDevice setFlashMode:AVCaptureFlashModeOff];
             [self.cameraDevice unlockForConfiguration];
            [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Off", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];


        }
        else{
            // turn on
            [self.cameraDevice lockForConfiguration:&error];
            [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
            [self.cameraDevice unlockForConfiguration];
            [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ On", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];

        
        }
    }
    else{
        NSLog(@"No flash available");
        [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Off", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];
        return;
    }
}


- (void)toggleCameraPosition
{
    [self.session beginConfiguration];
    NSError *error;
    [self.session removeInput:self.cameraInput];
    if ([self.cameraDevice position] == AVCaptureDevicePositionBack){
        // show front camera
        self.cameraDevice = [self frontCamera];
        self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
        if (self.cameraInput){
            [self.session addInput:self.cameraInput];
            [self.flashButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ Off", @" On button for camera flash"),[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];

        }
        

    }
    else{
        // show back camera
        self.cameraDevice = [self backCamera];
        self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
        if (self.cameraInput){
            [self.session addInput:self.cameraInput];
        }

    }
    
    [self.session commitConfiguration];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}


- (AVCaptureDevice *)backCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

- (void)focusAPoint:(CGPoint)point
{
    if ([self.cameraDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus] && [self.cameraDevice isFocusPointOfInterestSupported]){
        NSError *error;
        
        if ([self.cameraDevice lockForConfiguration:&error]){
            [self.cameraDevice setFocusPointOfInterest:point];
            
            [self.cameraDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            
            [self.cameraDevice unlockForConfiguration];
        }
    }
}


- (void)showFinalTextLabel
{
    // move text field off screen
    [UIView animateWithDuration:1.0f
                     animations:^{
                        CGRect oneFrame = self.previewOneFieldContainer.frame;
                         self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                                          SCREENHEIGHT ,
                                                                          oneFrame.size.width,
                                                                          oneFrame.size.height);
                         

                     } completion:^(BOOL finished) {
                         //show label text ontop of image
                         self.previewFinalPhraseLabel.text = self.finalPhrase;
                         self.previewFinalPhraseLabel.userInteractionEnabled = YES;
                         if ([self.finalPhrase length] > 15){
                             self.previewFinalPhraseLabel.numberOfLines = 0;
                             [self.previewFinalPhraseLabel sizeToFit];
                         }
                         self.previewFinalPhraseLabel.textAlignment = NSTextAlignmentCenter;
                         
                         self.previewFinalPhraseLabel.alpha = 0;
                         self.previewFinalPhraseLabel.hidden = NO;
                         [UIView animateWithDuration:1.0
                                          animations:^{
                                              self.previewFinalPhraseLabel.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              // add pulsating effect to next button arrow
                                              if  (![self.previewNextButton.layer animationForKey:@"previewNextButton"]){
                                                  
                                              
                                                  CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                                                  pulseAnimation.duration = .5;
                                                  pulseAnimation.toValue = [NSNumber numberWithFloat:1.3];
                                                  pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                  pulseAnimation.autoreverses = YES;
                                                  pulseAnimation.repeatCount = FLT_MAX;
                                                  [self.previewNextButton.layer addAnimation:pulseAnimation forKey:@"previewNextButton"];
                                              }

                                          }];

                     }];

}


- (void)showMenu
{
   
      [self.sideMenuViewController openMenuAnimated:YES completion:nil];
    
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.cameraOptionsContainerView.hidden)
    {
        self.cameraOptionsContainerView.hidden = YES;
    }
    
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    // focus camera where user touces
    if (self.session.running){
        [self focusAPoint:touchLocation];
    }
}

#pragma -mark Overlay delegate

- (void)showMenuButtonClicked
{
    [self showMenu];
}

#pragma -mark Menu delegate

- (void)menuShowingAnotherScreen
{
    // use this to dispose of resources instead of
    // view did/will disappear so we dont mess up
    // preview screen
    
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
    [self.session stopRunning];
    self.session = nil;
    
    self.cameraDevice = nil;
    self.cameraInput = nil;
    self.snapper = nil;
    self.previewSnap = nil;
    self.previewControls = nil;
    self.snapPicButton = nil;
    self.topMenuButton = nil;
    self.flashButton = nil;
    self.previewCancelButton = nil;
    self.previewNextButton = nil;
    self.cameraOptionsButton = nil;
    self.cameraOptionsContainerView = nil;
    self.previewOneFieldContainer = nil;
    self.finalPhrase = nil;
    self.previewEditedSnapshot = nil;
    self.previewOriginalSnapshot = nil;
    
    
    
    
    
    if (self.navigationController.delegate == self){
        self.navigationController.delegate = nil;
    }
    
    MenuViewController *menu = (MenuViewController *) self.sideMenuViewController.menuViewController;
    if (menu.delegate == self){
        menu.delegate = nil;
    }
    

}


#pragma -mark SemderPreview delegate

- (void)previewscreenDidMoveBack
{
    self.navigationController.navigationBarHidden = YES;
}


#pragma -mark UItextfield delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if ([string isEqualToString:@""]){
        return YES;
    }
    
    if ([textField.text length] <= PHRASE_LIMIT){
        return YES;
    }
    else{
        return NO;
    }
    


}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.finalPhrase = textField.text;
    [self showFinalTextLabel];
    
    //[self proceedToFinalPreview];
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
      textField.returnKeyType = UIReturnKeyNext;
}


#pragma -mark UIImagepickercontroller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *) kUTTypeImage]){
        self.previewOriginalSnapshot = info[UIImagePickerControllerOriginalImage];
        [self setupImagePreviewScreen];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark UINavigationController delegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[HomeViewController class]]){
        if ([fromVC isKindOfClass:[SenderPreviewViewController class]]){
            self.previewNextButton.hidden = NO;
            self.previewCancelButton.hidden = NO;
            self.previewFinalPhraseLabel.hidden = YES;
            self.finalPhrase = nil;
            CGRect oneFrame = self.previewOneFieldContainer.frame;
            self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                             SCREENHEIGHT - 290,
                                                             oneFrame.size.width,
                                                             oneFrame.size.height);

            return nil;
        }
        
        self.navigationController.navigationBarHidden = YES;
        if ([fromVC isKindOfClass:[ChallengeViewController class]]){
            UIView *remove = [self.navigationController.navigationBar viewWithTag:SENDERPICANDNAME_TAG];
            if (remove){
                [remove removeFromSuperview];
            }
            
        }
        return [GoHomeTransition new];
    }
    
    if (operation == UINavigationControllerOperationPush && [toVC isKindOfClass:[ReceiverPreviewViewController class]]){
        UIView *picAndName = ((ChallengeViewController *)fromVC).topLabel;
        if (picAndName){
            [picAndName removeFromSuperview];
        }
    }
    
    if (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[ReceiverPreviewViewController class]]){
        [((ChallengeViewController *)toVC) setupTopLabel];
    }
    

    
    return nil;
}


- (AVCaptureVideoPreviewLayer *)previewLayer
{

    if (!_previewLayer){
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.view.frame;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (AVCaptureStillImageOutput *)snapper
{
    if (!_snapper){
        _snapper = [AVCaptureStillImageOutput new];
        _snapper.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG,
                                    AVVideoQualityKey:@0.6};

    }
    return _snapper;
}

- (AVCaptureDeviceInput *)cameraInput
{
    NSError *error;
    if (!_cameraInput){
        _cameraInput =  [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
    }
    
    
    return _cameraInput;
}
- (AVCaptureDevice *)cameraDevice
{
    if (!_cameraDevice){
        _cameraDevice = [self backCamera];
    }
    return _cameraDevice;
}

- (AVCaptureSession *)session
{
    if (!_session){

        _session = [AVCaptureSession new];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return  _session;
}

- (UIView *)mainControls
{
    if (!_mainControls){
        _mainControls = [[[NSBundle mainBundle] loadNibNamed:@"cameraControls" owner:self options:nil]lastObject];
    }
    return  _mainControls;
}

- (UIView *)previewControls
{
    if (!_previewControls){
        _previewControls = [[[NSBundle mainBundle] loadNibNamed:@"previewControls" owner:self options:nil]lastObject];

    }
    
    return _previewControls;
}


- (User *)myUser
{
    if (!_myUser){
        NSManagedObjectContext *context = ((AppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
        NSURL *uri = [[NSUserDefaults standardUserDefaults] URLForKey:@"superuser"];
        if (uri){
            NSManagedObjectID *superuserID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
            NSError *error;
            _myUser = (id) [context existingObjectWithID:superuserID error:&error];
        }
        
    }
    return _myUser;
}

@end
