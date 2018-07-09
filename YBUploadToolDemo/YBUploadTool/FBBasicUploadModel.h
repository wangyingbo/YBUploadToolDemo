//
//  FBBasicUploadModel.h
//  FengbangB
//
//  Created by fengbang on 2018/7/5.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 上传状态
 */
typedef NS_ENUM(NSInteger, YBAttachmentUploadStatus) {
    /**未上传*/
    YBAttachmentUploadStatusNone = 0,
    /**上传中*/
    YBAttachmentUploadStatusUploading,
    /**上传结束*/
    YBAttachmentUploadStatusEnd,
};

@interface FBBasicUploadModel : NSObject

/**上传成功后返回的url*/
@property (nonatomic, copy) NSString *imgUrl;
/**选择后的图片*/
@property (nonatomic, strong) UIImage *image;
/**上传状态*/
@property (nonatomic, assign) YBAttachmentUploadStatus uploadStatus;
/**进度0~1*/
@property (nonatomic, assign) CGFloat progress;
/**当前是第几张图片*/
@property (nonatomic, copy) NSString *index;

/**进度回调*/
@property (nonatomic, copy) void(^UploadProgress)(CGFloat p);
/**成功回调*/
@property (nonatomic, copy) void(^UploadSuccess)(id obj);
/**失败回调*/
@property (nonatomic, copy) void(^UploadFailure)(NSError *error);

/**
 异步并行上传图片（一次只上传一张）
 
 @param success 每个model成功回调
 @param progress 每个model进度条回调
 @param failure 每个model失败回调
 */
- (void)asyncConcurrentUploadSuccess:(void(^)(id obj))success progress:(void(^)(CGFloat p))progress failure:(void(^)(NSError *error))failure;

/**
 抽取的公共的上传方法，模拟网络上传，可在此方法里用 afn 上传
 
 @param model 每个图片model
 @param success 成功回调
 @param progress 进度回调
 @param failure 失败回调
 */
+ (void)uploadWithModel:(FBBasicUploadModel *)model success:(void(^)(id obj))success progress:(void(^)(CGFloat p))progress failure:(void(^)(NSError *error))failure;


@end
