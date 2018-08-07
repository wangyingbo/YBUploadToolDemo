//
//  FBUploadTool.m
//  FengbangB
//
//  Created by fengbang on 2018/7/5.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "FBUploadTool.h"
#import <libkern/OSAtomic.h>

NSString * const FBAttachmentUploadSuccessNumber = @"successNumber";
NSString * const FBAttachmentUploadFailureNumber = @"failureNumber";
int32_t _longInt = 1;


@implementation FBUploadTool

+ (void)initialize {
    _longInt = 1;
}

+ (void)asyncConcurrentGroupUploadArray:(NSArray<FBBasicUploadModel *> *)modelArray uploading:(void(^)(void))uploading completion:(void (^)(id))completion {
    
    if (!modelArray || modelArray.count<1) {
        return;
    }
    NSAssert((modelArray && modelArray.count>0), @"图片model数组nil");
    
    //创建group
    dispatch_group_t uploadGroup = dispatch_group_create();
    
    for (FBBasicUploadModel *model in modelArray) {
        if (!model.image) { continue; }
        if (model.uploadStatus != YBAttachmentUploadStatusNone) { continue; }
        
        dispatch_group_enter(uploadGroup);
        [model asyncConcurrentUploadSuccess:^(id obj) {
            dispatch_group_leave(uploadGroup);
        } progress:^(CGFloat p) {
            if (uploading) { uploading(); }
        } failure:^(NSError *error) {
            dispatch_group_leave(uploadGroup);
        }];
    }
    
    dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(nil);
        }
    });
}

+ (void)asyncConcurrentConstUploadArray:(NSArray<FBBasicUploadModel *> *)modelArray uploading:(void (^)(void))uploading completion:(void (^)(id))completion {
    
    if (!modelArray || modelArray.count<1) {
        return;
    }
    NSAssert((modelArray && modelArray.count>0), @"图片model数组nil");
    
    void (^endBlock)(int32_t) = ^(int32_t x){
        if (x == 1) {
            if (completion) { completion(nil); }
        }
    };
    
    for (FBBasicUploadModel *model in modelArray) {
        if (!model.image) { continue; }
        if (model.uploadStatus != YBAttachmentUploadStatusNone) { continue; }
        
        OSAtomicIncrement32(&_longInt);
        
        [model asyncConcurrentUploadSuccess:^(id obj) {
            OSAtomicDecrement32(&_longInt);
            endBlock(_longInt);
        } progress:^(CGFloat p) {
            if (uploading) { uploading(); }
        } failure:^(NSError *error) {
            OSAtomicDecrement32(&_longInt);
            endBlock(_longInt);
        }];
    }
}

+ (void)asyncSerialUploadArray:(NSArray<FBBasicUploadModel *> *)modelArray progress:(void(^)(CGFloat p, NSInteger index))progress completion:(void(^)(id obj))completion {
    
    if (!modelArray || modelArray.count<1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            !completion?:completion(nil);
        });
        return;
    }
    NSAssert((modelArray && modelArray.count>0), @"图片model数组nil");
    
    //dispatch_semaphore_t signal = dispatch_semaphore_create(0);//总的信号
    //dispatch_group_t uploadGroup = dispatch_group_create();
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    __block NSInteger successInt=0,failureInt=0;
    
    //取总的图片大小
    NSMutableData *totalData = [NSMutableData data];
    NSMutableData *currentData = [NSMutableData data];
    for (FBBasicUploadModel *model in modelArray) {
        if (!model.image) { continue; }
        if (model.uploadStatus != YBAttachmentUploadStatusNone) { continue; }
        NSData *data = UIImagePNGRepresentation(model.image);
        [totalData appendData:data];
    }
    
    //dispatch_group_enter(uploadGroup);
    //创建异步串行队列
    dispatch_async(dispatch_queue_create("com.fb_upload.queue", DISPATCH_QUEUE_SERIAL), ^{
        //用信号量sema保证一次只上传一个
        dispatch_semaphore_t sema = dispatch_semaphore_create(1);
        NSInteger shouldUploadNumber = 0;
        for (int i = 0;i<modelArray.count;i++) {
            FBBasicUploadModel *model = modelArray[i];
            if (!model) { continue; }
            if (model.uploadStatus != YBAttachmentUploadStatusNone) { continue; }
            if (![model isKindOfClass:[FBBasicUploadModel class]]) { continue; }
            shouldUploadNumber += 1;
            NSData *current;
            if (model.image) {
                current = UIImagePNGRepresentation(model.image);
            }
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            [FBBasicUploadModel uploadWithModel:model success:^(id obj) {
                successInt += 1;
                [currentData appendData:current];
                //单个任务的
                dispatch_semaphore_signal(sema);
                //单个model的成功回调
                if (model.UploadSuccess) { model.UploadSuccess(obj); }
//                if (i+1==modelArray.count) {
//                    dispatch_group_leave(uploadGroup);
//                }
            } progress:^(CGFloat p) {
                //单个model的进度
                if (model.UploadProgress) { model.UploadProgress(p); }
                //总的进度
                if (progress) {
                    if (totalData.length>0) {
                        progress((CGFloat)(currentData.length+current.length*p)/(CGFloat)totalData.length, i);
                    }
                }
            } failure:^(NSError *error) {
                failureInt += 1;
                [currentData appendData:current];
                dispatch_semaphore_signal(sema);
                if (model.UploadFailure) { model.UploadFailure(error); }
//                if (i+1==modelArray.count) {
//                    dispatch_group_leave(uploadGroup);
//                }
            }];
        }
        
        if (shouldUploadNumber<1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !completion?:completion(nil);
            });
        }
    });
    
    //dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
    //});
    
    //总的完成以后的回调
    [mutDic setObject:[NSNumber numberWithInteger:successInt] forKey:FBAttachmentUploadSuccessNumber];
    [mutDic setObject:[NSNumber numberWithInteger:failureInt] forKey: FBAttachmentUploadFailureNumber];
    if (completion) {
        completion(mutDic);
    }
    
}
@end
