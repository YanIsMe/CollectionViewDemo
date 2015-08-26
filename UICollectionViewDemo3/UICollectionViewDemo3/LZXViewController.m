//
//  LZXViewController.m
//  UICollectionViewDemo3
//
//  Created by LZXuan on 15-1-15.
//  Copyright (c) 2015年 LZXuan. All rights reserved.
//

#import "LZXViewController.h"
#import "AFNetworking.h"
#import "UICollectionViewWaterfallLayout.h"
#import "AppCell.h"
#import "AppModel.h"
#import "UIImageView+WebCache.h"



#define URL @"http://madmin.caixin.com/api.php?m=api_article&a=getPhotoList&page_size=20&page_number=1"

@interface LZXViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateWaterfallLayout>
{
    UICollectionView *_collectionView;
    NSMutableArray *_dataArr;
}
@end

@implementation LZXViewController

- (void)creatView {
    //第三方的layout
    UICollectionViewWaterfallLayout *layout = [[UICollectionViewWaterfallLayout alloc] init];
    layout.itemWidth = 150;
    layout.delegate = self;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.view addSubview:_collectionView];
    
    //注册xib 的cell
    [_collectionView registerNib:[UINib nibWithNibName:@"AppCell" bundle:nil] forCellWithReuseIdentifier:@"AppCell"];
    _collectionView.backgroundColor = [UIColor grayColor];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self creatView];
    
    [self loadData];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)loadData {
    _dataArr = [[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //返回二进制
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray *arr = dict[@"rows"];
        
        for (NSDictionary *rowDict in arr) {
            AppModel *model = [[AppModel alloc] init];
            model.title = rowDict[@"title"];
            model.picture_url = rowDict[@"new_picture_url"];
            model.picture_heigth = rowDict[@"picture_heigth"];
            model.picture_width = rowDict[@"picture_width"];
            [_dataArr addObject:model];
        }
        //刷新表格
        [_collectionView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"下载失败");
    }];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArr.count;
}
//获取cell

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    AppCell *cell = (AppCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"AppCell" forIndexPath:indexPath];
    AppModel *model = _dataArr[indexPath.row];
    
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.picture_url]];
    cell.iconImageView.frame = CGRectMake(0, 0, 140, [model.picture_heigth doubleValue]*140/[model.picture_width doubleValue]);
    
    cell.titleLabel.frame = CGRectMake(0, [model.picture_heigth doubleValue]*140/[model.picture_width doubleValue], 140, 60);
    cell.titleLabel.text = model.title;
    
    
    return cell;

}
//选中 cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"选中");
}

//设置高度 UICollectionViewWaterfallLayout协议中的方法

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewWaterfallLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AppModel *model = _dataArr[indexPath.row];
    
    //140 /h = w/h
    
    //返回高度
    return [model.picture_heigth doubleValue]*140/[model.picture_width doubleValue]+60;
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
