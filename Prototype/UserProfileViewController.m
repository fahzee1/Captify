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



@interface UserProfileViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic)NSArray *sentMedia;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
    
    self.myUsername.text = @"";
    self.myScore.text = @"";
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
    self.navigationItem.title = NSLocalizedString(@"Profile", nil);
    //self.navigationController.navigationBarHidden = NO;
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popScreen)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    self.navigationController.navigationBarHidden = NO;

    
    [self fetchProfile];

    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
     self.view.backgroundColor = [[UIColor colorWithHexString:CAPTIFY_DARK_GREY] colorWithAlphaComponent:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fetchProfile
{
    [User fetchUserProfileWithData:@{@"username": [self.usernameString stringByReplacingOccurrencesOfString:@" " withString:@"-"] }
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
                                             if (media && ![media isKindOfClass:[NSNull class]]){
                                                 [challengeTemp addObject:media];
                                             }
                                         }
                                         
                                         self.sentMedia = challengeTemp; // reload table
                                         
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
                                             

                                             
                                             
                                         });
                                         
                                         
                                    }
                                 }
                             }];
}

- (void)popScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupScreen
{
    if ([self.facebook_user intValue] == 1){
        [self.myProfileImage setImageWithURL:self.profileURLString
                            placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
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
                                                               } completion:nil];
                                          }];
                         
                     }];
    
    
    self.myScore.text = self.scoreString;
    self.myUsername.text = [[self.usernameString stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    self.myScore.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    self.myScore.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL size:18];
    self.myUsername.textColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
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
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    cell.layer.borderWidth = 1.f;
    cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    cell.layer.cornerRadius = 5.f;
    
    
    NSInteger count = [self.sentMedia count];
    if (indexPath.row < count){
        //DLog(@"row %ld is less then %ld so show",(long)indexPath.row,(long)count)
        NSString *media_url = [self.sentMedia objectAtIndex:indexPath.row];
        
        /*
        cell.name.text = [json[@"name"] capitalizedString];
        cell.name.font = [UIFont fontWithName:CAPTIFY_FONT_GLOBAL_BOLD size:12];
        cell.name.textColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
        if ([cell.name.text length] >= 35){
            NSString *uString = [cell.name.text substringToIndex:34];
            cell.name.text = [NSString stringWithFormat:@"%@...",uString];
            
            //DLog(@"%@ is to long at count %lu",cell.name.text,(unsigned long)[cell.name.text length]);
        }
         */
        

        [cell.myImageView setImageWithURL:[NSURL URLWithString:media_url]
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
        cell.name.text = nil;
        
    }
    
    //cell.name.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger count = [self.sentMedia count];
    if (indexPath.row < count){
        NSString *media_url = [self.sentMedia objectAtIndex:indexPath.row];
        
        
        UIViewController *detailRoot = [self.storyboard instantiateViewControllerWithIdentifier:@"feedDetailRoot"];
        
        // show full screen
        
        /*
        MZFormSheetController *formSheet;
        if (!IS_IPHONE5){
            formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 380) viewController:detailRoot];
        }
        else{
            formSheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 400) viewController:detailRoot];
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
        
        
        */
        
        
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


@end
