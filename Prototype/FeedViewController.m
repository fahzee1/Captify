//
//  FeedViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 5/8/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "FeedViewController.h"
#import "TWTSideMenuViewController.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "UIColor+HexValue.h"
#import "Challenge+Utils.h"
#import "FeedViewCell.h"
#import "UIImageView+WebCache.h"
#import "AwesomeAPICLient.h"
#import "MenuViewController.h"

@interface FeedViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TWTSideMenuViewControllerDelegate>

@property (strong,nonatomic)NSArray *results;
@property (strong,nonatomic)NSArray *data;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic)UIRefreshControl *refreshControl;
@property (strong,nonatomic)UIActivityIndicatorView *spinner;
@property BOOL fetched;
@property BOOL reloaded;
@end

@implementation FeedViewController

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
    [[AwesomeAPICLient sharedClient] startMonitoringConnection];
    self.sideMenuViewController.delegate = self;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FeedCell"];
    //[self.collectionView reloadData];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.collectionView.backgroundColor = [UIColor clearColor];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:CAPTIFY_LOGO]];
    logo.frame = CGRectMake(40, -60, 175, 175);
    logo.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView *titleContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    titleContainer.backgroundColor = [UIColor clearColor];
    [titleContainer addSubview:logo];
    self.navigationItem.titleView = titleContainer;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(updateFeed) forControlEvents:UIControlEventValueChanged];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.center = self.view.center;
    self.spinner.color = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    [self.collectionView addSubview:self.spinner];
    [self.collectionView bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
   

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
      DLog(@"received memory warning here");
}



- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

- (void)updateFeed
{
    self.fetched = NO;
    [self storeAndReturnResults];
}


- (void)storeAndReturnResults
{

    if (!self.fetched){
    [Challenge getCurrentChallengeFeedWithBlock:^(BOOL wasSuccessful, id data) {
        if (wasSuccessful){
            self.results = data[@"data"];
        
        }
        else{
            [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.refreshControl.isRefreshing){
                [self.refreshControl endRefreshing];
            }
            
        });
    }];

        self.fetched = YES;
    }
    
}

- (NSArray *)results
{
    if (!_results){
        _results = [NSArray array];
    }
    
    return _results;
}

- (NSArray *)data
{
    /*
    if (!_data){
        [Challenge getCurrentChallengeFeedWithBlock:^(BOOL wasSuccessful, id data) {
            if (wasSuccessful){
                _data = data[@"data"];
                [self.collectionView reloadData];
            }
            else{
                [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:data];
            }
        }];
    }
    
     */
    [self storeAndReturnResults];
    _data = self.results;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (!self.reloaded){
            [self.collectionView reloadData];
            self.reloaded = YES;
            if (self.spinner.isAnimating){
                [self.spinner stopAnimating];
            }

        }
    });
    return _data;
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    UIAlertView *a = [[UIAlertView alloc]
                      initWithTitle:title
                      message:message
                      delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil];
    [a show];
}


#pragma mark - Uicollection delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"collection called");
    FeedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    cell.layer.borderWidth = 1.f;
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_DARK_BLUE] CGColor];
    cell.layer.cornerRadius = 5.f;
    
    
    NSInteger count = [self.data count];
    if (indexPath.row < count){
        //DLog(@"row %ld is less then %ld so show",(long)indexPath.row,(long)count)
        NSString *jsonString = [self.data objectAtIndex:indexPath.row];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

        NSNumber *is_facebook = json[@"sender"][0][@"is_facebook"];
        if ([is_facebook intValue] == 1){
            
            NSString *fbID = json[@"sender"][0][@"facebook_id"];
            NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",fbID];
            NSURL * fbUrl = [NSURL URLWithString:fbString];
            [cell.senderPic setImageWithURL:fbUrl placeholderImage:[UIImage imageNamed:@"profile-placeholder"]];
            cell.senderPic.layer.masksToBounds = YES;
            cell.senderPic.layer.cornerRadius = 15.f;
        }
        else{
            cell.senderPic.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC];
        }
       
        // senderLabel and name are mismatched (to lazy to fix)
        
        cell.senderLabel.text = [json[@"name"] capitalizedString];
        cell.senderLabel.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:12];
        cell.senderLabel.textColor = [UIColor whiteColor];
        if ([cell.senderLabel.text length] >= 24){
            NSString *uString = [cell.senderLabel.text substringToIndex:23];
            cell.senderLabel.text = [NSString stringWithFormat:@"%@...",uString];
        }
        
        
        
        NSString *username = json[@"sender"][0][@"username"];
        cell.name.text = [[username stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
        cell.name.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:12];
        cell.name.textColor = [UIColor whiteColor];
        if ([cell.name.text length] >= 24){
            NSString *uString = [cell.name.text substringToIndex:23];
            cell.name.text = [NSString stringWithFormat:@"%@...",uString];
        }
        
        
        
        
        NSString *url = json[@"media_url"];
        [cell.myImageView setImageWithURL:[NSURL URLWithString:url]
                         placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    if (!image){
                                        DLog(@"%@",error);
                                    }
                                }];
        
    }
    else{
       // DLog(@"row %ld is greater then %ld so dont show",(long)indexPath.row,(long)count)

        cell.myImageView.image = nil;
        cell.senderPic.image = nil;
        cell.senderLabel.text = nil;
        cell.name.text = nil;
        
    }
    
    //cell.name.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // add 35 to height and with to give each picture a border
    /*
    if (indexPath.row == 0){
        return CGSizeMake(200, 200);
    }
    else if (indexPath.row == 9){
        return CGSizeMake(200, 200);
    }
    
    else{
       return CGSizeMake(150, 150);
    }
     */
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[FeedViewCell class]]){
        CGSize size = ((FeedViewCell *)cell).myImageView.frame.size;
        size.height -= 50;
        size.width -= 50;
        return size;
    }
    else{
        return CGSizeMake(150, 160);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 7.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 5 , 20, 5);
}

/*- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [[UICollectionReusableView alloc] init];
}*/

- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    UIViewController *menu = self.sideMenuViewController.menuViewController;
    if ([menu isKindOfClass:[MenuViewController class]]){
        [((MenuViewController *)menu) setupColors];
    }
}



@end
