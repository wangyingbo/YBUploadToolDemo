//
//  FBBasicUploadModel.m
//  FengbangB
//
//  Created by fengbang on 2018/7/5.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "FBBasicUploadModel.h"

@implementation FBBasicUploadModel


- (void)asyncConcurrentUploadSuccess:(void (^)(id))success progress:(void (^)(CGFloat))progress failure:(void (^)(NSError *))failure {
    
    dispatch_async(dispatch_queue_create("com.fb_upload.queue", DISPATCH_QUEUE_CONCURRENT), ^{
        
        [FBBasicUploadModel uploadWithModel:self success:^(id obj) {
            if (success) { success(obj); }
        } progress:^(CGFloat p) {
            if (progress) { progress(p); }
        } failure:^(NSError *error) {
            if (failure) { failure(error); }
        }];

    });
}


/**
 抽取的公共的上传方法

 @param model 每个图片model
 @param success 成功回调
 @param progress 进度回调
 @param failure 失败回调
 */
+ (void)uploadWithModel:(FBBasicUploadModel *)model success:(void(^)(id obj))success progress:(void(^)(CGFloat p))progress failure:(void(^)(NSError *error))failure {
    if (!model) { return; }
    NSAssert(model, @"model为nil");
    
    model.uploadStatus = YBAttachmentUploadStatusUploading;
    for (; model.progress<=1.0f; ) {
        CGFloat per = (arc4random() % 100)/1000.0f;
        model.progress += per;
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"index：%@----进度：%.2f",self.index,self.progress);
            //模拟上传中的状态
            if (progress) { progress(model.progress); }
            if (model.UploadProgress) { model.UploadProgress(model.progress); }
            //模拟上传完成的状态
            if (model.progress>=1.) {
                model.uploadStatus = YBAttachmentUploadStatusEnd;
                if (success) { success(nil); }
                if (model.UploadSuccess) { model.UploadSuccess(nil); }
                return ;
            }
            //模拟上传失败的状态
            if (model.progress<0) {
                model.uploadStatus = YBAttachmentUploadStatusNone;
                if (failure) { failure(nil); }
                if (model.UploadFailure) { model.UploadFailure(nil); }
            }
        });
        usleep(500000);
    }
}

@end
