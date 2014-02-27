//
//  InviteFriendViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "InviteFriendViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface InviteFriendViewController ()<FBViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *selectedFriendsView;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end

@implementation InviteFriendViewController

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
    
    if (!FBSession.activeSession.isOpen){
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          if (error){
                                              UIAlertView *alert = [[UIAlertView alloc]
                                                                    initWithTitle:@"Error"
                                                                    message:error.localizedDescription
                                                                    delegate:nil
                                                                    cancelButtonTitle:@"Ok"
                                                                    otherButtonTitles: nil];
                                              [alert show];
                                          }
                                          else if (session.isOpen){
                                              [self viewDidLoad];
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil){
        
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Invite Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma -mark FBFRIENDS delegate


- (void)facebookViewControllerDoneWasPressed:(id)sender
{
    for (id<FBGraphUser> user in self.friendPickerController.selection){
        NSLog(@"%@",user.name);
    }
}


- (void)facebookViewControllerCancelWasPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
