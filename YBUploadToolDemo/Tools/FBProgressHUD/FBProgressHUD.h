//
//  FBProgressHUD.h
//  FengbangC
//
//  Created by 王迎博 on 2018/6/12.
//  Copyright © 2018年 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FBProgressHUD : NSObject

/**
 显示ActivityIndicatorView

 @param view 非必填，为空时加到[UIApplication sharedApplication].keyWindow
 */
+ (instancetype)showIndicatorToView:(UIView *)view;

/**
 隐藏ActivityIndicatorView
 */
+ (BOOL)hiddenIndicatorFromView;

/**
 用UIAlertController显示纯文本信息，无取消和确定按钮

 @param message 文本信息
 */
+ (void)showAlertViewControllerMessage:(NSString *)message;

/**
 弹出提示框

 @param title 提示title
 @param message 内容
 @param actionTitles 按钮的title数组
 @param handler 回调
 @return return value description
 */
+ (UIAlertController *)alertControllerAlertTitle:(NSString *)title
                                          message:(NSString *)message
                                     actionTitles:(NSArray<NSString *> *)actionTitles
                                          handler:(void(^)(UIAlertAction *action,NSInteger index))handler;


@end
