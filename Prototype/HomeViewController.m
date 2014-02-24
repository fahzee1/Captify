//
//  HomeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HomeViewController.h"
#import "MenuViewController.h"
#import "LoginViewController.h"
#import "User+Utils.h"
#import "Challenge+Utils.h"
#import <FacebookSDK/FacebookSDK.h>
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
#import <AVFoundation/AVFoundation.h>


#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define ONEFIELD_TAG 1990
#define TWOFIELDS_FIRST_TAG 1991
#define TWOFIELDS_SECOND_TAG 1992
#define THREEFIELDS_FIRST_TAG 1993
#define THREEFIELDS_SECOND_TAG 1994
#define THREEFIELDS_THIRD_TAG 1995
#define PHRASE_LIMIT 18

@interface HomeViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ODelegate,SenderPreviewDelegate,MenuDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *snapPicButton;
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
@property (strong, nonatomic)UIView *previewControls;
@property (weak, nonatomic) IBOutlet UIButton *previewCancelButton;

@property (weak, nonatomic) IBOutlet UIButton *previewNextButton;
@property (weak, nonatomic) IBOutlet UIButton *previewShowPickerButton;
@property (weak, nonatomic) IBOutlet UIView *previewPickerContainer;

@property (weak, nonatomic) IBOutlet UIView *cameraOptionsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraOptionsButton;

@property (weak, nonatomic) IBOutlet UIPickerView *previewWordCountPicker;

@property (weak, nonatomic) IBOutlet UIView *previewOneFieldContainer;

@property (weak, nonatomic) IBOutlet UIView *previewTwoFieldContainer;

@property (weak, nonatomic) IBOutlet UIView *previewThreeFieldContainer;


@property (nonatomic, assign) NSInteger numberOfFields;
@property (strong, nonatomic)NSArray *phraseCountNumbers;
@property (nonatomic, strong) UIView *previewCurrentField;
@property (nonatomic, strong)NSString *finalPhrase;

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
    
    self.phraseCountNumbers = [[NSArray alloc] initWithObjects:@"One Word",@"Two Words",@"Three Words" ,nil];


    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // got a camera
        if (![self.session isRunning]){
            [self setupCamera];
        }
        
    }
    else{
        // using simulator with no camera so just add buttons
        
        [self setupTestNoCamera];
    }
    
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
        NSLog(@"no front camera");
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        NSLog(@"no photo library");
    }
    
    //if user not logged in segue to login screen
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"logged"]){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }
    if (self.goToLogin){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }
    
    //[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    //User *friend = [User createTestFriendWithName:@"test2" context:self.myUser.managedObjectContext];
    //Challenge *ch = [Challenge createTestChallengeWithUser:friend];
 
     [self setupStylesAndMore];
}




- (void)setupCamera
{
    NSError *error;
    
    self.session = [AVCaptureSession new];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.cameraDevice = [self backCamera];
    self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
    
    // set flash
    [self.cameraDevice lockForConfiguration:&error];
    [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
    [self.cameraDevice unlockForConfiguration];
    
    
    self.snapper = [AVCaptureStillImageOutput new];
    self.snapper.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG,
                                    AVVideoQualityKey:@0.6};
    
    if (self.cameraInput){
        [self.session addInput:self.cameraInput];
    }
    if (self.snapper){
        [self.session addOutput:self.snapper];
    }
    
    if (self.cameraInput && self.snapper){
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.previewLayer.frame = self.view.frame;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [self.view.layer addSublayer:self.previewLayer];
        
        UIView *controlsView = [[[NSBundle mainBundle] loadNibNamed:@"cameraControls" owner:self options:nil]lastObject];
        [self.view addSubview:controlsView];
        
        
        [self.session startRunning];
        
        
        
    }
    else{
        NSLog(@"error creating camera input or output");
    }
    

}

- (void)setupTestNoCamera
{
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeSystem];
    [menu setTitle:@"Menu" forState:UIControlStateNormal];
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
 
    
    self.snapPicButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:70];
    [self.snapPicButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-dot-circle-o"] forState:UIControlStateNormal];
    [self.snapPicButton setTitleColor:[UIColor colorWithHexString:@"#3498db"] forState:UIControlStateNormal];

    
    self.topMenuButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.topMenuButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] forState:UIControlStateNormal];
    [self.topMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    

    
    self.flashButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    [self.flashButton setTitle:[NSString stringWithFormat:@"%@ On",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];
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
    
    self.previewShowPickerButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:50];
    [self.previewShowPickerButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-plus-square-o"] forState:UIControlStateNormal];
    [self.previewShowPickerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // add pulsating effect to button
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .5;
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
    [self.previewShowPickerButton.layer addAnimation:pulseAnimation forKey:nil];
    
    self.previewOneFieldContainer.layer.cornerRadius = 10.0f;
    self.previewOneFieldContainer.backgroundColor = [[UIColor colorWithHexString:@"#1abc9c"] colorWithAlphaComponent:0.5f];
    CGRect firstRect = self.previewOneFieldContainer.frame;
    self.previewOneFieldContainer.frame = CGRectMake(firstRect.origin.x, SCREENHEIGHT , firstRect.size.width, firstRect.size.height);
    for (id textField in self.previewOneFieldContainer.subviews){
        if ([textField isKindOfClass:[UITextField class]]){
            ((UITextField *)textField).delegate = self;
        }
    }
    
    self.previewTwoFieldContainer.layer.cornerRadius = 10.0f;
    self.previewTwoFieldContainer.backgroundColor = [[UIColor colorWithHexString:@"#1abc9c"] colorWithAlphaComponent:0.5f];
    CGRect secondRect = self.previewTwoFieldContainer.frame;
    self.previewTwoFieldContainer.frame = CGRectMake(secondRect.origin.x, SCREENHEIGHT, secondRect.size.width, secondRect.size.height);
    for (id textField in self.previewTwoFieldContainer.subviews){
        if ([textField isKindOfClass:[UITextField class]]){
            ((UITextField *)textField).delegate = self;
        }
    }

    
    self.previewThreeFieldContainer.layer.cornerRadius = 10.0f;
    self.previewThreeFieldContainer.backgroundColor = [[UIColor colorWithHexString:@"#1abc9c"] colorWithAlphaComponent:0.5f];
    CGRect thirdRect = self.previewThreeFieldContainer.frame;
    self.previewThreeFieldContainer.frame = CGRectMake(thirdRect.origin.x, SCREENHEIGHT, thirdRect.size.width, thirdRect.size.height);
    for (id textField in self.previewThreeFieldContainer.subviews){
        if ([textField isKindOfClass:[UITextField class]]){
            ((UITextField *)textField).delegate = self;
        }
    }



    
    self.previewPickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.previewPickerContainer.layer.cornerRadius = 10.0f;
    self.previewPickerContainer.hidden = YES;
    self.previewPickerContainer.userInteractionEnabled = NO;
    
    self.previewWordCountPicker.delegate = self;
    self.previewWordCountPicker.dataSource = self;

   
    
    
}

- (IBAction)tappedMenuButton:(UIButton *)sender {
    [self showMenu];
}


- (IBAction)tappedSnapPic:(UIButton *)sender {
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
    
    //[self performSegueWithIdentifier:@"showFinalPreview" sender:self];
    SenderPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"finalPreview"];
    vc.image = self.previewSnap.image;
    vc.name = self.finalPhrase;
    vc.phrase = self.finalPhrase;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tappedPreviewWordCountButton:(id)sender {
    [self.previewShowPickerButton.layer removeAllAnimations];
    if (self.previewPickerContainer.hidden){
        self.previewPickerContainer.hidden = NO;
        self.previewPickerContainer.userInteractionEnabled = YES;
        
    }
    else{
        self.previewPickerContainer.hidden = YES;
        self.previewPickerContainer.userInteractionEnabled = NO;
        
    }
}


- (void)proceedToFinalPreview
{

    [self tappedNextPreview:self.previewNextButton];
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
                                                  UIImage *im = [UIImage imageWithData:data];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      self.previewSnap = [[UIImageView alloc] initWithFrame:self.view.frame];
                                                      self.previewSnap.contentMode = UIViewContentModeScaleAspectFill;
                                                      self.previewSnap.image = im;
                                                      
                                                      self.previewControls = [[[NSBundle mainBundle] loadNibNamed:@"previewControls" owner:self options:nil]lastObject];
                                                      [self setupPreviewStylesAndMore];
                                                
                                                      [self.view addSubview:self.previewSnap];
                                                      [self.view addSubview:self.previewControls];
                                                      
                                                      //[self.previewLayer removeFromSuperlayer];
                                                      //self.previewLayer = nil;
                                                      //[self.session stopRunning];
                                                  });
                                              }];
}

- (void)cancelPreviewImage
{
    [self.previewControls removeFromSuperview];
    [self.previewSnap removeFromSuperview];
    
    self.previewControls = nil;
    self.previewSnap = nil;
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
            [self.flashButton setTitle:[NSString stringWithFormat:@"%@ Off",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];


        }
        else{
            // turn on
            [self.cameraDevice lockForConfiguration:&error];
            [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
            [self.cameraDevice unlockForConfiguration];
            [self.flashButton setTitle:[NSString stringWithFormat:@"%@ On",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];

        
        }
    }
    else{
        NSLog(@"No flash available");
        [self.flashButton setTitle:[NSString stringWithFormat:@"%@ Off",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];
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
            [self.flashButton setTitle:[NSString stringWithFormat:@"%@ Off",[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"]] forState:UIControlStateNormal];

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


- (void)clearTextFieldsText
{
    switch (self.numberOfFields) {
        case 1:
        {
            
            UIView *field = [self.previewOneFieldContainer viewWithTag:ONEFIELD_TAG];
            if ([field isKindOfClass:[UITextField class]]){
                ((UITextField *)field).text = nil;
            }

        }
            break;
            
        case 2:
        {
            
            UIView *firstField = [self.previewTwoFieldContainer viewWithTag:TWOFIELDS_FIRST_TAG];
            UIView *secondField = [self.previewTwoFieldContainer viewWithTag:TWOFIELDS_SECOND_TAG];
            if ([firstField isKindOfClass:[UITextField class]] && [secondField isKindOfClass:[UITextField class]]){
                ((UITextField *)firstField).text = nil;
                ((UITextField *)secondField).text = nil;
            }

            
        }
            break;
        case 3:
        {
            UIView *firstField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_FIRST_TAG];
            UIView *secondField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_SECOND_TAG];
            UIView *thirdField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_THIRD_TAG];
            if ([firstField isKindOfClass:[UITextField class]] && [secondField isKindOfClass:[UITextField class]] && [thirdField isKindOfClass:[UITextField class]]){
                ((UITextField *)firstField).text = nil;
                ((UITextField *)secondField).text = nil;
                ((UITextField *)thirdField).text = nil;
            }

        }
            break;
            
        default:
            break;
    }
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
    
    if (self.navigationController.delegate == self){
        self.navigationController.delegate = nil;
    }
    
    MenuViewController *menu = (MenuViewController *) self.sideMenuViewController.menuViewController;
    if (menu.delegate == self){
        menu.delegate = nil;
    }
    
    if (self.previewWordCountPicker.delegate == self){
        self.previewWordCountPicker.delegate = nil;
    }
    if (self.previewWordCountPicker.dataSource == self){
        self.previewWordCountPicker.dataSource = nil;
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
    int total = 0;
    if ([string isEqualToString:@""]){
        return YES;
    }
    
    switch (self.numberOfFields) {
        case 1:
        {
            if ([textField.text length] <= PHRASE_LIMIT){
                return YES;
            }
            else{
                return NO;
            }

            break;
        }
            
        case 2:
        {
            UIView *firstField = [self.previewTwoFieldContainer viewWithTag:TWOFIELDS_FIRST_TAG];
            UIView *secondField = [self.previewTwoFieldContainer viewWithTag:TWOFIELDS_SECOND_TAG];
            if (firstField && secondField){
                if ([firstField isKindOfClass:[UITextField class]] && [secondField isKindOfClass:[UITextField class]]){
                    total = [((UITextField *)firstField).text length] + [((UITextField *)secondField).text length];
                    }
                
            }
            break;
        }
        case 3:
        {
            
            UIView *firstField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_FIRST_TAG];
            UIView *secondField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_SECOND_TAG];
            UIView *thirdField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_THIRD_TAG];
            
            if (firstField && secondField && thirdField){
                 if ([firstField isKindOfClass:[UITextField class]] && [secondField isKindOfClass:[UITextField class]] && [thirdField isKindOfClass:[UITextField class]]){
                      total = [((UITextField *)firstField).text length] + [((UITextField *)secondField).text length] + [((UITextField *)thirdField).text length];
                 }
                
            }
            
            break;
            
        }
            
        default:
            break;
    }
    
    if (total <= PHRASE_LIMIT){
        return YES;
    }
    else{
        return NO;
    }



}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    switch (self.numberOfFields) {
        case 1:
        {
            self.finalPhrase = textField.text;
            break;
        }
            
        case 2:
        {
            UIView *firstField = [self.previewTwoFieldContainer viewWithTag:TWOFIELDS_FIRST_TAG];
            UIView *secondField = [self.previewTwoFieldContainer viewWithTag:TWOFIELDS_SECOND_TAG];
            if (firstField && secondField){
                if (textField.tag == firstField.tag){
                    [secondField becomeFirstResponder];
                    return YES;
                }
                else if (textField.tag == secondField.tag){
                   if ([firstField isKindOfClass:[UITextField class]] && [secondField isKindOfClass:[UITextField class]]){
                        self.finalPhrase = [NSString stringWithFormat:@"%@ %@",((UITextField *)firstField).text,((UITextField *)secondField).text];
    
                    }

                    
                }
            }
            break;
        }
        case 3:
        {
            
            UIView *firstField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_FIRST_TAG];
            UIView *secondField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_SECOND_TAG];
            UIView *thirdField = [self.previewThreeFieldContainer viewWithTag:THREEFIELDS_THIRD_TAG];


            if (firstField && secondField && thirdField){
                if (textField.tag == firstField.tag){
                    [secondField becomeFirstResponder];
                    return YES;
                }
                else if (textField.tag == secondField.tag){
                    [thirdField becomeFirstResponder];
                    return YES;
                }
                else if (textField.tag == thirdField.tag){
                    if ([firstField isKindOfClass:[UITextField class]] && [secondField isKindOfClass:[UITextField class]] && [thirdField isKindOfClass:[UITextField class]]){
                        self.finalPhrase = [NSString stringWithFormat:@"%@ %@ %@",((UITextField *)firstField).text,((UITextField *)secondField).text,((UITextField *)thirdField).text ];
                       
                    }

                    
                }

            }

            break;
            
        }
            
        default:
            break;
    }

    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         //
                         CGRect currentFrame = self.previewCurrentField.frame;
                         self.previewCurrentField.frame = CGRectMake(currentFrame.origin.x, SCREENHEIGHT, currentFrame.size.width, currentFrame.size.height);
                         self.previewCurrentField = nil;
                         
                     } completion:^(BOOL finished) {
                         [self performSelector:@selector(proceedToFinalPreview) withObject:nil afterDelay:1.0];
                        }];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (self.numberOfFields) {
        case 1:
        {
            textField.returnKeyType = UIReturnKeyDone;
             break;
        }
            
        case 2:
        {
            if (textField.tag == TWOFIELDS_FIRST_TAG){
                textField.returnKeyType = UIReturnKeyNext;
            }
            else{
                textField.returnKeyType = UIReturnKeyDone;
            }
             break;
        }
        case 3:
        {
            if (textField.tag == THREEFIELDS_FIRST_TAG){
                textField.returnKeyType = UIReturnKeyNext;
            }
            else if (textField.tag == THREEFIELDS_SECOND_TAG)
            {
                textField.returnKeyType = UIReturnKeyNext;
            }
            else{
                textField.returnKeyType = UIReturnKeyDone;
            }
             break;
 
        }
            
        default:
            break;
    }
}

#pragma -mark UINavigationController delegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[HomeViewController class]]){
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
    NSLog(@"ht");
    return [self.phraseCountNumbers objectAtIndex:row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{

    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[self.phraseCountNumbers objectAtIndex:row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
        {
            self.numberOfFields = 1;
        }
            break;
            
        case 1:
        {
            self.numberOfFields = 2;
        }
            break;
        case 2:
        {
            self.numberOfFields = 3;
        }
            break;
            
        default:
            break;
    }
    
    
    if (!self.previewPickerContainer.hidden){
        
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.previewPickerContainer.alpha = 0;
                         } completion:^(BOOL finished) {
                             
                            self.previewPickerContainer.hidden = YES;
                             self.previewPickerContainer.alpha = 1;
                             
                             [UIView animateWithDuration:0.5f
                                              animations:^{
                                                  // if a field is on screen hide it
                                                  // then reset this property
                                                  if (self.previewCurrentField){
                                                      CGRect currentFrame = self.previewCurrentField.frame;
                                                      self.previewCurrentField.frame = CGRectMake(currentFrame.origin.x,
                                                                                                  SCREENHEIGHT,
                                                                                                  currentFrame.size.width,
                                                                                                  currentFrame.size.height);
                                                      self.previewCurrentField = nil;
                                                  }
                                                  
                                              } completion:^(BOOL finished) {
                                                  // bring up correct text field
                                                  
                                                  [UIView animateWithDuration:1.0f
                                                                        delay:0
                                                       usingSpringWithDamping:0.6f
                                                        initialSpringVelocity:0
                                                                      options:0
                                                                   animations:^{
                                                                       switch (self.numberOfFields) {
                                                                           case 1:
                                                                           {
                                                                               
                                                                               CGRect oneFrame = self.previewOneFieldContainer.frame;
                                                                               self.previewOneFieldContainer.frame = CGRectMake(oneFrame.origin.x,
                                                                                                                                SCREENHEIGHT - 350,
                                                                                                                                oneFrame.size.width,
                                                                                                                                oneFrame.size.height);
                                                                               [self clearTextFieldsText];
                                                                                self.previewCurrentField = self.previewOneFieldContainer;
                                                                           }
                                                                               break;
                                                                           case 2:
                                                                           {
                                                                               CGRect twoFrame = self.previewTwoFieldContainer.frame;
                                                                               self.previewTwoFieldContainer.frame = CGRectMake(twoFrame.origin.x,
                                                                                                                                SCREENHEIGHT - 350,
                                                                                                                                twoFrame.size.width,
                                                                                                                                twoFrame.size.height);
                                                                               
                                                                            
                                                                               [self clearTextFieldsText];
                                                                               self.previewCurrentField = self.previewTwoFieldContainer;

                                                                               
                                                                           }
                                                                               break;
                                                                           case 3:
                                                                           {
                                                                               CGRect threeFrame = self.previewThreeFieldContainer.frame;
                                                                               self.previewThreeFieldContainer.frame = CGRectMake(threeFrame.origin.x,
                                                                                                                                SCREENHEIGHT - 350,
                                                                                                                                threeFrame.size.width,
                                                                                                                                threeFrame.size.height);
                                                                               [self clearTextFieldsText];
                                                                               self.previewCurrentField = self.previewThreeFieldContainer;

                                                                               
                                                                           }
                                                                               break;
                                                                           default:
                                                                               break;
                                                                       }
                                                                       
                                                                   }
                                                                   completion:nil];
                                                  
                                            }];
                                        }];
        
    }

    
    
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
