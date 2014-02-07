//
//  ChallengeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengeViewController.h"
#import "TilesView.h"
#import "KeyboardView.h"
#import "AnswerFieldView.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Challenge+Utils.h"
#import "AwesomeAPICLient.h"

#define kTileMargin 20
#define DELETEBUTTON_TAG -1
#define NEXTBUTTON_TAG -2
#define FIRSTANSWERFIELD_TAG 100
#define SECONDANSWERFIELD_TAG 200
#define THIRDANSWERFIELD_TAG 300
#define TEST 1

@interface ChallengeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dropHere;
@property (weak, nonatomic) IBOutlet UILabel *dragMe;
@property CGPoint originalCenter;
@property (strong, nonatomic) UIView *gameView;
@property (strong, nonatomic) NSMutableArray *targets;

@property (assign,nonatomic)NSInteger attempts; // used to track how many submissions user made; must be < 3
@property (strong, nonatomic) NSMutableArray *tiles;   // list of buttons for answer (used to shuffle)
@property (strong, nonatomic) KeyboardView *keyboard; // custom keyboard replaces system keyboard
@property (strong, nonatomic) UIButton *doneButton;  // used when user is ready to submit answer
@property (strong, nonatomic) UIButton *nextButton;  // used to move to next text field when more then 1 are available
@property (strong, nonatomic) UIButton *deleteButton; // backspace button;
@property CGRect doneButtonFrame; // used in textfield delegate to set done button in keyboard
@property (assign,nonatomic)NSInteger challengePoints;
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
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    UILongPressGestureRecognizer *drag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startDragging:)];
    [self.dragMe addGestureRecognizer:drag];
    drag.delegate = self;
    
    // buttons
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteButton setTag:DELETEBUTTON_TAG];
    [deleteButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(checkAnswer) forControlEvents:UIControlEventTouchUpInside];
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton setTag:NEXTBUTTON_TAG];
    [nextButton addTarget:self action:@selector(toggleFirstResponder:) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton = nextButton;
    self.doneButton = doneButton;
    self.deleteButton = deleteButton;
    
    
    self.dragMe.userInteractionEnabled = YES;
    self.answer = @"cj";
    self.hint = @"cj";
    self.level = 1;
    self.attempts = 0;
    self.challenge_id = @"0001";
    [self showKeyboardWithTiles];
    
    
    
    
    
    
    //NSNumber *screenWidth = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width];
    //NSNumber *screenHeight = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height];
    //self.gameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [screenWidth doubleValue], [screenHeight doubleValue])];
    //[self.view addSubview:self.gameView];
    
    //self.answer = @"ogbuehi";
    //[self dealChallengeTiles];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if (self.level == 1){
        self.challengePoints = 5;
    }
    if (self.level == 2){
        self.challengePoints = 15;
    }
    if (self.level == 3){
        self.challengePoints = 25;
    }

}


-(void)showKeyboardWithTiles
{
    KeyboardView *keyboard = [[KeyboardView alloc] init];
    
    //resize keyboard based on # of letters
    NSUInteger totalLetters = [self.answer length] - (self.level - 1);
    if (totalLetters <= 6){
        keyboard.frame = CGRectMake(keyboard.frame.origin.x, keyboard.frame.origin.y, keyboard.frame.size.width, keyboard.frame.size.height - 100);
    }
    if (totalLetters > 6 && totalLetters < 13){
        keyboard.frame = CGRectMake(keyboard.frame.origin.x, keyboard.frame.origin.y, keyboard.frame.size.width, keyboard.frame.size.height - 50);
    }
    CGRect keyboardRect = keyboard.frame;
    self.keyboard = keyboard;
    
    // slice up bottom half of keyboard
    CGRect slice, remainder;
    CGRectDivide(keyboardRect, &slice, &remainder, 45.0, CGRectMaxYEdge);
    //CGFloat keyboardWidth = CGRectGetWidth(remainder);
    //CGFloat keyboardHeight = CGRectGetHeight(remainder);
    CGFloat rightBorder = CGRectGetMaxX(remainder);
    //CGFloat leftBorder = CGRectGetMinX(remainder);
    
    //NSLog(@"width is %f",keyboardWidth);
    //NSLog(@"height is %f",keyboardHeight);
    //NSLog(@"right border is %f",rightBorder);
    //NSLog(@"left border is %f",leftBorder);
    
    // add backspace button to bottom slice
    self.deleteButton.frame = CGRectMake(CGRectGetMaxX(slice)-120, slice.origin.y, 50, 35);
    self.nextButton.frame = CGRectMake(CGRectGetMaxX(slice)-70, slice.origin.y, 50, 35);
    self.doneButtonFrame = self.nextButton.frame;
    if (self.level > 1){
        [keyboard addSubview:self.nextButton];
    }
    else{
        self.doneButton.frame = self.nextButton.frame;
        [keyboard addSubview:self.doneButton];
    }
    [keyboard addSubview:self.deleteButton];
    
    // loop through the answer and add to list to be shuffled
    self.tiles = [NSMutableArray arrayWithCapacity:[self.answer length]];
    for (int i = 0; i < [self.answer length]; i++){
        // loop through answer and create button for each letter
        NSString *string = [NSString stringWithFormat:@"%c",[self.answer characterAtIndex:i]];
        if (![string isEqualToString:@" "]){
            [self.tiles addObject:string];
        }
    }
    
    // shuffle list
    for (int x = 0; x < [self.tiles count]; x++){
        int rand =  (arc4random() % ([self.tiles count] - x)) + x;
        [self.tiles exchangeObjectAtIndex:x withObjectAtIndex:rand];
    }

    // start with tile positioned 10 pixels to the right and
    // 30 pixels down
    CGPoint p = remainder.origin;
    p.x += 10;
    p.y += 30;
    
    for (NSString *string in self.tiles){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundImage:[UIImage imageNamed:@"profile-placeholder"] forState:UIControlStateNormal];
     
        // animate display buttons are 35x35
        [UIView animateWithDuration:1.5
                              delay:0
             usingSpringWithDamping:.5
              initialSpringVelocity:1
                            options:0
                         animations:^{
                              button.frame = CGRectMake(p.x,p.y, 30, 35);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.2
                                              animations:^{
                                                  [button setTitle:string forState:UIControlStateNormal];
                                              }];

                         }];

        // if button reached the end of keyboard start new row
        // by pushing 50 pixels down from current position and
        // restarting at 10 from the right
        if (button.frame.origin.x + 20 >= rightBorder){
            p.y += 50;
            p.x = 10;
            button.frame = CGRectMake(p.x,p.y, 30, 35);
            
            
            
        }
        
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        // add button to keyboard
        [keyboard addSubview:button];
        p.x += 50;
        

    }
    
    [self layAnswerFieldsWithKeyboard:keyboard];
}



- (void)layAnswerFieldsWithKeyboard:(UIView *)keyboard
{
    NSParameterAssert(keyboard);
    
    // answer textfields
    NSArray *splitAnswer = [self.answer componentsSeparatedByString:@" "];
    NSAssert(self.level == [splitAnswer count], @"answer length should be same as level");
    
    CGFloat startX = self.view.center.x;
    CGFloat startY = self.view.center.y +30;
    CGFloat startWidth = 90;
    if (self.level == 2){
        startX -= 95;
    }
    if (self.level == 3){
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
        
        if (self.level ==1){
            answer.center = CGPointMake(self.view.center.x, startY);
        }
        answer.inputView = keyboard;
        if (showResponder){
            [answer becomeFirstResponder];
        }
        [self.view addSubview:answer];
        startX += startWidth +10;
        showResponder = NO;

    }

}

- (void)toggleFirstResponder:(UIButton *)sender
{
    NSParameterAssert(sender);
    
    UIView *firstField = [self.view viewWithTag:FIRSTANSWERFIELD_TAG];
    UIView *secondField = nil;
    UIView *thirdField = nil;
    if (self.level == 3){
        secondField = [self.view viewWithTag:SECONDANSWERFIELD_TAG];
        thirdField = [self.view viewWithTag:THIRDANSWERFIELD_TAG];
    }
    else{
        secondField = [self.view viewWithTag:SECONDANSWERFIELD_TAG];
    }
    
    
    if ([firstField isFirstResponder] && secondField){
        [secondField becomeFirstResponder];
        if (self.level == 2) {
            self.doneButton.frame = sender.frame;
            sender.hidden = YES;
            [self.keyboard addSubview:self.doneButton];

        }
        return;
    }
    
    if (secondField && [secondField isFirstResponder]){
        if (thirdField){
            [thirdField becomeFirstResponder];
            if (self.level == 3){
                self.doneButton.frame = sender.frame;
                sender.hidden = YES;
                [self.keyboard addSubview:self.doneButton];
            }

            return;
        }
    }
    

}

- (void)buttonTapped:(UIButton *)sender
{
    NSParameterAssert(sender);
    
    [[UIDevice currentDevice] playInputClick];
    if ([self.keyboard.target isKindOfClass:[UITextField class]]){
        UITextField *field = self.keyboard.target;
        int answerLength = [[field.placeholder substringToIndex:1] intValue];
        //delete button
        if (sender.tag == DELETEBUTTON_TAG){
            if ([field.text length] > 0){
                NSString *text = field.text;
                NSUInteger length = text.length;
                text = [text substringToIndex:length -1];
                field.text = text;
                return;
            }

            
        }
        
        if (sender.tag != DELETEBUTTON_TAG){
            if ([field.text length] == 0){
                field.text = sender.titleLabel.text;
                return;
            }
            else if ([field.text length] >= answerLength){
                return;
            }
            else{
                field.text = [field.text stringByAppendingString:sender.titleLabel.text];
            }
        }
    }
}

- (void)checkAnswer
{
   
    if (self.attempts >= 3){
        //bail
        return;
    }
    self.attempts += 1;
    NSAssert(self.attempts < 4, @"User can only make three attempts. Look at self.attempts");
    UITextField *firstField = ((UITextField *)[self.view viewWithTag:FIRSTANSWERFIELD_TAG]);
    UITextField *secondField = nil;
    UITextField *thirdField = nil;
    
    if (![firstField isKindOfClass:[UITextField class]]){
        //bail
        return;
    }
    
    if (self.level == 3){
        secondField = ((UITextField *)[self.view viewWithTag:SECONDANSWERFIELD_TAG]);
        thirdField = ((UITextField *)[self.view viewWithTag:THIRDANSWERFIELD_TAG]);
        
        if (![secondField isKindOfClass:[UITextField class]] && ![thirdField isKindOfClass:[UITextField class]]){
            return;
        }

        
    }
    if (self.level == 2){
        secondField = ((UITextField *)[self.view viewWithTag:SECONDANSWERFIELD_TAG]);
        if (![secondField isKindOfClass:[UITextField class]]){
            return;
        }
        

    }
    
    NSString *tryAnswer;
    if (self.level == 3){
        NSAssert(thirdField, @"level 3 should have third field");
        tryAnswer = [NSString stringWithFormat:@"%@ %@ %@",firstField.text,secondField.text,thirdField.text];

    }
    
    if (self.level == 2){
        NSAssert(secondField, @"level 2 should have second field");
        tryAnswer = [NSString stringWithFormat:@"%@ %@",firstField.text,secondField.text];
    }
    
    if (self.level == 1){
        NSAssert(firstField, @"level 1 should have a field");
        tryAnswer = firstField.text;
    }
    
    if ([tryAnswer isEqualToString:self.answer]){
        // show success screen
        //[self showAlertWithTitle:nil message:@"Answer is correct!"];
        
        NSNumber *previousScore = self.myUser.score;
        NSNumber *newScore = [NSNumber numberWithInt:[previousScore intValue] + self.challengePoints];
        self.myUser.score = newScore;
        self.myChallenge.success = [NSNumber numberWithBool:YES];
        
        NSError *error;
        if ([self.myUser.managedObjectContext hasChanges]){
            if (![self.myUser.managedObjectContext save:&error]){
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        NSAssert(self.myUser.score != previousScore, @"Score wasnt updated from %@ to %@",previousScore,newScore);
        NSAssert(self.myChallenge.success, @"Challege success should be 1 but it is %@",self.myChallenge.success);
        
        self.homeController.showResults = YES;
        self.homeController.success = YES;
        if (!TEST){
            [self sendChallengeResults:[self.myChallenge.success boolValue]];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        
    }
    if (![tryAnswer isEqualToString:self.answer] && self.attempts == 3){
        // show failure screen
        //[self showAlertWithTitle:nil message:@"Answer is incorrect and you have no more attempts!"];
        
        self.homeController.showResults = YES;
        self.homeController.success = NO;
        if (!TEST){
            [self sendChallengeResults:NO];
        }

        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    if (![tryAnswer isEqualToString:self.answer] && self.attempts != 3){
        // let user continue playing
        [self showAlertWithTitle:nil message:@"Answer is incorrect. Try again"];
        return;
    }
    
    
}


- (void)sendChallengeResults:(BOOL)success
{
    NSDictionary *params = @{@"username": [[NSUserDefaults standardUserDefaults]valueForKey:@"username"],
                             @"challenge_id": self.myChallenge.challenge_id,
                             @"success": [NSNumber numberWithBool:success],
                             @"score": self.myUser.score};
    
    if ([[AwesomeAPICLient sharedClient] connected]){
            [Challenge sendChallengeResults:params
                              challenge:self.myChallenge];
    }
    else{
        NSError *error;
        self.myChallenge.active = [NSNumber numberWithBool:YES];
        if (![self.myChallenge.managedObjectContext save:&error]){
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    
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
    
    self.tiles = nil;
}


- (void)startDragging:(UILongPressGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:[self.dragMe superview]];
    if (CGPointEqualToPoint(self.originalCenter, CGPointZero)){
        self.originalCenter = gesture.view.center;
    }

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
             NSLog(@"draggig");
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            gesture.view.center = location;
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGRect dragItem = [gesture.view convertRect:gesture.view.frame toView:[gesture.view superview]];
            CGRect targetItem = [self.dropHere convertRect:self.dropHere.frame toView:[self.dropHere superview]];
            if (CGRectIntersectsRect(dragItem, targetItem)){
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     gesture.view.center = self.dropHere.center;
                                 }];
            }else{
                [UIView animateWithDuration:0.4
                                 animations:^{
                                     gesture.view.center = self.originalCenter;
                                     self.originalCenter = CGPointZero;
                                 }];
            }
            
            break;
        }
        default:
            break;
    }
    
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
        NSDictionary *params = @{@"username": [[NSUserDefaults standardUserDefaults]valueForKey:@"username"],
                                 @"challenge_id":self.challenge_id,
                                 @"type":[NSNumber numberWithInt:self.level],
                                 @"answer":self.answer,
                                 @"hint":self.hint,
                                 //@"theUser":self.myFriend,
                                 @"theUser":self.myUser,
                                 @"level":[NSNumber numberWithInt:self.level]
                                 };
        _myChallenge = [Challenge GetOrCreateChallengeWithParams:params
                                              inManagedObjectContext:self.myUser.managedObjectContext];
    }
    return _myChallenge;
}


#pragma -mark UITextField Delegate
 - (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.inputView isKindOfClass:[KeyboardView class]]){
        ((KeyboardView *)textField.inputView).target = textField;
    }
    
    if (self.level == 3 && textField.tag == THIRDANSWERFIELD_TAG){
        UIButton *done = self.doneButton;
        done.frame = self.doneButtonFrame;
        self.nextButton.hidden = YES;
        [self.keyboard addSubview:done];
        
    }
    
    if (self.level ==2 && textField.tag == SECONDANSWERFIELD_TAG){
        UIButton *done = self.doneButton;
        done.frame = self.doneButtonFrame;
        self.nextButton.hidden = YES;
        [self.keyboard addSubview:done];

    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.inputView isKindOfClass:[KeyboardView class]]){
        ((KeyboardView *)textField.inputView).target = nil;
    }
}


@end
