//
//  HomeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/18/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HomeViewController.h"
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


@interface HomeViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ODelegate,SenderPreviewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *snapPicButton;
@property CGRect firstFrame;
@property (weak, nonatomic) IBOutlet UIButton *topMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;

@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureDevice *cameraDevice;
@property (strong,nonatomic)AVCaptureDeviceInput *cameraInput;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic)AVCaptureStillImageOutput *snapper;
@property (strong,nonatomic)UIImageView *previewSnap;
@property (strong, nonatomic)UIView *previewControls;
@property (weak, nonatomic) IBOutlet UIButton *previewCancelButton;

@property (weak, nonatomic) IBOutlet UIButton *previewNextButton;




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

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // got a camera
        [self setupCamera];
        
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



- (void)dealloc
{
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
    [self.session stopRunning];
    self.session = nil;
    
    self.cameraDevice = nil;
    self.cameraInput = nil;
    self.snapper = nil;
    self.previewSnap = nil;
    self.previewControls = nil;
    

    
}


- (void)setupCamera
{
    NSError *error;
    
    self.session = [AVCaptureSession new];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
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
 
    
    self.snapPicButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#e74c3c"] CGColor];
    self.snapPicButton.layer.opacity = 0.6f;
    self.snapPicButton.layer.cornerRadius = 30.0f;
    [self.snapPicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.snapPicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    self.topMenuButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#ecf0f1"] CGColor];
    self.topMenuButton.layer.opacity = 0.5f;
    self.topMenuButton.layer.cornerRadius = 10.0f;
    [self.topMenuButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.topMenuButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    
    //self.flashButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#ecf0f1"] CGColor];
    //self.flashButton.layer.opacity = 0.5f;
    //self.flashButton.layer.cornerRadius = 10.0f;
    //[self.flashButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //[self.flashButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    
    self.flashButton.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:30];
    [self.flashButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bolt"] forState:UIControlStateNormal];
    

    


}

- (void)setupPreviewStylesAndMore
{
    self.previewCancelButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#ecf0f1"] CGColor];
    self.previewCancelButton.layer.opacity = 0.5f;
    self.previewCancelButton.layer.cornerRadius = 10.0f;
    [self.previewCancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.previewCancelButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    self.previewNextButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#ecf0f1"] CGColor];
    self.previewNextButton.layer.opacity = 0.5f;
    self.previewNextButton.layer.cornerRadius = 10.0f;
    [self.previewNextButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.previewNextButton setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];

    
    
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

- (IBAction)tappedNextPreview:(UIButton *)sender {
    
    //[self performSegueWithIdentifier:@"showFinalPreview" sender:self];
    SenderPreviewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"finalPreview"];
    vc.image = self.previewSnap.image;
    vc.name = @"This is a test";
    vc.phrase = @"bull honky";
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
             [self.flashButton setTitle:@"FlashOff" forState:UIControlStateNormal];

        }
        else if (!self.cameraDevice.flashActive){
            // turn on
            [self.cameraDevice lockForConfiguration:&error];
            [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
            [self.cameraDevice unlockForConfiguration];
            [self.flashButton setTitle:@"FlashOn" forState:UIControlStateNormal];
        
        }
    }
    else{
        NSLog(@"No flash available");
        return;
    }
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


- (void)showMenu
{
   
      [self.sideMenuViewController openMenuAnimated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self){
        self.navigationController.delegate = nil;
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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

#pragma -mark SemderPreview delegate

- (void)previewscreenDidMoveBack
{
    self.navigationController.navigationBarHidden = YES;
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
