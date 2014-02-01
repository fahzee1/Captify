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

#define kTileMargin 20

@interface ChallengeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dropHere;
@property (weak, nonatomic) IBOutlet UILabel *dragMe;
@property (strong, nonatomic) UIView *gameView;
@property (strong, nonatomic) NSMutableArray *tiles;
@property (strong, nonatomic) NSMutableArray *targets;
@property (strong, nonatomic) NSMutableArray *answerRects;
@property CGPoint originalCenter;
@property (strong, nonatomic) KeyboardView *keyboard;


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
    UILongPressGestureRecognizer *drag = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startDragging:)];
    [self.dragMe addGestureRecognizer:drag];
    drag.delegate = self;
    self.dragMe.userInteractionEnabled = YES;
    self.answer = @"i am shit";
    self.level = 3;
    [self showKeyboardWithTiles];
    
    
    
    
    
    //NSNumber *screenWidth = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width];
    //NSNumber *screenHeight = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height];
    //self.gameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [screenWidth doubleValue], [screenHeight doubleValue])];
    //[self.view addSubview:self.gameView];
    
    //self.answer = @"ogbuehi";
    //[self dealChallengeTiles];
	// Do any additional setup after loading the view.
}



-(void)showKeyboardWithTiles
{
    KeyboardView *keyboard = [[KeyboardView alloc] init];
    CGRect keyboardRect = keyboard.frame;
    self.keyboard = keyboard;
    
    // slice up bottom half of keyboard
    CGRect slice, remainder;
    CGRectDivide(keyboardRect, &slice, &remainder, 45.0, CGRectMaxYEdge);
    CGFloat keyboardWidth = CGRectGetWidth(remainder);
    CGFloat keyboardHeight = CGRectGetHeight(remainder);
    CGFloat rightBorder = CGRectGetMaxX(remainder);
    CGFloat leftBorder = CGRectGetMinX(remainder);
    
    NSLog(@"width is %f",keyboardWidth);
    NSLog(@"height is %f",keyboardHeight);
    NSLog(@"right border is %f",rightBorder);
    NSLog(@"left border is %f",leftBorder);
    
    // add backspace button to bottom slice
     UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteButton setTag:-1];
    [deleteButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.frame = CGRectMake(CGRectGetMaxX(slice)-80, slice.origin.y, 50, 35);
    [keyboard addSubview:deleteButton];
    
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
                              button.frame = CGRectMake(p.x,p.y, 35, 35);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:.4
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
            button.frame = CGRectMake(p.x,p.y, 35, 35);
            
            
            
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
        NSUInteger wordLength = [word length];
        NSString *holderString;
        if (wordLength < 2){
            holderString = [NSString stringWithFormat:@"%lu letter",(unsigned long)wordLength];
        }
        else{
            holderString = [NSString stringWithFormat:@"%lu letters",(unsigned long)wordLength];
        }
        UITextField *answer = [[AnswerFieldView alloc] initWithFrame:CGRectMake(startX, startY, startWidth, 35) placeholder:holderString];
        answer.delegate = self;
        
        // tags will be 10, 20, 30
        answer.tag = i + 1 *10;
        
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
        i ++;
    }

}

- (void)buttonTapped:(UIButton *)sender
{
    [[UIDevice currentDevice] playInputClick];
    if ([self.keyboard.target isKindOfClass:[UITextField class]]){
        UITextField *field = self.keyboard.target;
        int answerLength = [[field.placeholder substringToIndex:1] intValue];
        //delete button
        if (sender.tag == -1){
            if ([field.text length] > 0){
                NSString *text = field.text;
                NSUInteger length = text.length;
                text = [text substringToIndex:length -1];
                field.text = text;
                return;
            }
            
        }
        
        if (sender.tag != -1){
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


#pragma -mark UITextField Delegate
 - (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.inputView isKindOfClass:[KeyboardView class]]){
        ((KeyboardView *)textField.inputView).target = textField;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.inputView isKindOfClass:[KeyboardView class]]){
        ((KeyboardView *)textField.inputView).target = nil;
    }
}


@end
