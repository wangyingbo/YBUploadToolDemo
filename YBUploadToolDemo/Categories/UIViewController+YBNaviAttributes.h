//
//  UIViewController+YBNaviAttributes.h
//  FengbangC
//
//  Created by 王迎博 on 2018/5/22.
//  Copyright © 2018年 王迎博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (YBNaviAttributes)

@property (nonatomic, strong) UIImage *oldBarImage;

- (void)yb_setNavigationBackgroundImage:(UIImage*)image;

- (void)yb_recoverNavigationBackgroundImage;

/**
 设置navigationItem.title

 @param title 文字
 @param font 字体
 @param color 颜色
 */
- (void)yb_setTitleAttributesWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color;

/**
 设置rightBarButtonItem

 @param title 文字
 @param font 字体
 @param color 颜色
 @param action 方法
 */
- (void)yb_setRightBarButtonItemWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color action:(nullable SEL)action;

/**
 设置rightBarButtonItem

 @param image 图片
 @param action 方法
 */
- (void)yb_setRightBarButtonItemWithImage:(UIImage *)image action:(nullable SEL)action;

/**
 设置tintColor-返回键颜色

 @param tintColor 返回键的颜色
 */
- (void)yb_setTintColor:(UIColor *)tintColor;

@end
