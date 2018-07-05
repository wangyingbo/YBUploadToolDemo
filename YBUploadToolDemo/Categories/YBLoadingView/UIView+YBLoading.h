//
//  UIButton+YBLoading
//  CQKit
//
//  Created by 王迎博 on 2017/10/19.
//  Copyright © 2017年 kuaijiankang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YBLoading)

/**
 展示loading（默认灰色）
 */
- (void)yb_showLoading;

/**
 展示指定颜色的loading
 
 @param color loading的颜色
 */
- (void)yb_showLoadingWithColor:(UIColor *)color;

/**
 移除loading
 */
- (void)yb_removeLoading;

@end
