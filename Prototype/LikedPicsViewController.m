//
//  LikedPicsViewController.m
//  Captify
//
//  Created by CJ Ogbuehi on 6/14/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "LikedPicsViewController.h"
#import "UIImageView+WebCache.h"
#import "FeedViewCell.h"
#import "UIColor+HexValue.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"


#define MY_IMAGE_TAG 2000

@interface LikedPicsViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *data;


@end

@implementation LikedPicsViewController

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
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-chevron-left"] style:UIBarButtonItemStylePlain target:self action:@selector(popToSettings)];
    [leftButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:25],
                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:CAPTIFY_ORANGE]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftButton;

    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.navigationItem.title = NSLocalizedString(@"Liked Photos", nil);
    
    self.view.backgroundColor = [UIColor colorWithHexString:CAPTIFY_DARK_GREY];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)popToSettings
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Uicollection delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //DLog(@"collection called");
    FeedViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"likedPicsCell" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor colorWithHexString:CAPTIFY_ORANGE];
    //cell.layer.borderWidth = 1.f;
    //cell.layer.borderColor = [[UIColor colorWithHexString:CAPTIFY_ORANGE] CGColor];
    //cell.layer.cornerRadius = 5.f;
    
    
    NSInteger count = [self.data count];
    if (indexPath.row < count){
        NSString *url = [self.data objectAtIndex:indexPath.row];
            [cell.myImageView setImageWithURL:[NSURL URLWithString:url]
                             placeholderImage:[UIImage imageNamed:CAPTIFY_CHALLENGE_PLACEHOLDER]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                        if (!image){
                                            DLog(@"%@",error);
                                        }
                                    }];

        
        
    }
    return cell;
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
    return CGSizeMake(150, 160);

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



- (NSArray *)data
{
    if (!_data){
        _data = [[NSUserDefaults standardUserDefaults] valueForKey:@"likedPics"];
    }
    
    return _data;
}

@end
