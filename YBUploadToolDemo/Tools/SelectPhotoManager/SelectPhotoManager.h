//
//  SelectPhotoManager.h
//  FengbangB
//
//  Created by fengbang on 2018/6/28.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    PhotoCamera = 0,
    PhotoAlbum,
} SelectPhotoType;

@protocol selectPhotoDelegate <NSObject>
//照片选取成功
- (void)selectPhotoManagerDidFinishImage:(UIImage *)image;
//照片选取失败
- (void)selectPhotoManagerDidError:(NSError *)error;

@end

@interface SelectPhotoManager : NSObject<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

//代理对象
@property(nonatomic, weak)__weak id<selectPhotoDelegate>delegate;
//是否开启照片编辑功能
@property(nonatomic, assign)BOOL canEditPhoto;
//跳转的控制器 可选参数
@property(nonatomic, weak)__weak UIViewController *currentVC;

//照片选取成功回调
@property(nonatomic, copy)void (^successHandle)(SelectPhotoManager *manager, UIImage *image);
//照片选取失败回调
@property(nonatomic, copy)void (^errorHandle)(NSString *errorReason);


/**有回调的选择方法*/
- (void)startSelectPhotoSuccess:(void(^)(SelectPhotoManager *manager, UIImage *image))success failure:(void(^)(NSString *errorReason))failure;

/**开始选取照片，在属性block里successHandle和errorHandle拿到结果*/
- (void)startSelectPhoto;
- (void)startSelectPhotoWithImageName:(NSString *)imageName;
- (void)startSelectPhotoWithImageName:(NSString *)imageName withAlertTitle:(NSString *)title;
- (void)startSelectPhotoWithType:(SelectPhotoType )type andImageName:(NSString *)imageName;

@end
