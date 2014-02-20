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
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ODelegate>

@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property CGRect firstFrame;
@property (weak, nonatomic) IBOutlet UIButton *topMenuButton;
@property (strong,nonatomic)AVCaptureSession *session;
@property (strong,nonatomic)AVCaptureDevice *cameraDevice;
@property (strong,nonatomic)AVCaptureDeviceInput *cameraInput;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (strong,nonatomic)AVCaptureStillImageOutput *snapper;

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
    [self setupStylesAndMore];
    self.navigationController.navigationBarHidden = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // got a camera
        
        //  start camera
        
        NSError *error;
        
        self.session = [AVCaptureSession new];
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        self.cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.cameraDevice error:&error];
        
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
            self.previewLayer.frame = CGRectMake(10, 30, 300, 300);
            [self.view.layer addSublayer:self.previewLayer];
            [self.session startRunning];
            
            
            [NSTimer scheduledTimerWithTimeInterval:10
                                             target:self
                                           selector:@selector(snapPhoto)
                                           userInfo:nil
                                            repeats:NO];
            
        }
        else{
            NSLog(@"error creating camera input or output");
        }
        
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
 
   
}

-(void)viewDidAppear:(BOOL)animated
{
    self.navigationController.delegate = self;
    
}

- (void)dealloc
{
    }

- (void)setupStylesAndMore
{
    self.previewButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#e74c3c"] CGColor];
    self.previewButton.layer.cornerRadius = 30.0f;
    [self.previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    


}

- (IBAction)tappedMenuButton:(UIButton *)sender {
    [self showMenu];
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
                                                      UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 300, 300)];
                                                      iv.contentMode = UIViewContentModeScaleAspectFit;
                                                      iv.image = im;
                                                      [self.view addSubview:iv];
                                                      [self.previewLayer removeFromSuperlayer];
                                                      self.previewLayer = nil;
                                                      [self.session stopRunning];
                                                  });
                                              }];
}

- (void)toggleFlash
{
    if ([self.cameraDevice isFlashModeSupported:AVCaptureFlashModeOn]){
        NSError *error;
        if (self.cameraDevice.flashActive){
            // turn off
             [self.cameraDevice lockForConfiguration:&error];
             [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
             [self.cameraDevice unlockForConfiguration];
        }
        else{
            // turn on
            [self.cameraDevice lockForConfiguration:&error];
            [self.cameraDevice setFlashMode:AVCaptureFlashModeOn];
            [self.cameraDevice unlockForConfiguration];
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

#pragma -mark UINavigationController delegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSLog(@"ddd");
    if (operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[HomeViewController class]]){
        self.navigationController.navigationBarHidden = YES;
        if ([fromVC isKindOfClass:[ChallengeViewController class]]){
            NSLog(@"should remove top label");
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
