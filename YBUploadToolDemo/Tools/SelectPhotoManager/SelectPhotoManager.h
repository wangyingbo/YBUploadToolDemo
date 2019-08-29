//
//  SelectPhotoManager.h
//  FengbangB
//
//  Created by 王迎博 on 2018/6/28.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//
//  单选图片或者拍照工具类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol selectPhotoDelegate <NSObject>
@optional;
//照片选取成功
- (void)selectPhotoManagerDidFinishImage:(UIImage *)image;
//照片选取失败
- (void)selectPhotoManagerDidError:(NSError *)error;
@end



typedef enum {
    PhotoCamera = 0,
    PhotoAlbum,
} SelectPhotoType;

/**
 错误码回调
 */
typedef NS_ENUM(NSUInteger,YBSelectPhotoErrorTag) {
    /**相机不可用*/
    YBSelectPhotoErrorTagNoCamera = 1,
    /**撤销*/
    YBSelectPhotoErrorTagCancel,
    /**相册不可用*/
    YBSelectPhotoErrorTagNoAlbum,
    /**类型错误*/
    YBSelectPhotoErrorTagTypeError,
    /**保存图片不可用*/
    YBSelectPhotoErrorTagSavePhotoAlbum,
};

/**
 当前相册认证的状态
 */
typedef NS_ENUM(NSInteger, YBPhotoAuthorizationStatus) {
    /**用户尚未做出选择这个应用程序的问候*/
    YBPhotoAuthorizationStatusNotDetermined = 0,
    /**此应用程序没有被授权访问的照片数据。可能是家长控制权限*/
    YBPhotoAuthorizationStatusRestricted,
    /**用户已经明确否认了这一照片数据的应用程序访问*/
    YBPhotoAuthorizationStatusDenied,
    /**用户已经授权应用访问照片数据*/
    YBPhotoAuthorizationStatusAuthorized,
    /**ios 8 以后可用，等同YBPhotoAuthorizationStatusAuthorized*/
    YBPhotokCLAuthorizationStatusAuthorizedAlways,
    /**ios 8 以后可用，此状态为：用户是否勾选了app在前台时，才允许访问相册*/
    YBPhotokCLAuthorizationStatusAuthorizedWhenInUse,
};

/**
 当前相机认证的状态
 */
typedef NS_ENUM(NSInteger, YBCameraAuthorizationStatus) {
    /**用户尚未做出选择这个应用程序的问候*/
    YBCameraAuthorizationStatusNotDetermined = 0,
    /**此应用程序没有被授权访问的照片数据。可能是家长控制权限*/
    YBCameraAuthorizationStatusRestricted    = 1,
    /**用户已经明确否认了这一照片数据的应用程序访问*/
    YBCameraAuthorizationStatusDenied        = 2,
    /**用户已经授权应用访问照片数据*/
    YBCameraAuthorizationStatusAuthorized    = 3,
};



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
@property(nonatomic, copy)void (^errorHandle)(YBSelectPhotoErrorTag tag);


#pragma mark - 开始选择图片，在属性block里successHandle和errorHandle拿到结果
/**开始选取照片，在属性block里successHandle和errorHandle拿到结果*/
- (void)startSelectPhoto;
/***/
- (void)startSelectPhotoWithImageName:(NSString *)imageName;
/***/
- (void)startSelectPhotoWithImageName:(NSString *)imageName withAlertTitle:(NSString *)title;
/**根据类型选择照片，可以传SelectPhotoType枚举值里的一个，只有相册或拍照，在回调里拿到结果*/
- (void)startSelectPhotoWithType:(SelectPhotoType )type andImageName:(NSString *)imageName;


#pragma mark - 有回调的选择方法，默认是弹actionSheet，从相册或者拍照，在回调里拿到结果
/**有回调的选择方法，默认是弹actionSheet，从相册或者拍照，在回调里拿到结果*/
- (void)startSelectPhotoSuccess:(void(^)(SelectPhotoManager *manager, UIImage *image))success failure:(void(^)(YBSelectPhotoErrorTag tag))failure;
/**根据传入type类型选取照片*/
- (void)startSelectPhotoWithType:(SelectPhotoType )type success:(void(^)(SelectPhotoManager *manager, UIImage *image))success failure:(void(^)(YBSelectPhotoErrorTag tag))failure;


#pragma mark - 授权访问相册和摄像头 authorization method
/**
 主动触发相机的授权提示
 
 @param handle 回调
 */
+ (void)showCameraAuthorization:(void(^)(BOOL authorization))handle;

/**
 主动触发相册的授权提示
 
 @param handle 回调
 */
+ (void)showPhotoAlbumAuthorization:(void(^)(BOOL authorization))handle;

/**
 读取设备相册的授权状态
 
 @return return value description
 */
+ (BOOL)isCanUsePhotos;

/**
 判断相册当前的认证状态是否是参数给的状态
 
 @param status YBPhotoAuthorizationStatus状态
 @return return value description
 */
+ (BOOL)currentPhotoAuthorizationIsStatus:(YBPhotoAuthorizationStatus)status;

/**
 读取设备相机的授权状态
 
 @return return value description
 */
+ (BOOL)isCanUseCamera;

/**
 判断相机当前的认证状态是否是参数给的状态
 
 @param status YBCameraAuthorizationStatus状态
 @return return value description
 */
+ (BOOL)currentCameraAuthorizationIsStatus:(YBCameraAuthorizationStatus)status;


@end
