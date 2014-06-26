//
//  UserProfileViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 5/27/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexValue.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "User+Utils.h"
#import "FeedViewCell.h"
#import "FeedDetailViewController.h"
#import "AppDelegate.h"



@interface UserProfileViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic)NSArray *sentMedia;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic)UIActivityIndicatorView *spinner;

@end

@implementation UserProfileViewController

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
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    // animate its display
    self.collectionView.hidden = YES;
    self.collectionView.alpha = 0;

    
    self.myUsername.text = @"";
    self.myScore.text = @"";
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.navigationItem.title = NSLocalizedString(@"Profile", nil);
    //self.navigationController.navigationBarHidden = NO;
    
    
    UIBarButtonItem *leftButton;
    if (!self.showCloseButton){
        leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popScreen)];

    }
    else{
        leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] style:UIBarButtonItemStylePlain target:self action:@selector(destroyScreen)];

    }
    
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                          NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];

    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    self.navigationController.navigationBarHidden = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.fromExplorePage){
        CGRect imageFrame = self.myProfileImage.frame;
        CGRect usernameFrame = self.myUsername.frame;
        CGRect scoreFrame = self.myScore.frame;
        
        imageFrame.origin.x -= 17;
        usernameFrame.origin.x -= 17;
        scoreFrame.origin.x -= 17;
        
        self.myProfileImage.frame = imageFrame;
        self.myUsername.frame = usernameFrame;
        self.myScore.frame = scoreFrame;
        
        
    }
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.center = self.scrollView.center;
    CGRect spinnerFrame = self.spinner.frame;
    spinnerFrame.origin.y -= 100;
    self.spinner.frame = spinnerFrame;
    self.spinner.color = [UIColor colorWithHexString:CAPTIFY_DARK_BLUE];
    [self.scrollView addSubview:self.spinner];
    [self.scrollView bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];

    
    [self fetchProfile];

    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:1
                     animations:^{
                         self.view.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
                     }];

}

- (void)viewDidDisappear:(BOOL)animated
{
     [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sentMedia"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    DLog(@"received memory warning");
    
    [AppDelegate clearImageCaches];
    self.sentMedia = nil;
    

}


- (void)adjustTableSize
{
    if ([self.sentMedia count] > 0){
        int height;
        int cushion = 77;
        if ([self.sentMedia count] < 3){
            cushion = 95;
        }
        else if (!IS_IPHONE5){
            cushion = 110;
        }
        if (!self.fromExplorePage){
            height = cushion * (int)[self.sentMedia count]; //cell height times amount of cells to add to scrollview
        }
        else{
            height = cushion * (int)[self.sentMedia count]; //cell height times amount of cells to add to scrollview
        }
        int scrollHeight = [UIScreen mainScreen].bounds.size.height + height;
        self.scrollView.contentSize = CGSizeMake(320, scrollHeight);
        CGRect tableRect = self.collectionView.frame;
        tableRect.size.height += height;
        self.collectionView.frame = tableRect;
    }
    else{
        self.scrollView.contentSize = CGSizeMake(320, 670);
    }

}

- (void)fetchProfile
{
    if (self.usernameString){
    [User fetchUserProfileWithData:@{@"username": [self.usernameString stringByReplacingOccurrencesOfString:@" " withString:@"-"],
                                     @"forProfile":[NSNumber numberWithBool:YES]}
                             block:^(BOOL wasSuccessful, NSNumber *json, id data) {
                                 //DLog(@"%@",data);
                                 if (wasSuccessful){
                                     DLog(@"%@",data);
                                     
                                     if ([json intValue] == 1){
                                         DLog(@"parse for json");
                                         // get user data
                                         id userString = data[@"user_data"];
                                         NSData *userData = [userString dataUsingEncoding:NSUTF8StringEncoding];
                                         NSDictionary *userJson = [NSJSONSerialization JSONObjectWithData:userData options:0 error:nil];
                                         
                                
                                        // get users sent pics
                                         NSArray *challengeList = data[@"challenge_data"];
                                         NSMutableArray *challengeTemp = [NSMutableArray array];
                                         for (NSString *challenge in challengeList){
                                             NSData *challengeData = [challenge dataUsingEncoding:NSUTF8StringEncoding];
                                             NSDictionary *challengeDict = [NSJSONSerialization JSONObjectWithData:challengeData options:0 error:nil];
                                             NSString *media = challengeDict[@"media_url"];
                                             NSString *name = challengeDict[@"name"];
                                             if (media && ![media isKindOfClass:[NSNull class]]){
                                                 if (name && ![name isKindOfClass:[NSNull class]]){
                                                     [challengeTemp addObject:@{@"media_url": media,@"name":name}];
                                                 }
                                             }
                                         }
                                         
                                         self.sentMedia = challengeTemp;
                                         
                                             
                                         //[[NSUserDefaults standardUserDefaults] setObject:challengeTemp forKey:@"sentMedia"];
                                         // reload table
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             NSString *username = userJson[@"username"];
                                             NSString *score = userJson[@"score"];
                                             NSString *facebook_id = userJson[@"facebook_id"];
                                             NSNumber *facebook_user = userJson[@"facebook_user"];
                                             

                                             
                                             self.scoreString = score;
                                             self.facebook_user = facebook_user;
                                             
                                             
                                             if ([facebook_user intValue] == 1){
                                                 username = [[username stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
                                                 
                                                 NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",facebook_id];
                                                 NSURL *fbURL = [NSURL URLWithString:fbString];
                                                 
                                                 self.profileURLString = fbURL;
                                                 
                                             }
                                             else{
                                                 username = [username capitalizedString];
                                             }
                                             self.usernameString = username;
                                             
                                             [self.spinner stopAnimating];
                                             
                                             if (self.delaySetupWithTime){
                                                 double delayInSeconds = self.delaySetupWithTime;
                                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                     [self setupScreen];
                                                 });
                                             }
                                             else{
                                                 [self setupScreen];
                                             }
                                             
                                             [self.collectionView reloadData];
                                             [self adjustTableSize];
                                             

                                         });
                                         
                                         
                                     }
                                     
                                     else{
                                         DLog(@"parse for non json");
                                
                                         dispatch_async(dispatch_get_main_queue(), ^{

                                             NSString *username = data[@"username"];
                                             NSString *score = data[@"score"];
                                             NSString *facebook_id = data[@"facebook_id"];
                                             NSNumber *facebook_user = data[@"facebook_user"];
                                             
                                             self.scoreString = score;
                                             self.facebook_user = facebook_user;

                                             if ([facebook_user intValue] == 1){
                                                 username = [[username stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
                                                 
                                                 NSString *fbString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",facebook_id];
                                                 NSURL *fbURL = [NSURL URLWithString:fbString];
                                                 
                                                 self.profileURLString = fbURL;
                                                 
                                             }
                                             else{
                                                 username = [username capitalizedString];
                                             }
                                             self.usernameString = username;

                                             
                                            [self.spinner stopAnimating];
                                             
                                             if (self.delaySetupWithTime){
                                                 double delayInSeconds = self.delaySetupWithTime;
                                                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                     [self setupScreen];
                                                 });
                                             }
                                             else{
                                                 [self setupScreen];
                                             }
                                             

                                             [self.collectionView reloadData];
                                             [self adjustTableSize];
                                             

                                             
                                         });
                                         
                                         
                                    }
                                 }
                             }];
    }
    else{
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Error fetching users profile.", nil)];
    }
}

- (void)popScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)destroyScreen
{
    [self.controller dismissAnimated:YES completionHandler:nil];
}

- (void)setupScreen
{
    if ([self.facebook_user intValue] == 1){
        [self.myProfileImage sd_setImageWithURL:self.profileURLString
                               placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          if (!image){
                                              DLog(@"%@",error);
                                          }

                                      }];
    }
    else{
        self.myProfileImage.image = [UIImage imageNamed:CAPTIFY_CONTACT_PIC_BIG];
    }
    
    self.myProfileImage.layer.masksToBounds = YES;
    self.myProfileImage.layer.cornerRadius = self.myProfileImage.frame.size.height/2;

    // move image up to bring down
    CGRect imageOriginal = self.myProfileImage.frame;
    CGRect newImageFrame = imageOriginal;
    newImageFrame.origin.y -= 200;
    self.myProfileImage.frame = newImageFrame;
    
    // move username down to bring up
    CGRect usernameOriginal = self.myUsername.frame;
    CGRect newUsernameFrame = usernameOriginal;
    newUsernameFrame.origin.y += 300;
    self.myUsername.frame = newUsernameFrame;
    
    // move score down to bring up
    CGRect scoreOriginal = self.myScore.frame;
    CGRect newScoreFrame = scoreOriginal;
    newScoreFrame.origin.y += 300;
    self.myScore.frame = newScoreFrame;
    
    
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:0
                     animations:^{
                         self.myProfileImage.frame = imageOriginal;
                     } completion:^(BOOL finished) {
                         // move up username
                         [UIView animateWithDuration:.5
                                               delay:0
                              usingSpringWithDamping:0.7
                               initialSpringVelocity:0.4
                                             options:0
                                          animations:^{
                                              self.myUsername.frame = usernameOriginal;
                                          } completion:^(BOOL finished) {
                                              // move up score
                                              [UIView animateWithDuration:.5
                                                                    delay:0
                                                   usingSpringWithDamping:0.7
                                                    initialSpringVelocity:0.4
                                                                  options:0
                                                               animations:^{
                                                                   self.myScore.frame = scoreOriginal;
                                                               } completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:1
                                                                                    animations:^{
                                                                                        self.collectionView.hidden = NO;
                                                                                        self.collectionView.alpha = 1;
                                                                                    }];
                                                               }];
                                          }];
                         
                     }];
    
    
    self.myScore.text = self.scoreString;
    self.myUsername.text = [[self.usernameString stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    self.myScore.textColor = [UIColor whiteColor];
    self.myScore.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:18];
    self.myUsername.textColor = [UIColor whiteColor];
    self.myUsername.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:18];
    
    

}


- (NSArray *)sentMedia
{
    if (!_sentMedia){
        _sentMedia = [NSArray array];
    }
    return _sentMedia;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.sentMedia count];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"collection called");
    FeedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileMediaCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_LIGHT_GREY];
    cell.layer.borderWidth = 1.f;
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_LIGHT_GREY] CGColor];
    cell.layer.cornerRadius = 5.f;
    
    
    NSInteger count = [self.sentMedia count];
    if (indexPath.row < count){
        //DLog(@"row %ld is less then %ld so show",(long)indexPath.row,(long)count)
        NSDictionary *challengeDict = [self.sentMedia objectAtIndex:indexPath.row];
        NSString *media_url = challengeDict[@"media_url"];
        NSString *name = challengeDict[@"name"];
        

        cell.name.text = [name capitalizedString];
        cell.name.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:11];
        cell.name.textColor = [UIColor whiteColor];
        if ([cell.name.text length] >= 25){
            NSString *uString = [cell.name.text substringToIndex:24];
            cell.name.text = [NSString stringWithFormat:@"%@...",uString];
            
            //DLog(@"%@ is to long at count %lu",cell.name.text,(unsigned long)[cell.name.text length]);
        }
        
        if (self.fromExplorePage){
            // reposition name label cause cell is smaller
            CGRect nameFrame = cell.name.frame;
            nameFrame.origin.y += 7;
            nameFrame.origin.x += 7;
            cell.name.frame = nameFrame;
        }
        

        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:media_url]
                            placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                     options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       if (!image){
                                           DLog(@"%@",error);
                                       }

                                   }];
          
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
    
    

    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell){
        if (((FeedViewCell *)cell).myImageView.image){
            UIViewController *detailRoot = [self.storyboard instantiateViewControllerWithIdentifier:@"feedDetailRoot"];
            
            if ([detailRoot isKindOfClass:[UINavigationController class]]){
                UIViewController *detailVC = ((UINavigationController *)detailRoot).topViewController;
                if ([detailVC isKindOfClass:[FeedDetailViewController class]]){
                    //NSURL *mediaUrl = ((FeedViewCell *)cell).myImageView.imageURL;
                    ((FeedDetailViewController *)detailVC).showTopLabel = NO;
                    //((FeedDetailViewController *)detailVC).urlString = [mediaUrl absoluteString];
                    ((FeedDetailViewController *)detailVC).image = ((FeedViewCell *)cell).myImageView.image;
                    [self.navigationController pushViewController:detailVC animated:YES];
                    return;
                    
                }
            }
            
        }
    }
     
    
    

    
    NSInteger count = [self.sentMedia count];
    if (indexPath.row < count){
        NSDictionary *challengeDict = [self.sentMedia objectAtIndex:indexPath.row];
        NSString *media_url  = challengeDict[@"media_url"];
        
        UIViewController *detailRoot = [self.storyboard instantiateViewControllerWithIdentifier:@"feedDetailRoot"];
        
        if ([detailRoot isKindOfClass:[UINavigationController class]]){
            UIViewController *detailVC = ((UINavigationController *)detailRoot).topViewController;
            if ([detailVC isKindOfClass:[FeedDetailViewController class]]){
                
                ((FeedDetailViewController *)detailVC).urlString = media_url;
                ((FeedDetailViewController *)detailVC).showTopLabel = NO;
                [self.navigationController pushViewController:detailVC animated:YES];
                
                
            }
        }
        
        
    }
    else{
        
        [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Can't show photo due to low memory. Try stopping other apps running in the background.", nil)];
    }
    
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
    if (!self.fromExplorePage){
        return CGSizeMake(140, 150);
    }
    else{
        return CGSizeMake(120, 130);
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (!self.fromExplorePage){
        return 1.0;
    }
    else{
        return 2;
    }

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  
    return 7.0;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (!self.fromExplorePage) {
        return UIEdgeInsetsMake(20, 5 , 20, 5); //top,left,bottom/right
    }
    else{
        return UIEdgeInsetsMake(0, 0 , 0, 45);
    }
    
    
    
}

- (void)showAlertWithTitle:(NSString *)title
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
