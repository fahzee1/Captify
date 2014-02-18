//
//  HistoryViewController.m
//  Prototype
//
//  Created by CJ Ogbuehi on 2/16/14.
//  Copyright (c) 2014 CJ Ogbuehi. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryCollectionCell.h"
#import "TWTSideMenuViewController.h"

@interface HistoryViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *myHistoryTable;
@property NSArray *list;

@end

@implementation HistoryViewController

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
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
    self.navigationItem.leftBarButtonItem = button;
    self.myHistoryTable.delegate = self;
    self.myHistoryTable.dataSource = self;
    self.list = [[NSArray alloc] initWithObjects:@"joe_bryant22",@"quiver_hut",@"dSanders21",@"theCantoon",@"darkness",@"fruity_cup",@"d_rose",@"splacca",@"on_fire",@"IAM", nil];

	// Do any additional setup after loading the view.
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



#pragma -mark Uicollection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.list count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"historyCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if ([cell isKindOfClass:[HistoryCollectionCell class]]){
        ((HistoryCollectionCell *)cell).myRecentPic.image = [UIImage imageNamed:@"profile-placeholder"];
    }
    
    // can also customize cell with cell.backgroundView = View
    // and cell.selectedBackgroundView = view
    
    return cell;
}
/*
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
}
 */

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.list objectAtIndex:indexPath.row]isEqualToString:@"joe_bryant22"]){
        return CGSizeMake(180.0, 180.0);
    }
    else{
        return CGSizeMake(100.0, 100.0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    // space between items in row
    
    return 10.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    //space betweem items in columns
    
    return 10.0f;
}


@end
