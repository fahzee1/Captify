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
#import "GoHomeTransition.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ChallengeViewController.h"
#import "UIColor+HexValue.h"

@interface HomeViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ODelegate>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property BOOL fullScreen;
@property CGRect firstFrame;
@property UITapGestureRecognizer *tap;
@end

@implementation HomeViewController

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
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        // no camera
        NSLog(@"no camera");
    }
    
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]){
        NSLog(@"no front camera");
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        NSLog(@"no photo library");
    }
    
    
    
    //[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    //User *friend = [User createTestFriendWithName:@"test2" context:self.myUser.managedObjectContext];
    //Challenge *ch = [Challenge createTestChallengeWithUser:friend];
    
    self.fullScreen = NO;
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeFullScreen)];
    self.tap.delegate = self;
    [self.tap setNumberOfTapsRequired:1];
    [self.profileImage addGestureRecognizer:self.tap];
    self.profileImage.userInteractionEnabled =YES;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
     self.navigationController.delegate = self;
    //if user not logged in segue to login screen
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"logged"] boolValue]){
        [self performSegueWithIdentifier:@"segueToLogin" sender:self];
        return;
    }
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"logged"] boolValue]){
        self.username.text = self.myUser.username;
        self.score.text = [self.myUser.score stringValue];
        [User getFacebookPicWithUser:self.myUser
                           imageview:self.profileImage];
    }
    

    if (self.showResults){
        //self.showResults = NO;
        /*
        ResultsViewController *results = [self.storyboard instantiateViewControllerWithIdentifier:@"resultsScreen"];
        if (self.success){
            results.success = self.success;
        }
        */
          NSLog(@"hit2");
        [self performSegueWithIdentifier:@"segueToResults" sender:self];
          NSLog(@"hit3");
        self.showResults = NO;
        
        
    }
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
        [self.view addSubview:imgPicker.view];
        
    }
}


- (void)showMenu
{
    /*
    NSLog(@"hit");
      [self.sideMenuViewController openMenuAnimated:YES completion:nil];
     */
}
- (void)makeFullScreen
{
    if (!self.fullScreen){
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             self.firstFrame = self.profileImage.frame;
                             [self.profileImage setFrame:[[UIScreen mainScreen] bounds]];
                            
                         } completion:^(BOOL finished) {
                             self.fullScreen = YES;
                         }];
        return;
    }
    else{
        [UIView animateWithDuration:0.5
                              delay:0
                            options:0
                         animations:^{
                             [self.profileImage setFrame:self.firstFrame];
                         } completion:^(BOOL finished) {
                             self.fullScreen = NO;
                         }];
        return;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL should = YES;
    if (gestureRecognizer == self.tap){
        should = (touch.view == self.profileImage);
        
    }
    return should;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.delegate == self){
        self.navigationController.delegate = nil;
    }
}


- (IBAction)logout:(UIButton *)sender {
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
    /*
    self.myUser = nil;
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended){
        //close the session and remove the access token from the cache.
        //the session state handler in the app delegate will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }

    [self performSegueWithIdentifier:@"segueToLogin" sender:self];
     */
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
    if (operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[HomeViewController class]]){
        return [GoHomeTransition new];
    }
    
    
    
    return nil;
}
 
@end
