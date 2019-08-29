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

/**
 设置导航栏背景图片
 
 @param image image description
 */
- (void)yb_setNavigationBackgroundImage:(UIImage*)image;

/**
 恢复导航栏原有的图片
 */
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
 设置tintColor返回键颜色
 
 @param tintColor 返回键的颜色
 */
- (void)yb_setTintColor:(UIColor *)tintColor;

/**
 设置导航栏颜色
 
 @param barTintColor 导航栏颜色
 */
- (void)yb_setBarTintColor:(UIColor *)barTintColor;

/**
 设置导航栏title颜色
 
 @param navigationTitleColor 字体颜色
 */
- (void)yb_setNavigationTitleColor:(UIColor *)navigationTitleColor;

/**
 设置导航栏控件颜色
 
 @param barTintColor 导航栏主题色
 @param tintColor 返回键颜色
 @param titleColor title颜色
 */
- (void)yb_setNavigationBarTintColor:(UIColor *)barTintColor tintColor:(UIColor *)tintColor titleColor:(UIColor *)titleColor;

/**
 设置系统的侧滑手势是否可用
 可在viewDidAppear:方法和viewWillDisappear:方法里调用
 
 @param enabled bool值
 */
- (void)yb_setInteractivePopGestureRecognizerEnabled:(BOOL)enabled;

@end
