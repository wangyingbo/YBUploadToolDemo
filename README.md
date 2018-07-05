# YBUploadToolDemo
 上传工具


![预览图](https://raw.githubusercontent.com/wangyingbo/YBUploadToolDemo/master/gif.gif)



![预览图](https://raw.githubusercontent.com/wangyingbo/YBUploadToolDemo/master/1.png)


### 封装图片上传工具，包含异步并行上传与异步串行上传，可以一次上传多张开启多个线程，也可以上传多张一张一张顺序上传

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
