//
//  ChallengeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengeViewController.h"
#import "AnswerFieldView.h"
#import "AppDelegate.h"
#import "Challenge+Utils.h"
#import "AwesomeAPICLient.h"
#import "CJPopup.h"
#import "ReceiverPreviewViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIColor+HexValue.h"


#define FIRSTANSWERFIELD_TAG 100
#define SECONDANSWERFIELD_TAG 200
#define THIRDANSWERFIELD_TAG 300
#define TEST 1

@interface ChallengeViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic)CJPopup *successPop;
@property (strong, nonatomic)CJPopup *failPop;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *nonKeyboardDoneButton;
@property (nonatomic)CGRect answerFieldRect;

@end

@implementation ChallengeViewController

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
    self.challengeNameLabel.layer.backgroundColor = [[UIColor colorWithHexString:@"#3498db"] CGColor];
    self.challengeNameLabel.textColor = [UIColor whiteColor];
    self.challengeNameLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:17];
    
    self.nonKeyboardDoneButton.layer.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] CGColor];
    [self.nonKeyboardDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nonKeyboardDoneButton.titleLabel.font = [UIFont fontWithName:@"Optima-ExtraBlack" size:25];
    self.nonKeyboardDoneButton.alpha = 0;
    
    
    self.scrollView.contentSize = CGSizeMake(320,450);
    self.scrollView.scrollEnabled = YES;
    self.scrollView.delegate = self;
    
    self.answer = @"cj ogbuehi";
    self.name = @"guess what im eating";
    self.numberOfFields = 2;
    self.challengeNameLabel.text = self.name;
    
    [self layAnswerFields];
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
   
}

- (void)dealloc
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}


- (IBAction)nonKeyboardDoneButtonPressed:(UIButton *)sender {
    if ([self returnChallengeChoiceString] != nil){
        [self performSegueWithIdentifier:@"goToRecieverPreview" sender:self];
    }
}


- (void)layAnswerFields
{
    
    // answer textfields
    NSArray *splitAnswer = [self.answer componentsSeparatedByString:@" "];
    NSAssert(self.numberOfFields == [splitAnswer count], @"answer length should be same as level");
    
    CGFloat startX = self.scrollView.center.x;
    CGFloat startY = self.scrollView.center.y;
    CGFloat startWidth = 90;
    if (self.numberOfFields == 2){
        startX -= 95;
    }
    if (self.numberOfFields == 3){
        startX -= 144;
    }
    
    BOOL showResponder = YES;
    int i = 0;
    for (NSString *word in splitAnswer){
        i ++;
        NSUInteger wordLength = [word length];
        NSString *holderString;
        if (wordLength < 2 && ![word intValue]){
            holderString = [NSString stringWithFormat:@"%lu letter",(unsigned long)wordLength];
        }
        if (wordLength < 2 && [word intValue]){
            holderString = [NSString stringWithFormat:@"%lu number",(unsigned long)wordLength];
        }
        if (wordLength >= 2 && ![word intValue]){
            holderString = [NSString stringWithFormat:@"%lu letters",(unsigned long)wordLength];
        }
        if (wordLength >= 2 && [word intValue]){
            // doesnt work if numbers not in front of strings
            holderString = [NSString stringWithFormat:@"%lu letters/numbers",(unsigned long)wordLength];
        }
        UITextField *answer = [[AnswerFieldView alloc] initWithFrame:CGRectMake(startX, startY, startWidth, 35) placeholder:holderString];
        answer.delegate = self;
        
        // tags will be 10, 20, 30
        answer.tag = i *100;
        
        if (word == [splitAnswer lastObject]){
            answer.returnKeyType = UIReturnKeyDone;
        }
        else{
            answer.returnKeyType = UIReturnKeyNext;
        }
        
        if (self.numberOfFields ==1){
            answer.center = CGPointMake(self.view.center.x, startY);
        }
   
        if (showResponder){
            //[answer becomeFirstResponder];
        }
        
        if (CGRectIsEmpty(self.answerFieldRect)){
            NSLog(@"hit");
            self.answerFieldRect = answer.frame;
        }
        
        [self.scrollView addSubview:answer];
        startX += startWidth +10;
        showResponder = NO;
        
    }
    
    
    UIView *answerBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.answerFieldRect.origin.y -15, [UIScreen mainScreen].bounds.size.width,self.answerFieldRect.size.height +30 )];
    answerBorder.backgroundColor = [UIColor colorWithHexString:@"#2ecc71"];
    answerBorder.layer.opacity = 0.2f;

    [self.scrollView addSubview:answerBorder];
    [self.scrollView sendSubviewToBack:answerBorder];
    
}


- (void)toggleFirstResponder
{

    
    UIView *firstField = [self.view viewWithTag:FIRSTANSWERFIELD_TAG];
    UIView *secondField = nil;
    UIView *thirdField = nil;
    if (self.numberOfFields == 3){
        secondField = [self.view viewWithTag:SECONDANSWERFIELD_TAG];
        thirdField = [self.view viewWithTag:THIRDANSWERFIELD_TAG];
    }
    else{
        secondField = [self.view viewWithTag:SECONDANSWERFIELD_TAG];
    }
    
    
    if ([firstField isFirstResponder] && secondField){
        [secondField becomeFirstResponder];
        return;
    }
    
    if (secondField && [secondField isFirstResponder]){
        if (thirdField){
            [thirdField becomeFirstResponder];
            return;
        }
    }
    
    
}

- (NSString *)returnChallengeChoiceString
{
    NSString *choice;
    UITextField *firstField = ((UITextField *)[self.view viewWithTag:FIRSTANSWERFIELD_TAG]);
    UITextField *secondField = nil;
    UITextField *thirdField = nil;
    
    if (![firstField isKindOfClass:[UITextField class]]){
        //bail
        return choice;
    }
    
    if (self.numberOfFields == 3){
        secondField = ((UITextField *)[self.view viewWithTag:SECONDANSWERFIELD_TAG]);
        thirdField = ((UITextField *)[self.view viewWithTag:THIRDANSWERFIELD_TAG]);
        
        if (![secondField isKindOfClass:[UITextField class]] && ![thirdField isKindOfClass:[UITextField class]]){
            return choice;
        }
        
        
    }
    if (self.numberOfFields == 2){
        secondField = ((UITextField *)[self.view viewWithTag:SECONDANSWERFIELD_TAG]);
        if (![secondField isKindOfClass:[UITextField class]]){
            return choice;
        }
        
    }
    
    // all views are within in scroll view not self.view
    BOOL didNotify = NO;
    for (UIView *view in self.view.subviews){
        if ([view isKindOfClass:[UIScrollView class]]){
            for (id view2 in view.subviews){
                if ([view2 isKindOfClass:[UITextField class]]){
                    if ([((UITextField *)view2).text isEqualToString:@""]){
                        if (!didNotify){
                            NSLog(@"notify");
                            didNotify = YES;
                            [self showAlertWithTitle:@"Sheesh!" message:@"No field can be empty"];
                            return choice;
                        }
                    }
                }
            }
        }
    }
    
    
    if (self.numberOfFields == 3){
        NSAssert(thirdField, @"level 3 should have third field");
        choice = [NSString stringWithFormat:@"%@ %@ %@",firstField.text,secondField.text,thirdField.text];
        
    }
    
    if (self.numberOfFields == 2){
        NSAssert(secondField, @"level 2 should have second field");
        choice = [NSString stringWithFormat:@"%@ %@",firstField.text,secondField.text];
    }
    
    if (self.numberOfFields == 1){
        NSAssert(firstField, @"level 1 should have a field");
        choice = firstField.text;
    }
    
    
    choice = [NSString stringWithFormat:@" \"%@\" ",choice];
    
    return choice;
}




- (void)showDoneButtonAnimated
{
    [UIView animateWithDuration:.6
                     animations:^{
                         self.nonKeyboardDoneButton.alpha = 1;
                     }];

}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
{
    if (!title){
        title = @"Results";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma -mark Lazy Instantiation
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


- (Challenge *)myChallenge
{
    if (!_myChallenge){
        // create and return challenge
        }
    return _myChallenge;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self toggleFirstResponder];
    if (textField.returnKeyType == UIReturnKeyDone){
        if ([self returnChallengeChoiceString] != nil){
              [self performSegueWithIdentifier:@"goToRecieverPreview" sender:self];
        }
        
    }
    

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.numberOfFields == 1 && textField.tag == FIRSTANSWERFIELD_TAG){
        [self showDoneButtonAnimated];
    }
    
    if (self.numberOfFields == 2 && textField.tag == SECONDANSWERFIELD_TAG){
        [self showDoneButtonAnimated];
    }
    
    if (self.numberOfFields == 3 && textField.tag ==THIRDANSWERFIELD_TAG){
        [self showDoneButtonAnimated];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier]isEqualToString:@"goToRecieverPreview"]){
        UIViewController *destination = segue.destinationViewController;
        if ([destination isKindOfClass:[ReceiverPreviewViewController class]]){
            NSLog(@"%@",destination);
            ReceiverPreviewViewController *preview = (ReceiverPreviewViewController *)destination;
            preview.phrase = [self returnChallengeChoiceString];
            preview.image = self.challengeImage.image;
            preview.challengeName = self.name;
            
        }
    }
}

@end
