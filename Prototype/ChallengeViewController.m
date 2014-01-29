//
//  ChallengeViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 1/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "ChallengeViewController.h"
#import "TilesView.h"

const int kTileMargin = 20;

@interface ChallengeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dropHere;
@property (weak, nonatomic) IBOutlet UILabel *dragMe;
@property (strong, nonatomic) UIView *gameView;
@property (strong, nonatomic) NSMutableArray *tiles;
@property (strong, nonatomic) NSMutableArray *targets;
@property CGPoint originalCenter;
@property NSString *answer;
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
    self.answer = @"ogbuehi";
    [self.demoTextField becomeFirstResponder];
    
    UIView *keyboard = [[[NSBundle mainBundle] loadNibNamed:@"Keyboard" owner:self options:nil] lastObject];
    CGRect keyboardRect = keyboard.frame;
    
    for (int i = 0; i < [self.answer length]; i++){
        NSString *string = [NSString stringWithFormat:@"%c",[self.answer characterAtIndex:i]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:string forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"profile-placeholder"] forState:UIControlStateNormal];
        keyboardRect.size = CGSizeMake(keyboardRect.size.width, keyboardRect.size.height);
        CGPoint random = [self randomPointInRect:keyboardRect];
        button.frame = CGRectMake(random.x,random.y, 35, 35);
        [button addTarget:self action:@selector(showText:) forControlEvents:UIControlEventTouchUpInside];
        [keyboard addSubview:button];

    }
  
    self.demoTextField.inputView = keyboard;

    
    
    
    
    
    //NSNumber *screenWidth = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width];
    //NSNumber *screenHeight = [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height];
    //self.gameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [screenWidth doubleValue], [screenHeight doubleValue])];
    //[self.view addSubview:self.gameView];
    
    //self.answer = @"ogbuehi";
    //[self dealChallengeTiles];
	// Do any additional setup after loading the view.
}

- (CGPoint)randomPointInRect:(CGRect)r
{
    CGPoint p = r.origin;
    
    p.x += arc4random() % (int)r.size.width;
    p.y += arc4random() % (int)r.size.height;
    
    return p;
}

- (void)showText:(UIButton *)sender
{
    if ([self.demoTextField.text length] == 0){
        self.demoTextField.text = sender.titleLabel.text;
    }
    else{
        self.demoTextField.text = [self.demoTextField.text stringByAppendingString:sender.titleLabel.text];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
