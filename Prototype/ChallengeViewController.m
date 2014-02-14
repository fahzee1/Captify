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


#define FIRSTANSWERFIELD_TAG 100
#define SECONDANSWERFIELD_TAG 200
#define THIRDANSWERFIELD_TAG 300
#define TEST 1

@interface ChallengeViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic)CJPopup *successPop;
@property (strong, nonatomic)CJPopup *failPop;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

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
    
    self.scrollView.contentSize = CGSizeMake(320, 400);
    self.scrollView.scrollEnabled = YES;
    self.scrollView.delegate = self;
    
    self.answer = @"cj ogbuehi";
    self.name = @"test";
    self.numberOfFields = 2;
    
    self.navigationItem.title = self.name;
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
        UITextField *answer = [[AnswerFieldView alloc] initWithFrame:CGRectMake(startX, startY+100, startWidth, 35) placeholder:holderString];
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
            answer.center = CGPointMake(self.view.center.x, startY+100);
        }
   
        if (showResponder){
            //[answer becomeFirstResponder];
        }
        
        [self.scrollView addSubview:answer];
        startX += startWidth +10;
        showResponder = NO;
        
    }
    
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
    
    
    
    
    return choice;
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    

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
        NSLog(@"send challenge pick sting is %@!",[self returnChallengeChoiceString]);
        ReceiverPreviewViewController *previewScreen = [[ReceiverPreviewViewController alloc] init];
        // set all previews properties to show screen
        
        [self.navigationController pushViewController:previewScreen animated:YES];
    }
    

    return YES;
}




@end
