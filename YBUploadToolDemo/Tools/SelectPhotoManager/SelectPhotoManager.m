//
//  SelectPhotoManager.m
//  FengbangB
//
//  Created by 王迎博 on 2018/6/28.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "SelectPhotoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <CoreLocation/CoreLocation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"//消除方法过期的警告

@implementation SelectPhotoManager {
    //图片名
    NSString *_imageName;
}

static SelectPhotoManager *sharedInstance = nil;
+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SelectPhotoManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - overwrite
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - public

- (void)startSelectPhoto {
    [self startSelectPhotoWithImageName:nil];
}

//开始选择照片
- (void)startSelectPhotoWithImageName:(NSString *)imageName {
    [self startSelectPhotoWithImageName:imageName withAlertTitle:nil];
}

- (void)startSelectPhotoWithImageName:(NSString *)imageName withAlertTitle:(NSString *)title {
    _imageName = imageName;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction: [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self startSelectPhotoWithType:PhotoCamera andImageName:imageName];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"从相册获取" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self startSelectPhotoWithType:PhotoAlbum andImageName:imageName];
    }]];
    [alertController addAction:cancelAction];
    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}

//根据类型选取照片
- (void)startSelectPhotoWithType:(SelectPhotoType)type andImageName:(NSString *)imageName {
    _imageName = imageName;
    [self selectPhotoWithType:type];
}

- (void)startSelectPhotoSuccess:(void (^)(SelectPhotoManager *, UIImage *))success failure:(void (^)(YBSelectPhotoErrorTag tag))failure {
    [self startSelectPhoto];
    self.successHandle = success;
    self.errorHandle = failure;
}

- (void)startSelectPhotoWithType:(SelectPhotoType)type success:(void (^)(SelectPhotoManager *, UIImage *))success failure:(void (^)(YBSelectPhotoErrorTag tag))failure {
    self.successHandle = success;
    self.errorHandle = failure;
    [self selectPhotoWithType:type];
}

-(void)selectPhotoWithType:(int)type {
    if (type >= 2) {
        !self.errorHandle?:self.errorHandle(YBSelectPhotoErrorTagTypeError);
        return;
    }
    
    if (type == PhotoAlbum) {
        if ([SelectPhotoManager currentPhotoAuthorizationIsStatus:YBPhotoAuthorizationStatusNotDetermined]) {
            [SelectPhotoManager showPhotoAlbumAuthorization:^(BOOL authorization) {
                if (authorization) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self selectPhotoWithType:type];
                    });
                }
            }];
            return;
        }
        if ([SelectPhotoManager currentPhotoAuthorizationIsStatus:YBPhotoAuthorizationStatusDenied]) {
            [self showPhotosSettingAlert];
            return;
        }
        if ([SelectPhotoManager currentPhotoAuthorizationIsStatus:YBPhotoAuthorizationStatusRestricted]) {
            [self showPhotosSettingAlert];
            return;
        }
    }
    
    if (type == PhotoCamera) {
        if ([SelectPhotoManager currentCameraAuthorizationIsStatus:YBCameraAuthorizationStatusNotDetermined]) {
            [SelectPhotoManager showCameraAuthorization:^(BOOL authorization) {
                if (authorization) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self selectPhotoWithType:type];
                    });
                }
            }];
            return;
        }
        if ([SelectPhotoManager currentCameraAuthorizationIsStatus:YBCameraAuthorizationStatusDenied]) {
            [self showCameraSettingAlert];
            return;
        }
        if ([SelectPhotoManager currentCameraAuthorizationIsStatus:YBCameraAuthorizationStatusRestricted]) {
            [self showCameraSettingAlert];
            return;
        }
    }
    
    UIImagePickerController *ipVC = [[UIImagePickerController alloc] init];
    //设置跳转方式
    ipVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    ipVC.allowsEditing = self.canEditPhoto;
    
    ipVC.delegate = self;
    if (type == PhotoCamera) {
        BOOL isCameraSource = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        BOOL isCameraDevice = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCameraDevice || !isCameraSource) {
            !self.errorHandle?:self.errorHandle(YBSelectPhotoErrorTagNoCamera);
            return ;
        }
        ipVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        BOOL isPhotoLibrarySource = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        if (!isPhotoLibrarySource) {
            !self.errorHandle?:self.errorHandle(YBSelectPhotoErrorTagNoAlbum);
            return;
        }
        ipVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [[self getCurrentVC] presentViewController:ipVC animated:YES completion:nil];
}

#pragma mark - authorization method
/**
 主动触发相机的授权提示
 
 @param handle 回调
 */
+ (void)showCameraAuthorization:(void(^)(BOOL authorization))handle {
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted) {//允许
            !handle?:handle(YES);
        }else {
            !handle?:handle(NO);
        }
    }];
}

/**
 主动触发相册的授权提示
 
 @param handle 回调
 */
+ (void)showPhotoAlbumAuthorization:(void(^)(BOOL authorization))handle {
    //iOS8之前 APP 第一次访问相册 系统弹窗 方法的拦截
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // 用户点击 "OK"
            !handle?:handle(YES);
        } failureBlock:^(NSError *error) {
            // 用户点击 不允许访问
            !handle?:handle(NO);
        }];
    }
    
    //iOS8之后 APP 第一次访问相册 系统弹窗 方法的拦截
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if(status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 用户点击 "OK"
                    !handle?:handle(YES);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 用户点击 不允许访问
                    !handle?:handle(NO);
                });
            }
        }];
    }
}

/**
 读取设备相册的授权状态
 
 @return return value description
 */
+ (BOOL)isCanUsePhotos {
    /**
     typedef enum {
     kCLAuthorizationStatusNotDetermined = 0, // 用户尚未做出选择这个应用程序的问候
     kCLAuthorizationStatusRestricted,        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
     kCLAuthorizationStatusDenied,            // 用户已经明确否认了这一照片数据的应用程序访问
     kCLAuthorizationStatusAuthorized         // 用户已经授权应用访问照片数据
     } CLAuthorizationStatus;
     */
    
    //ios11之后的系统，可以不需要进行询问用户，就可以直接访问相册。 但是这就出现了一个问题，可以不需要进行询问用户，但是选择图片之后，系统又会询问是否允许询问相册权限。为解决这个问题，不要用ALAuthorizationStatus来判断相册权限。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied) { //无权限
            return NO;
        }
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) { //无权限
            return NO;
        }
    }
    return YES;
}

+ (BOOL)currentPhotoAuthorizationIsStatus:(YBPhotoAuthorizationStatus)status {
    BOOL _isLessThanIOS_8 = ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)?YES:NO;
    BOOL _isEqual = NO;
    
    NSInteger _currentStatus;
    //    NSInteger _author;
    //    if (_isLessThanIOS_8) {
    //        _author = [ALAssetsLibrary authorizationStatus];
    //    }else {
    //        _author = [PHPhotoLibrary authorizationStatus];
    //    }
    ALAuthorizationStatus kclAuthor =[ALAssetsLibrary authorizationStatus];
    PHAuthorizationStatus phAuthor = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case YBPhotoAuthorizationStatusNotDetermined:
        {
            _currentStatus = _isLessThanIOS_8?kCLAuthorizationStatusNotDetermined:PHAuthorizationStatusNotDetermined;
        }
            break;
        case YBPhotoAuthorizationStatusRestricted:
        {
            _currentStatus = _isLessThanIOS_8?kCLAuthorizationStatusRestricted:PHAuthorizationStatusRestricted;
        }
            break;
        case YBPhotoAuthorizationStatusDenied:
        {
            _currentStatus = _isLessThanIOS_8?kCLAuthorizationStatusDenied:PHAuthorizationStatusDenied;
        }
            break;
        case YBPhotoAuthorizationStatusAuthorized:
        {
            _currentStatus = _isLessThanIOS_8?kCLAuthorizationStatusAuthorized:PHAuthorizationStatusAuthorized;
        }
            break;
        case YBPhotokCLAuthorizationStatusAuthorizedAlways:
        {
            _currentStatus = kCLAuthorizationStatusAuthorizedAlways;
        }
            break;
        case YBPhotokCLAuthorizationStatusAuthorizedWhenInUse:
        {
            _currentStatus = kCLAuthorizationStatusAuthorizedWhenInUse;
        }
            break;
        default:
            break;
    }
    if (status == YBPhotokCLAuthorizationStatusAuthorizedAlways) {
        _isEqual = (_currentStatus == kclAuthor)?YES:NO;
    }else if (status == YBPhotokCLAuthorizationStatusAuthorizedWhenInUse) {
        _isEqual = (_currentStatus == kclAuthor)?YES:NO;
    }else {
        _isEqual = _isLessThanIOS_8?(_currentStatus == kclAuthor?YES:NO):(_currentStatus == phAuthor?YES:NO);
    }
    
    return _isEqual;
}

/**
 读取设备相机的授权状态
 
 @return return value description
 */
+ (BOOL)isCanUseCamera {
    /**
     typedef NS_ENUM(NSInteger, AVAuthorizationStatus) {
     AVAuthorizationStatusNotDetermined = 0,// 系统还未知是否访问，第一次开启相机时
     AVAuthorizationStatusRestricted, // 受限制的
     AVAuthorizationStatusDenied, //不允许
     AVAuthorizationStatusAuthorized // 允许状态
     } NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;
     
     */
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) { //无权限
        return NO;
    }
    
    return YES;
}

+ (BOOL)currentCameraAuthorizationIsStatus:(YBCameraAuthorizationStatus)status {
    AVAuthorizationStatus author =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus _currentStatus;
    switch (status) {
        case YBCameraAuthorizationStatusNotDetermined:
        {
            _currentStatus = AVAuthorizationStatusNotDetermined;
        }
            break;
        case YBCameraAuthorizationStatusRestricted:
        {
            _currentStatus = AVAuthorizationStatusRestricted;
        }
            break;
        case YBCameraAuthorizationStatusDenied:
        {
            _currentStatus = AVAuthorizationStatusDenied;
        }
            break;
        case YBCameraAuthorizationStatusAuthorized:
        {
            _currentStatus = AVAuthorizationStatusAuthorized;
        }
            break;
            
        default:
            break;
    }
    
    return (author == _currentStatus)?YES:NO;
}

/**
 当相册无授权时，弹窗提示
 */
- (void)showPhotosSettingAlert {
    NSString *message = @"您没有使用相册的权限，请在设置里打开相册权限";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle: UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *messageAtt = [[NSMutableAttributedString alloc] initWithString:message];
    [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, message.length)];
    [messageAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, message.length)];
    [alertController setValue:messageAtt forKey:@"attributedMessage"];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        });
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}

/**
 当相机没有授权时，弹窗
 */
- (void)showCameraSettingAlert {
    NSString *message = @"您没有使用相机的权限，请在设置里打开相机权限";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle: UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *messageAtt = [[NSMutableAttributedString alloc] initWithString:message];
    [messageAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, message.length)];
    [messageAtt addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, message.length)];
    [alertController setValue:messageAtt forKey:@"attributedMessage"];
    
    [alertController addAction: [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        });
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - private
//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC {
    
    if (self.currentVC) {
        return self.currentVC;
    }
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
        
    }else{
        result = window.rootViewController;
    }
    if (![result isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    return result;
}


#pragma mark - imagePickerController协议方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //NSLog(@"info = %@",info);
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (image == nil) {
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    }
    //图片旋转
    if (image.imageOrientation != UIImageOrientationUp) {
        //图片旋转
        image = [self fixOrientation:image];
    }
    if (_imageName==nil || _imageName.length == 0) {
        //获取当前时间,生成图片路径
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
        NSString *dateStr = [formatter stringFromDate:date];
        _imageName = [NSString stringWithFormat:@"photo_%@.png",dateStr];
    }
    
    [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(selectPhotoManagerDidFinishImage:)]) {
        [_delegate selectPhotoManagerDidFinishImage:image];
    }
    
    if (_successHandle) {
        _successHandle(self,image);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [[self getCurrentVC] dismissViewControllerAnimated:YES completion:nil];
    if (_delegate && [_delegate respondsToSelector:@selector(selectPhotoManagerDidError:)]) {
        [_delegate selectPhotoManagerDidError:nil];
    }
    !self.errorHandle?:self.errorHandle(YBSelectPhotoErrorTagCancel);
}

#pragma mark 图片处理方法
//图片旋转处理
- (UIImage *)fixOrientation:(UIImage *)aImage {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

#pragma clang diagnostic pop

