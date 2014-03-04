//
//  HistoryDetailViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/28/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryDetailViewController.h"
#import "HistoryDetailCell.h"
#import "NSString+FontAwesome.h"
#import "FAImageView.h"
#import "UIFont+FontAwesome.h"
#import "NSDate+TimeAgo.h"
#import "UIView+Screenshot.h"
#import "FacebookFriends.h"
#import "UIImage+Utils.h"
#import "UIColor+HexValue.h"
#import "DraggableCaption.h"



@interface HistoryDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, DraggableCaptionDelegate>

@property NSArray *data;
@property BOOL hideSelectButtons;
@property BOOL shareToFacebook;
@property BOOL shareContainerOnScreen;
@property NSString *selectedCaption;
@property UIImageView *finalContainerScreen;
@property UIImage *finalImage;
@property (strong,nonatomic)UIView *containerView;
@property (strong, nonatomic)UIView *shareControls;
@property (weak, nonatomic) IBOutlet UILabel *finalCaptionLabel;

@property (weak, nonatomic) IBOutlet UIView *finalShareContainer;
@property (weak, nonatomic) IBOutlet UILabel *shareFacebookLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareImageButton;

@end

@implementation HistoryDetailViewController

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
    
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    
    self.data = @[@"This is one long example of a caption that could be used",@"Buggy woggy its late right now",@"Wait a minute dont you hear me",@"She wanna have what you have",@"Yolo son!",@"Her ass cant handle it",@"Its alright, its Ok!"];
    
    if (!self.hideSelectButtons){
        self.hideSelectButtons = NO;
    }
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureFinalScreen
{
    self.finalContainerScreen = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.finalContainerScreen.contentMode = UIViewContentModeScaleAspectFill;
    self.finalContainerScreen.image = self.myImageView.image;
    self.finalContainerScreen.alpha = 0;
    [self.containerView addSubview:self.finalContainerScreen];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.finalContainerScreen.alpha = 1;
                          self.navigationController.navigationBarHidden = YES;
                     } completion:^(BOOL finished) {
                         [self.containerView addSubview:self.shareControls];
                         [self setupFinalLabel];
                         [self setupShareStyles];
                         [UIView animateWithDuration:1.0
                                          animations:^{
                                              self.finalCaptionLabel.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              [UIView animateWithDuration:1.0
                                                                    delay:0
                                                   usingSpringWithDamping:0.7
                                                    initialSpringVelocity:0
                                                                  options:0
                                                               animations:^{
                                                                   self.finalShareContainer.frame = CGRectMake(self.finalShareContainer.frame.origin.x, self.finalShareContainer.frame.origin.y - self.finalShareContainer.frame.size.height, self.finalShareContainer.frame.size.width , self.finalShareContainer.frame.size.height);
                                                                   self.shareContainerOnScreen = YES;
                                                               } completion:nil];

                                          }];
                        }];
 
}


- (void)setupFinalLabel
{
    //self.finalCaptionLabel.frame = CGRectMake(self.finalCaptionLabel.frame.origin.x, self.finalCaptionLabel.frame.origin.y, [UIScreen mainScreen].bounds.size.width, self.finalCaptionLabel.frame.size.height);
    self.finalCaptionLabel.text = self.selectedCaption;
    self.finalCaptionLabel.font = [UIFont fontWithName:@"Chalkduster" size:25];
    if ([self.finalCaptionLabel.text length] > 15){
        NSLog(@"hit");
        self.finalCaptionLabel.numberOfLines = 0;
        [self.finalCaptionLabel sizeToFit];
    }
    self.finalCaptionLabel.textAlignment = NSTextAlignmentCenter;
    self.finalCaptionLabel.userInteractionEnabled = YES;
    self.finalCaptionLabel.alpha = 0;
    if ([self.finalCaptionLabel isKindOfClass:[DraggableCaption class]]){
        ((DraggableCaption *) self.finalCaptionLabel).delegate = self;
    }
}

- (void)setupShareStyles
{
    self.finalShareContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.finalShareContainer.frame = CGRectMake(self.finalShareContainer.frame.origin.x, self.finalShareContainer.frame.origin.y + self.finalShareContainer.frame.size.height, self.finalShareContainer.frame.size.width , self.finalShareContainer.frame.size.height);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFacebookLabel:)];
    tap.numberOfTapsRequired = 1;
    
    self.shareFacebookLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:35];
    self.shareFacebookLabel.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-facebook-square"];
    self.shareFacebookLabel.textColor = [UIColor whiteColor];
    self.shareFacebookLabel.userInteractionEnabled = YES;
    [self.shareFacebookLabel addGestureRecognizer:tap];
    
    
    self.shareImageButton.backgroundColor = [[UIColor colorWithHexString:@"#2ecc71"] colorWithAlphaComponent:0.5f];
    self.shareImageButton.layer.cornerRadius = 10.0f;
    
}

- (void)captureFinalImage
{
    // hide controls
    
    self.finalImage = [self.view convertViewToImage];
    UIImageWriteToSavedPhotosAlbum(self.finalImage, nil, nil, nil);
    
}


- (IBAction)tappedShareButton:(UIButton *)sender {
    
    [self.containerView removeFromSuperview];
    self.containerView = nil;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)tappedFacebookLabel:(UITapGestureRecognizer *)sender {
    self.shareToFacebook = !self.shareToFacebook;
    if (self.shareToFacebook){

        self.shareFacebookLabel.textColor = [UIColor colorWithHexString:@"#3498db"];

    }
    else if (!self.shareToFacebook){
        self.shareFacebookLabel.textColor = [UIColor whiteColor];

    }
    
    
}



- (void)selectedCaption:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.myTable];
    NSIndexPath *indexPath = [self.myTable indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil){
        self.selectedCaption = [self.data objectAtIndex:indexPath.row];
    }

    UIAlertView *confirm = [[UIAlertView alloc]
                            initWithTitle:@"Confirm"
                            message:[NSString stringWithFormat:@"Are you sure you want this caption? '%@' ",[self.data objectAtIndex:indexPath.row]]
                            delegate:self
                            cancelButtonTitle:@"Not sure"
                            otherButtonTitles:@"I'm sure", nil];
    [confirm show];
    
}



#pragma -mark DraggableCaption delegate

- (void)CaptionStartedDragging{
    if (!self.shareContainerOnScreen){
        return;
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.finalShareContainer.frame = CGRectMake(self.finalShareContainer.frame.origin.x, self.finalShareContainer.frame.origin.y + self.finalShareContainer.frame.size.height, self.finalShareContainer.frame.size.width , self.finalShareContainer.frame.size.height);
                     }];
    self.shareContainerOnScreen = NO;
}

- (void)CaptionStoppedDragging
{
    [UIView animateWithDuration:1.0
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:0
                     animations:^{
                         self.finalShareContainer.frame = CGRectMake(self.finalShareContainer.frame.origin.x, self.finalShareContainer.frame.origin.y - self.finalShareContainer.frame.size.height, self.finalShareContainer.frame.size.width , self.finalShareContainer.frame.size.height);
                     } completion:nil];
    
    self.shareContainerOnScreen = YES;
    

}


#pragma -mark Uialertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        self.selectedCaption = nil;
    }
    
    else if (buttonIndex == 1){
        self.hideSelectButtons = YES;
        [self.myTable reloadData];
        [self configureFinalScreen];
    }
}

#pragma -mark Uitableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.hideSelectButtons){
        return @"Your Friends said";
    }
    else{
        return @"Choose a caption!";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"historyDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell isKindOfClass:[HistoryDetailCell class]]){
        UILabel *captionLabel = ((HistoryDetailCell *)cell).myCaptionLabel;
        UIButton *selectButton = ((HistoryDetailCell *)cell).mySelectButton;
        UILabel *dateLabel = ((HistoryDetailCell *)cell).myDateLabel;
        
        ((HistoryDetailCell *)cell).myImageVew.image = nil;
        FAImageView *imageView = ((FAImageView *)((HistoryDetailCell *)cell).myImageVew);
        [imageView setDefaultIconIdentifier:@"fa-user"];
        
        ((HistoryDetailCell *)cell).myCaptionLabel.text = [self.data objectAtIndex:indexPath.row];
    
        // set width and height so "sizeToFit" uses those constraints
      
        captionLabel.frame = CGRectMake(captionLabel.frame.origin.x, captionLabel.frame.origin.y,176 , 30);

        captionLabel.numberOfLines = 0;
        [captionLabel sizeToFit];
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
        dateLabel.text = [date timeAgo];
    
        
        
        [selectButton addTarget:self action:@selector(selectedCaption:) forControlEvents:UIControlEventTouchUpInside];
        if (self.hideSelectButtons){
            selectButton.hidden = YES;
        }
       
        /*
        [((HistoryDetailCell *)cell).mySelectButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:25]];
        [((HistoryDetailCell *)cell).mySelectButton.titleLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-thumbs-up"]];
        [((HistoryDetailCell *)cell).mySelectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
         */
        
        
    }
    return cell;
    
}


- (UIView *)containerView
{
    if (!_containerView){
        _containerView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_containerView];

    }

    return _containerView;
}

- (UIView *)shareControls
{
    if (!_shareControls){
        _shareControls = [[[NSBundle mainBundle] loadNibNamed:@"shareControls" owner:self options:nil]lastObject];
    }
    return _shareControls;
}





@end
