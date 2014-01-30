//
//  ChallengeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengeViewController.h"
#import "TilesView.h"
#import "keyboardView.h"

#define kTileMargin 20


@interface ChallengeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dropHere;
@property (weak, nonatomic) IBOutlet UILabel *dragMe;
@property (strong, nonatomic) UIView *gameView;
@property (strong, nonatomic) NSMutableArray *tiles;
@property (strong, nonatomic) NSMutableArray *targets;
@property (strong, nonatomic) NSMutableArray *tileRects;
@property CGPoint originalCenter;
@property NSString *answer;
@property NSInteger level;
@property (weak, nonatomic) IBOutlet UITextField *demoTextField;


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
    self.answer = @"cjogbuehiamakakaka";
    self.level = 2;
    self.demoTextField.delegate = self;
    [self.demoTextField becomeFirstResponder];
    
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
    UIView *keyboard = [[keyboardView alloc] init];
    CGRect keyboardRect = keyboard.frame;
    
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
    [deleteButton addTarget:self action:@selector(textFieldButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
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
        
        [button addTarget:self action:@selector(textFieldButtonCliked:) forControlEvents:UIControlEventTouchUpInside];
        
        // add button to keyboard
        [keyboard addSubview:button];
        p.x += 50;
        

    }

    self.demoTextField.inputView = keyboard;


}


- (void)textFieldButtonCliked:(UIButton *)sender
{
    [[UIDevice currentDevice] playInputClick];
    // delete button
    if (sender.tag == -1){
        if ([self.demoTextField.text length] > 0){
            NSString *text = self.demoTextField.text;
            NSUInteger length = text.length;
            text = [text substringToIndex:length -1];
            self.demoTextField.text = text;
            return;
        }

    }
    
    
    if (sender.tag != -1){
    
        if ([self.demoTextField.text length] == 0){
            self.demoTextField.text = sender.titleLabel.text;
            return;
        }
        else if ([self.demoTextField.text length] >= [self.answer length]){
            // dont do anything
            return;
        }
        else{
            self.demoTextField.text = [self.demoTextField.text stringByAppendingString:sender.titleLabel.text];
            return;
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.tiles = nil;
    self.tileRects = nil;
}


- (void)dealChallengeTiles
{
    NSNumber *screenWidth = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width];
    NSNumber *screenHeight = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height];
    NSNumber *answerLength = [NSNumber numberWithUnsignedInteger:[self.answer length]];

    double ninetyScreen = ([screenWidth doubleValue]*0.9 / [answerLength doubleValue]) - kTileMargin;
    double xOffset = ([screenWidth doubleValue] - [answerLength doubleValue] * (ninetyScreen + kTileMargin))/2;
    xOffset += ninetyScreen/2;
    
    // create tiles list and add tiles
    self.tiles = [NSMutableArray arrayWithCapacity:[self.answer length]];
    for (NSUInteger i=0; i < [self.answer length]; i++){
        NSString *letter = [self.answer  substringWithRange:NSMakeRange(i, 1)];
        if (![letter isEqualToString:@" "]){
            TilesView *tile = [[TilesView alloc] initWithLetter:letter andSideLength:ninetyScreen];
            [self.tiles addObject:tile];
            
        }
    }
    
    // shuffle list
    for (int x = 0; x < [self.tiles count]; x++){
        int rand =  (arc4random() % ([self.tiles count] - x)) + x;
        [self.tiles exchangeObjectAtIndex:x withObjectAtIndex:rand];
    }
    
    // add tiles to game view
    int x = 0;
    for (TilesView *tile in self.tiles){
        tile.center = CGPointMake(xOffset + x*(ninetyScreen + kTileMargin), [screenHeight doubleValue]/4*3.6);
        [tile randomize];
        [self.gameView addSubview:tile];
        x++;
    }
    
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



@end
