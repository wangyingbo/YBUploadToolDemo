//
//  FBUploadTool.h
//  FengbangB
//
//  Created by fengbang on 2018/7/5.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "FBBasicUploadModel.h"

@interface FBUploadTool : FBBasicUploadModel


/**
 异步并行上传多张图片（用dispatch_group_t上传）

 @param modelArray 图片model数组
 @param uploading 上传中的状态回调
 @param completion 上传完成回调
 */
+ (void)asyncConcurrentGroupUploadArray:(NSArray<FBBasicUploadModel *> *)modelArray uploading:(void(^)(void))uploading completion:(void(^)(id obj))completion;

/**
 异步并行上传多张图片（用常量监控上传）

 @param modelArray 图片model数组
 @param uploading 上传中的状态回调
 @param completion 上传完成回调
 */
+ (void)asyncConcurrentConstUploadArray:(NSArray<FBBasicUploadModel *> *)modelArray uploading:(void(^)(void))uploading completion:(void(^)(id obj))completion;;

/**
 异步串行上传图片（上传多张），通过dispatch_semaphore_t保证一张一张串行上传
 每个model的回调可通过每个model的属性block回调
 
 @param progress 总的进度条回调
 @param completion 总的任务完成回调
 */
+ (void)asyncSerialUploadArray:(NSArray<FBBasicUploadModel *> *)modelArray progress:(void(^)(CGFloat p, NSInteger index))progress completion:(void(^)(id obj))completion;

@end
