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

@interface FeedViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong,nonatomic)NSArray *data;
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

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
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:CAPTIFY_CONTACT_PIC]];
    logo.frame = CGRectMake(0, 0, 80, 80);
    self.navigationItem.titleView = logo;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)showMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}


- (NSArray *)data
{
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
    FeedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    
    NSInteger count = [self.data count];
    if (indexPath.row < count){
        NSString *jsonString = [self.data objectAtIndex:indexPath.row];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

        cell.sender = json[@"name"];
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
        cell.myImageView.image = [UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER];
        
    }
    
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
    return CGSizeMake(150, 150);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 0 , 20, 0);
}

/*- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [[UICollectionReusableView alloc] init];
}*/


@end
