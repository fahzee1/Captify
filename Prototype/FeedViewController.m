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
#import "TMCache.h"
#import "FeedDetailViewController.h"
#import "UIViewController+TargetViewController.h"
#import "MZFormSheetController.h"
#import "AppDelegate.h"


#define FEED_CACHE_NAME @"feedCache"

@interface FeedViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TWTSideMenuViewControllerDelegate>

@property (strong,nonatomic)NSArray *results;
@property (strong,nonatomic)NSArray *data;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic)UIRefreshControl *refreshControl;
@property (strong,nonatomic)UIActivityIndicatorView *spinner;
@property BOOL fetched;
@property BOOL refreshedImages;
@property BOOL alertedError;
@property BOOL reloaded;
@property BOOL addedLatestJson;
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
    
    //[AppDelegate clearImageCaches];
    
    self.sideMenuViewController.delegate = self;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FeedCell"];
    //[self.collectionView reloadData];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(updateFeed)];
    [rightButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];

    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;
    
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
    self.spinner.color = [UIColor colorWithHexString:CAPTIFY_DARK_BLUE];
    [self.collectionView addSubview:self.spinner];
    [self.collectionView bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
   
    
   
}


- (void)viewWillAppear:(BOOL)animated
{
    if (USE_GOOGLE_ANALYTICS){
        self.screenName = @"Explore page";
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
      DLog(@"received memory warning here");
    
    self.results = nil;
    self.data = nil;
    [self.collectionView reloadData];
    
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
        double delayInSeconds = 10.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([self.refreshControl isRefreshing]){
                [self.refreshControl endRefreshing];
            }
        });

    [Challenge getCurrentChallengeFeedWithBlock:^(BOOL wasSuccessful, id data) {
        if (wasSuccessful){
            self.results = data[@"data"];
            if ([self.results count] > 0){
                [[TMCache sharedCache] removeObjectForKey:FEED_CACHE_NAME];
                [[TMCache sharedCache] setObject:self.results forKey:FEED_CACHE_NAME];
            }
        
        }
        else{
            [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.refreshControl.isRefreshing){
                [self.refreshControl endRefreshing];
                [self.collectionView reloadData];
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
    if ([self.results count] > 0){
        _data = self.results;
    }
    else{
        NSArray *results = [[TMCache sharedCache] objectForKey:FEED_CACHE_NAME];
        if ([results count] > 0){
              _data = results;
        }
    }
    
    if (!self.addedLatestJson){
        if (self.lastestJson){
            NSMutableArray *mutableResults = [NSMutableArray array];
            [mutableResults addObject:self.lastestJson];
            [mutableResults addObjectsFromArray:_data];
            
            NSArray *finalResults = [NSArray arrayWithArray:mutableResults];
            _data = finalResults;
            
            [[TMCache sharedCache] removeObjectForKey:FEED_CACHE_NAME];
            [[TMCache sharedCache] setObject:_data forKey:FEED_CACHE_NAME];
            self.addedLatestJson = YES;
        }
    }
    if (!self.refreshedImages){
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
            
            /*
            // need to do a refresh to get updated image with caption
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [AppDelegate clearImageCaches];
                [self.collectionView reloadData];
                DLog(@"reload");
        
            });
             */

        });
        
        self.refreshedImages = YES;
    }
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
    
    if (self.lastestJson || [self.data count] == 21){
        return 21;
    }
    
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"collection called");
    FeedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    cell.layer.borderWidth = 1.f;
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.cornerRadius = 5.f;
    
    
    
    
    
    NSInteger count = [self.data count];
    if (indexPath.row < count){
        //DLog(@"row %ld is less then %ld so show",(long)indexPath.row,(long)count)
        
        
        NSString *jsonString = [self.data objectAtIndex:indexPath.row];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

    
        cell.name.text = [json[@"name"] capitalizedString];
        cell.name.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:12];
        cell.name.textColor = [UIColor whiteColor];
        if ([cell.name.text length] >= TITLE_LIMIT - 5){
            NSString *uString = [cell.name.text substringToIndex:TITLE_LIMIT - 6];
            cell.name.text = [NSString stringWithFormat:@"%@...",uString];
            //DLog(@"%@ is to long at count %lu",cell.name.text,(unsigned long)[cell.name.text length]);
        }
        
        
       
        if (indexPath.row == 0 && self.latestImage){
            cell.myImageView.image = self.latestImage;
        }
        else{
            NSString *url = json[@"media_url"];
            [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:url]
                                placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                         options:SDWebImageRefreshCached
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           if (!image){
                                               DLog(@"%@",error);
                                           }

                                       }];
            
            
        }
        
        
        
        
    }
    else{
       // DLog(@"row %ld is greater then %ld so dont show",(long)indexPath.row,(long)count)

        cell.myImageView.image = nil;
        cell.name.text = nil;
        
    }
    
    //cell.name.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger count = [self.data count];
    if (indexPath.row < count){
        NSString *jsonString = [self.data objectAtIndex:indexPath.row];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        
        NSString *url = json[@"media_url"];
        NSString *name = json[@"name"];
        NSString *username = json[@"sender"][0][@"username"];
        NSNumber *is_facebook = json[@"sender"][0][@"is_facebook"];
        NSString *challenge_id = json[@"id"];
        NSString *score;
        NSString *winnerUsername;
        NSNumber *likes;

        @try {
            winnerUsername = json[@"winner"];
        }
        @catch (NSException *exception) {
            winnerUsername = @"";
        }
        
        @try {
            score = json[@"sender"][0][@"score"];
        }
        @catch (NSException *exception) {
            score = @"0";
        }
        
        @try {
            likes = json[@"likes"];
        }
        @catch (NSException *exception) {
            likes = @0;
        }
        
        NSURL *fbURL;
        if ([is_facebook intValue] == 1){
            
            NSString *fbID = json[@"sender"][0][@"facebook_id"];
            NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",fbID];
            fbURL = [NSURL URLWithString:fbString];
        }
        

        
        UIViewController *detailRoot = [self.storyboard instantiateViewControllerWithIdentifier:@"feedDetailRoot"];
        if ([detailRoot isKindOfClass:[UINavigationController class]]){
            UIViewController *detailVC = ((UINavigationController *)detailRoot).topViewController;
            if ([detailVC isKindOfClass:[FeedDetailViewController class]]){
                
                ((FeedDetailViewController *)detailVC).urlString = url;
                ((FeedDetailViewController *)detailVC).facebookUser = is_facebook;
                ((FeedDetailViewController *)detailVC).profileUsername = username;
                ((FeedDetailViewController *)detailVC).showTopLabel = YES;
                ((FeedDetailViewController *)detailVC).winnerUsername = winnerUsername;
                ((FeedDetailViewController *)detailVC).name = name;
                ((FeedDetailViewController *)detailVC).likes = likes;
                ((FeedDetailViewController *)detailVC).challenge_id = challenge_id;
                if (indexPath.row == 0 && self.latestImage){
                    ((FeedDetailViewController *)detailVC).image = self.latestImage;
                }

                if ([score isKindOfClass:[NSNumber class]]){
                    ((FeedDetailViewController *)detailVC).profileScore = [NSString stringWithFormat:@"%@",(NSNumber *)score];
                }
                else{
                    ((FeedDetailViewController *)detailVC).profileScore = score;
                }
              
                if ([is_facebook intValue] == 1 && fbURL){
                    ((FeedDetailViewController *)detailVC).facebookPicURL = fbURL;
                }
                
                
            }
        }
        
        MZFormSheetController *formSheet;
        if (!IS_IPHONE5){
            formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 400) viewController:detailRoot];
            CGPoint point = formSheet.formSheetWindow.frame.origin;
            point.y -= 35;
            formSheet.formSheetWindow.frame = CGRectMake(point.x, point.y, formSheet.formSheetWindow.frame.size.width, formSheet.formSheetWindow.frame.size.height);
        }
        else{
            formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 410) viewController:detailRoot];
            //formSheet = [[MZFormSheetController alloc] initWithSize:self.view.frame.size viewController:detailRoot];
        }
        
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
        
        [[MZFormSheetController sharedBackgroundWindow] setBackgroundBlurEffect:YES];
        [[MZFormSheetController sharedBackgroundWindow] setBlurRadius:5.0];
        [[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor clearColor]];
        
        [formSheet presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            //
        }];

        
        
        

    }

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

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message

{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *a = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
        [a show];
        
    });
}



@end
