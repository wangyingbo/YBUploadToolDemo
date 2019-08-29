//
//  ViewController.m
//  YBUploadToolDemo
//
//  Created by fengbang on 2018/7/5.
//  Copyright © 2018年 王颖博. All rights reserved.
//

#import "ViewController.h"
#import "FBAttachmentUploadVC.h"
#import "UIViewController+YBNaviAttributes.h"
#import "UIImage+Extension.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        tableView.estimatedRowHeight = 44;
        tableView.estimatedSectionHeaderHeight = 15.;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorInset = UIEdgeInsetsMake(0.5, 14, 0, 0);
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.01)];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.01)];
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

#pragma mark - overwrite
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    
    [self configNavigation];
    
    [self configData];
}

#pragma amrk - configData
- (void)configData {
    self.dataArray = @[@"异步并行",@"异步串行",@"自己选图片"];
}

#pragma mark - configUI
- (void)configUI {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)configNavigation {
    UIImage *bgImage = [UIImage imageWithColor:[UIColor redColor]];
    //[self yb_setNavigationBackgroundImage:bgImage];
    
    [self yb_setTitleAttributesWithTitle:@"demo" font:[UIFont systemFontOfSize:17.] color:[UIColor darkGrayColor]];
}

#pragma mark - dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellId];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.];
    cell.detailTextLabel.text = @"click here!";
    
    return cell;
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBAttachmentUploadVC *uploadVC = [[FBAttachmentUploadVC alloc]init];
    uploadVC.status = indexPath.row;
    [self.navigationController pushViewController:uploadVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}


@end
