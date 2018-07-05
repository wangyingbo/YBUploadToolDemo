//
//  FBAttachmentUploadCollectionViewCell.m
//  FengbangB
//
//  Created by fengbang on 2018/6/28.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "FBAttachmentUploadCollectionViewCell.h"
#import "FBCustomUploadProgress.h"
#import "header.h"


@interface FBAttachmentUploadCollectionViewCell ()
@property (nonatomic, strong) UIImageView *resourceImageView;
@property (nonatomic, strong) UIButton *cleanButton;
@property (nonatomic, strong) FBCustomUploadProgress *progressView;
//@property (nonatomic, strong) FBAttachmentCellStyleModel *model;
@end

/**最大的图片个数*/
extern NSInteger const kAttachmentPhotoMaxNumber;

@implementation FBAttachmentUploadCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - private
- (void)setUI {
    [self setSubViewsUI];
}
- (void)setSubViewsUI {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *resourceImageView = [[UIImageView alloc] init];
    resourceImageView.contentMode = UIViewContentModeScaleAspectFill;
    resourceImageView.clipsToBounds = YES;
    resourceImageView.backgroundColor = YBColorHexString(@"E6E6E6");
    [self.contentView addSubview:resourceImageView];
    self.resourceImageView = resourceImageView;
    
    UIButton *cleanButton = [[UIButton alloc] init];
    [cleanButton setBackgroundImage:[UIImage imageNamed:@"clean_attachment_icon"] forState:UIControlStateNormal];
    [cleanButton addTarget:self action:@selector(cleanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cleanButton];
    self.cleanButton = cleanButton;
    
    FBCustomUploadProgress *progressView = [[FBCustomUploadProgress alloc] init];
    [progressView configProgressBgColor:[UIColor colorWithWhite:0. alpha:.5] progressColor:APP_MAIN_COLOR];
    progressView.hidden = YES;
    progressView.presentlab.font = KV_FONT(7.);
    [self.contentView addSubview:progressView];
    self.progressView = progressView;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.resourceImageView.frame = self.contentView.bounds;
    CGFloat cleanButtonW = 30;
    self.cleanButton.frame = CGRectMake(self.resourceImageView.width - cleanButtonW, 0, cleanButtonW, cleanButtonW);
    self.progressView.frame = CGRectMake(5, self.contentView.height - 8 - 5, self.contentView.width - 10, 8);
}


#pragma mark - public
- (void)configCellWithData:(id)obj {
    FBAttachmentCellStyleModel *model = (FBAttachmentCellStyleModel *)obj;
    self.resourceImageView.image = model.image;
    [self showCleanIcon:!model.hiddenCleanIcon];
    [self configCellProgress:0.01];
    
    if (model.uploadStatus != YBAttachmentUploadStatusEnd) {
        model.UploadProgress = ^(CGFloat p) {
            [self showProgress:YES];
            [self showCleanIcon:NO];
            [self configCellProgress:p];
        };
        model.UploadSuccess = ^(id obj) {
            [self showCleanIcon:YES];
            [self showProgress:NO];
        };
        model.UploadFailure = ^(NSError *error) {
            
        };
    }
}

- (void)configCellAdd {
    [self showCleanIcon:NO];
    [self showProgress:NO];
    self.resourceImageView.image = [UIImage imageNamed:@"add_attachment_icon"];
}

- (void)configCellProgress:(CGFloat)progress {
    [self.progressView setPresent:progress];
}

- (void)showProgress:(BOOL)show {
    self.progressView.hidden = !show;
}

- (void)showCleanIcon:(BOOL)show {
    self.cleanButton.hidden = !show;
}

#pragma mark - private

- (void)cleanButtonClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(configCellDelete:withOject:)]) {
        [self.delegate configCellDelete:self withOject:nil];
    }
}

@end


#pragma mark -----------------FBAttachmentCellStyleModel-------------------

@implementation FBAttachmentCellStyleModel


@end
