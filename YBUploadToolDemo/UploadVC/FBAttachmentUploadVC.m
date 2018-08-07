//
//  FBAttachmentUploadVC.m
//  FengbangB
//
//  Created by fengbang on 2018/6/28.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "FBAttachmentUploadVC.h"
#import "UIViewController+YBNaviAttributes.h"
#import "UIViewController+BackButtonHandler.h"
#import "FBAttachmentUploadCollectionViewCell.h"
#import "SelectPhotoManager.h"
#import "Header.h"
#import "FBProgressHUD.h"


@interface FBAttachmentUploadVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,FBAttachmentUploadCollectionViewCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray *dataArray;
/**图片选择工具*/
@property (nonatomic, strong) SelectPhotoManager *photoManager;
@property (nonatomic, assign,getter=isUploading) BOOL uploading;
@end


/**最大附件图片个数*/
NSInteger kAttachmentPhotoMaxNumber = 1;
/**每行显示的个数*/
static CGFloat kPerLineNumber = 3;
/**cell的identifier*/
static NSString *kAttachmentUploadCellIdentifier = @"kAttachmentUploadCellIdentifier";
#define SECTION_LEFT_MARGIN 30
#define ITEM_SPACE 10

@implementation FBAttachmentUploadVC {
}

#pragma mark - lazy
- (UICollectionView *)collectionView
{
    if (_collectionView) {
        return _collectionView;
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = ITEM_SPACE;
    layout.minimumInteritemSpacing = ITEM_SPACE/2;
    layout.sectionInset = UIEdgeInsetsMake(20, SECTION_LEFT_MARGIN, 20, SECTION_LEFT_MARGIN);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.alwaysBounceVertical = YES;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollEnabled = YES;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    [collectionView registerClass:[FBAttachmentUploadCollectionViewCell class] forCellWithReuseIdentifier:kAttachmentUploadCellIdentifier];
    
    return _collectionView;
}

/**
 选择照片的工具类

 @return 工具类
 */
- (SelectPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [[SelectPhotoManager alloc] init];
        _photoManager.currentVC = self;
    }
    return _photoManager;
}

#pragma mark - overwrite
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNavigation];
    
    [self configData];

}

- (void)dealloc {
    NSLog(@"%@销毁了",[self class]);
}

#pragma mark - private

/**
 设置导航栏
 */
- (void)configNavigation {
    
    [self yb_setTitleAttributesWithTitle:@"附件上传" font:KV_FONT(16.) color:[UIColor colorWithHexString:@"575757"]];
    
    [self yb_setRightBarButtonItemWithTitle:@"确定" font:KV_FONT(16) color:APP_MAIN_COLOR action:@selector(confirmButtonClick:)];
}

/**
 重写此方法，拦截导航栏返回按钮的点击相应方法

 @return bool值
 */
- (BOOL)navigationShouldPopOnBackButton {
    return YES;
}

/**
 右上角确认按钮点击方法

 @param sender sender description
 */
- (void)confirmButtonClick:(UIButton *)sender {
    
}

/**
 配置数据
 */
- (void)configData {
    //拿到参数
    kAttachmentPhotoMaxNumber = 6;
    
    self.collectionView.hidden = NO;

    
    
    //测试数据
    NSMutableArray *mutArr = [NSMutableArray array];
    for (int i = 0; i<3; i++) {
        FBAttachmentCellStyleModel *model = [[FBAttachmentCellStyleModel alloc] init];
        model.image = [UIImage imageNamed:@"timg"];
        [mutArr addObject:model];
    }
    self.dataArray = mutArr.copy;
    [self.collectionView reloadData];
    
    if (self.status == 0) {
        [self asyncConcurrentGroupUpload];
    }else if (self.status == 1) {
        [self asyncSerialUpload];
    }else {
        self.dataArray = nil;
        [self.collectionView reloadData];
    }
    
}

/**
 选择添加照片
 */
- (void)addPicture {
    @weakify(self);
    [self.photoManager startSelectPhotoSuccess:^(SelectPhotoManager *manager, UIImage *image) {
        @strongify(self);
        if (!image) { return ; }
        
        FBAttachmentCellStyleModel *model = [[FBAttachmentCellStyleModel alloc]init];
        model.image = image;
        NSMutableArray *mutArray = [NSMutableArray arrayWithArray:self.dataArray];
        [mutArray insertObject:model atIndex:0];
        self.dataArray = [mutArray copy];
        //FBLog(@"_____________增加了图片_______________");
        [self.collectionView reloadData];
        
        //上传图片
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self asyncConcurrentConstUpload];
        });
        
    } failure:^(NSString *errorReason) {
        @strongify(self);
        NSLog(@"%@",errorReason);
    }];
}

#pragma mark - 上传图片的几种方式
/**
 上传图片-用dispatch_group监控所有上传完成动作-缺点是不能实时往group里添加任务
 */
- (void)asyncConcurrentGroupUpload {
    self.uploading = YES;
    [FBUploadTool asyncConcurrentGroupUploadArray:self.dataArray uploading:^{
        [FBProgressHUD showIndicatorToView:self.view];
    } completion:^(id obj) {
        [FBProgressHUD hiddenIndicatorFromView];
        NSLog(@"异步并行(dispatch_group)-所有的任务都完成了...");
        self.uploading = NO;
    }];
}

/**
 上传图片-用常量监控所有上传是否完成
 */
- (void)asyncConcurrentConstUpload {
    
    self.uploading = YES;
    [FBProgressHUD showIndicatorToView:self.view];
    [FBUploadTool asyncConcurrentConstUploadArray:self.dataArray uploading:nil completion:^(id obj) {
        [FBProgressHUD hiddenIndicatorFromView];
        self.uploading = NO;
        NSLog(@"异步并行(常量)-所有的任务都完成了...");
    }];
}

- (void)asyncSerialUpload {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (FBAttachmentCellStyleModel *model in self.dataArray) {
            if (model.imgUrl.length>0) {
                model.uploadStatus = YBAttachmentUploadStatusEnd;
            }
        }
        [FBAttachmentCellStyleModel asyncSerialUploadArray:self.dataArray progress:^(CGFloat p, NSInteger index) {
            self.uploading = YES;
            NSLog(@"%.4f",p);
        } completion:^(id obj) {
            NSLog(@"数量：%@",obj);
            self.uploading = NO;
            NSLog(@"异步串行-所有的任务都完成了...");
        }];
    });
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return (self.dataArray.count==kAttachmentPhotoMaxNumber)?self.dataArray.count:self.dataArray.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBAttachmentUploadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAttachmentUploadCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(FBAttachmentUploadCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (kArrayIsEmpty(self.dataArray)) {
        [cell configCellAdd];
    }else if (self.dataArray.count == kAttachmentPhotoMaxNumber) {
        FBAttachmentCellStyleModel *model = self.dataArray[indexPath.row];
        model.index = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [cell configCellWithData:model];
    }else {
        if (indexPath.row == 0) {
            [cell configCellAdd];
        }else {
            FBAttachmentCellStyleModel *model = self.dataArray[indexPath.row - 1];
            model.index = [NSString stringWithFormat:@"%ld",indexPath.row-1];
            [cell configCellWithData:model];
        }
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FBAttachmentUploadCollectionViewCell *cell = (FBAttachmentUploadCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.isUploading && self.status!=2) {
        NSLog(@"上传中，不要选图片...");
        return;
    }
    
    if (kArrayIsEmpty(self.dataArray)) {
        //添加图片
        [self addPicture];
    }else if (self.dataArray.count == kAttachmentPhotoMaxNumber) {
        //查看大图
    }else {
        if (indexPath.row == 0) {
           //添加图片
            [self addPicture];
        }else {
            //查看大图
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = (FULL_SCREEN_WIDTH - SECTION_LEFT_MARGIN*2 - (kPerLineNumber-1)*ITEM_SPACE)/kPerLineNumber;
    return CGSizeMake(w, w);
}

#pragma mark - FBAttachmentUploadCollectionViewCellDelegate
- (void)configCellDelete:(FBAttachmentUploadCollectionViewCell *)cell withOject:(id)object
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSMutableArray *mutArray = [NSMutableArray arrayWithArray:self.dataArray];
    if (self.dataArray.count == kAttachmentPhotoMaxNumber) {
        [mutArray removeObjectAtIndex:indexPath.row];
        self.dataArray = [mutArray copy];
        [self.collectionView reloadData];
    }else {
        if (indexPath.row>0) {
            [mutArray removeObjectAtIndex:indexPath.row - 1];
        }
        self.dataArray = [mutArray copy];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

@end
